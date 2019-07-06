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
        return strip_import_prefix

    return "{}/{}".format(label.package, strip_import_prefix)

def _resolve_srcs(srcs, strip_import_prefix, import_prefix):
    if (None == strip_import_prefix) or (None == import_prefix):
        return ".", srcs

    return ".", srcs

def _starlark_proto_library_impl(ctx):
    proto_source_root, srcs = _resolve_srcs(
        srcs = ctx.files.srcs,
        strip_import_prefix = _absolute_strip_import_prefix(
            label = ctx.label,
            strip_import_prefix = _string_value(ctx.attr.strip_import_prefix),
        ),
        import_prefix = _string_value(ctx.attr.import_prefix),
    )

    # _virtual_imports
    return [
        StarlarkProtoInfo(),
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
            providers = [StarlarkProtoInfo],
            doc = " ".join([
                "The list of other `proto_library` rules that the target",
                "depends upon. A `proto_library` may only depend on other",
                "`proto_library` targets. It may not depend on",
                "language-specific libraries.",
            ]),
        ),
        "exports": attr.label_list(
            mandatory = False,
            providers = [StarlarkProtoInfo],
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
)
