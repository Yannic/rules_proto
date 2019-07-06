## Copyright 2019 The Rules Protobuf Authors. All rights reserved.
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##    http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

load("//proto/private:labels.bzl", "TOOLCHAIN_TYPE")

_FileDescriptorSet = "".join([
    "<a href=\"https://github.com/protocolbuffers/protobuf/blob/",
    "55ed1d427ccc0d200927746329ac9b811dee77b9/src/google/protobuf/",
    "descriptor.proto#L57\">FileDescriptorSet</a>",
])

StarlarkProtoInfo = provider(
    fields = {
        "transitive_imports": " ".join([
            "Transitive imports including weak dependencies.",
        ]),
        "transitive_sources": " ".join([
            "Proto sources for this rule and all its dependent protocol",
            "buffer rules.",
        ]),
        "direct_sources": " ".join([
            "Proto sources from the `srcs` attribute.",
        ]),
        "check_deps_sources": " ".join([
            "Proto sources from the `srcs` attribute. If the library is a",
            "proxy library that has no sources, it contains the",
            "`check_deps_sources` from this library's direct deps.",
        ]),
        "direct_descriptor_set": " ".join([
            "The " + _FileDescriptorSet + " of the direct sources.",
            "If no `srcs`, contains an empty file.",
        ]),
        "transitive_descriptor_sets": " ".join([
            "A set of " + _FileDescriptorSet + " files of all dependent",
            "`proto_library` rules, and this one's.",
            "This is not the same as passing --include_imports to",
            "proto-compiler.",
            "Will be empty if no dependencies.",
        ]),
        "transitive_proto_path": " ".join([
            "A set of proto source roots collected from the transitive closure",
            "of this rule.",
        ]),
        "proto_source_root": " ".join([
            "The directory relative to which the `.proto` files defined in the",
            "`proto_library` are defined. For example, if this is `a/b` and",
            "the rule has the file `a/b/c/d.proto` as a source, that source",
            "file would be imported as `import c/d.proto`.",
        ]),
    },
)

_value_not_set = "::value_not_set::"

def _string_value(value):
    if value == _value_not_set:
        return None
    return value

def _absolute_strip_import_prefix(label, strip_import_prefix):
    if None == strip_import_prefix:
        return None

    if strip_import_prefix.startswith("/"):
        return strip_import_prefix[1:]

    return "{}/{}".format(label.package, strip_import_prefix)

def _assert_starts_with(prefix, string):
    if not string.startswith(prefix):
        fail("Expected that '{}' starts with '{}'.".format(string, prefix))

def _proto_source_root_from_list(roots):
    c = roots[0] if len(roots) else "."
    for r in roots:
        if r != c:
            fail("Found different workspace roots: '{}' and '{}'".format(c, r))
    return c

def _map_workspace_root(src):
    root = src.owner.workspace_root
    if root:
        return root
    return "."

def _proto_source_root(srcs):
    roots = [_map_workspace_root(src) for src in srcs]
    return _proto_source_root_from_list(roots)

def _strip_leading_slash(path):
    if path.startswith("/"):
        return path[1:]
    return path

def _strip_trailing_slash(path):
    if path.endswith("/"):
        return path[:-1]
    return path

def _declare_file(actions, name, path):
    f = "_virtual_imports/{name}/{path}".format(
        name = name,
        path = path,
    )
    return actions.declare_file(f)

def _resolve_srcs(name, actions, srcs, strip_import_prefix, import_prefix):
    if (None == strip_import_prefix) and (None == import_prefix):
        return _proto_source_root(srcs), srcs

    roots = []
    files = []
    for src in srcs:
        path = _strip_leading_slash(src.path)

        workspace_root = src.owner.workspace_root
        if workspace_root:
            path = _strip_leading_slash(path[len(workspace_root):])

        if None != strip_import_prefix:
            path = _strip_leading_slash(path[len(strip_import_prefix):])

        if None != import_prefix:
            path = "{}/{}".format(import_prefix, path)

        file = _declare_file(actions, name, path)
        files.append(file)

        root = _strip_trailing_slash(file.path[:-len(path)])
        roots.append(root)

        actions.expand_template(
            template = src,
            output = file,
            substitutions = {},
        )

    return _proto_source_root_from_list(roots), files

def _get(target, attr):
    if StarlarkProtoInfo in target:
        info = target[StarlarkProtoInfo]
    elif ProtoInfo in target:
        info = target[ProtoInfo]
    else:
        fail("Must have either provider StarlarkProtoInfo or ProtoInfo.")
    return getattr(info, attr)

def _compile(
        actions,
        toolchain,
        descriptor_set_out,
        srcs = [],
        proto_source_root = ".",
        deps = [],
        strict_deps = "ERROR"):
    args = actions.args()

    # 1. Add proto_source_root (including include paths from transitive deps).
    transitive_proto_path = depset(
        direct = [proto_source_root],
        transitive = [_get(dep, "transitive_proto_path") for dep in deps],
    )
    args.add_all(transitive_proto_path, format_each = "--proto_path=%s")

    # 2. Add output file.
    args.add(descriptor_set_out, format = "--descriptor_set_out=%s")

    # 3. Add check_deps plugin.
    check_deps_sources = depset(srcs)
    if not len(srcs):
        check_deps_sources = [_get(dep, "direct_sources") for dep in deps]

    # TODO(yannic): Implement.

    # 4. Add direct sources.
    transitive_imports = depset(
        direct = srcs,
        transitive = [_get(dep, "transitive_imports") for dep in deps],
    )
    args.add_all(srcs)

    # 5. Generate.
    # Bazel's native `proto_library` emits an empty descriptor set if |srcs|
    # is empty.
    if not len(srcs):
        actions.write(
            output = descriptor_set_out,
            content = "",
        )
    else:
        actions.run(
            executable = toolchain.protoc,
            inputs = transitive_imports,
            outputs = [descriptor_set_out],
            arguments = [args],
            mnemonic = "StarlarkGenProto",
        )

    return StarlarkProtoInfo(
        transitive_imports = transitive_imports,
        transitive_sources = depset(
            direct = srcs,
            transitive = [_get(dep, "transitive_sources") for dep in deps],
        ),
        direct_sources = depset(
            direct = srcs,
        ),
        check_deps_sources = check_deps_sources,
        direct_descriptor_set = depset(
            direct = [descriptor_set_out],
        ),
        transitive_descriptor_sets = depset(
            direct = [descriptor_set_out],
            transitive = [_get(dep, "transitive_descriptor_sets") for dep in deps],
        ),
        transitive_proto_path = transitive_proto_path,
        proto_source_root = proto_source_root,
    )

def _starlark_proto_library_impl(ctx):
    proto_source_root, direct_sources = _resolve_srcs(
        name = ctx.attr.name,
        actions = ctx.actions,
        srcs = ctx.files.srcs,
        strip_import_prefix = _absolute_strip_import_prefix(
            label = ctx.label,
            strip_import_prefix = _string_value(ctx.attr.strip_import_prefix),
        ),
        import_prefix = _string_value(ctx.attr.import_prefix),
    )

    descriptor_set_out = ctx.actions.declare_file("{}-descriptor-set.proto.bin".format(ctx.attr.name))
    proto_info = _compile(
        actions = ctx.actions,
        toolchain = ctx.toolchains[TOOLCHAIN_TYPE],
        descriptor_set_out = descriptor_set_out,
        srcs = direct_sources,
        proto_source_root = proto_source_root,
        deps = ctx.attr.deps,
        strict_deps = "ERROR",
    )

    return [
        DefaultInfo(
            files = depset(
                direct = [descriptor_set_out],
            ),
        ),
        proto_info,
    ]

starlark_proto_library = rule(
    implementation = _starlark_proto_library_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = False,
            allow_files = [".proto", ".protodevel"],
            doc = " ".join([
                "The list of `.proto` and `.protodevel` files that are",
                "processed to create the target. This is usually a non empty",
                "list. One  usecase where srcs can be empty is an",
                "alias-library. This is a proto_library rule having one or",
                "more other proto_library in deps. This pattern can be used to",
                "e.g. export a public api under a persistent name.",
            ]),
        ),
        "deps": attr.label_list(
            mandatory = False,
            providers = [],
            doc = " ".join([
                "The list of other `proto_library` rules that the target",
                "depends upon. A `proto_library` may only depend on other",
                "`proto_library` targets. It may not depend on",
                "language-specific libraries.",
            ]),
        ),
        "exports": attr.label_list(
            mandatory = False,
            providers = [],
            doc = " ".join([
                "List of `proto_library` targets that can be referenced via",
                "`import public` in the proto source.",
            ]),
        ),
        "import_prefix": attr.string(
            mandatory = False,
            default = _value_not_set,
            doc = " ".join([
                "The prefix to add to the paths of the `.proto` files in this",
                "rule.\n",
                "When set, the `.proto` source files in the srcs attribute of",
                "this rule are accessible at is the value of this attribute",
                "prepended to their repository-relative path.\n",
                "\n",
                "The prefix in the `strip_import_prefix` attribute is removed",
                "before this prefix is added.",
            ]),
        ),
        "strip_import_prefix": attr.string(
            mandatory = False,
            default = _value_not_set,
            doc = " ".join([
                "The prefix to strip from the paths of the `.proto` files in",
                "this rule.\n",
                "When set, `.proto` source files in the srcs attribute of this",
                "rule are accessible at their path with this prefix cut off.\n",
                "\n",
                "If it's a relative path (not starting with a slash), it's",
                "taken as a package-relative one. If it's an absolute one,",
                "it's understood as a repository-relative path.\n",
                "\n",
                "The prefix in the `import_prefix` attribute is added after",
                "this prefix is stripped.",
            ]),
        ),
    },
    toolchains = [
        TOOLCHAIN_TYPE,
    ],
)
