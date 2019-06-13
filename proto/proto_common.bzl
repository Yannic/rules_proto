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

"""Utilities for Protocol Buffers support in Starlark."""

load("//proto/private:labels.bzl", _TOOLCHAIN_TYPE = "TOOLCHAIN_TYPE")

# TODO(yannic): Reorganize code.

def _proto_info(target):
    if ProtoInfo not in target:
        name = target.label.name
        fail("Required provider ProtoInfo missing from target {}".format(name))
    return target[ProtoInfo]

def _file_path(proto_info, file):
    proto_source_root = proto_info.proto_source_root

    if "." == proto_source_root:
        # File is in local (main) workspace,
        # {proto_source_root,import_prefix,strip_import_prefix} not defined.
        return file.path

    # |file.path| is of form <proto_source_root>/<proto_path>.
    offset = len(proto_source_root) + 1
    return file.path[offset:]

def _direct_sources(proto_info):
    return [_file_path(proto_info, src) for src in proto_info.direct_sources]

def _descriptors(proto_info):
    return [file.path for file in proto_info.transitive_descriptor_sets]

def _create_outputs(actions, srcs, output_name):
    return [actions.declare_file(f) for src in srcs for f in output_name(src)]

def _language_out(language, protoc_plugin):
    if language:
        if protoc_plugin:
            fail("Only one of {language,protoc_plugin} must be defined.")
        return language, None

    if not protoc_plugin:
        fail("One of {language,protoc_plugin} must be defined.")

    # TODO(yannic): Deduce language from plugin name.
    fail("Not implemented: protoc_plugin")
    language = None

    return language, protoc_plugin.path

def _lang_proto_aspect_impl(
        actions,
        toolchain,
        flavor,
        target,
        get_generator_options,
        get_output_files,
        get_generator_options_params = None,
        language = None,
        protoc_plugin = None):
    """An abstract aspect implementation that generates source files from
    `proto_library` targets.

    Args:
      actions: The ctx.actions object, used to register the actions for the
          output files.
      toolchain: ...
      flavor: The flavor that is generated (e.g. C++, Java, Closure).
          Used to generate a nicer progress message.

      get_generator_options: A function that returns the options for the protoc
          plugin as string. Takes |get_generator_options_params| as parameter.
      get_generator_options_params: Optional. Parameter object passed to
          |get_generator_options|. Defaults to None.
      get_output_files: A function that returns a sequence of path of files
          generated for the passed input file. Takes the path of a single proto
          file as parameter, and returns a non-empty sequence of files that
          protoc will generate.
          There is no guarantee that the input file exists on disc.

      language: The output language to generate (e.g. cpp, java, js, ...), if
          the generator is part of protoc (i.e. not a plugin). Must be defined
          iff |plugin| is not defined.
      protoc_plugin: The protoc plugin that generates the output files.
          Must be defined iff |language| is not defined.

      target: The target this aspect is applied on.

    Returns:
      A sequence of generated files.
    """

    proto_info = _proto_info(target)

    direct_sources = _direct_sources(proto_info)
    descriptors = _descriptors(proto_info)
    outputs = _create_outputs(actions, direct_sources, get_output_files)

    args = actions.args()

    path_seperator = toolchain.descriptor_set_path_seperator
    args.add("--descriptor_set_in={}".format(path_seperator.join(descriptors)))

    lang, plugin = _language_out(language, protoc_plugin)
    if plugin:
        args.add(plugin)

    # TODO(yannic): Figure out if there is a better way to get the current
    #     output root.
    dummy_file = actions.declare_file("dummy.txt".format(target.label))
    actions.write(
        output = dummy_file,
        content = "",
    )

    lang_out = "--{language}_out={options}:{root}".format(
        language = language,
        options = get_generator_options(get_generator_options_params),
        root = dummy_file.path[:-10],
    )
    args.add(lang_out)

    args.add_all(direct_sources)

    plugin_files = []
    if protoc_plugin:
        fail("Not implemented: protoc_plugin files")

    actions.run(
        inputs = depset(plugin_files, transitive = [proto_info.transitive_descriptor_sets]),
        outputs = outputs,
        executable = toolchain.protoc.executable,
        arguments = [args],
        mnemonic = "StarlarkGenProto",
        # Inspired by https://github.com/bazelbuild/bazel/blob/2419cb3d7d8b5dd8f1a8bad7b57760d276730c4d/src/main/java/com/google/devtools/build/lib/rules/proto/ProtoCompileActionBuilder.java#L236
        progress_message = "Generating {flavor} proto_library {label}".format(
            flavor = flavor,
            label = str(target.label),
        ),
    )

    return depset(outputs)

def _lang_proto_aspect(
        implementation,
        attrs = {},
        required_aspect_providers = [],
        provides = [],
        fragments = [],
        host_fragments = [],
        toolchains = [],
        doc = ""):
    """TODO(yannic): Add documentation.

    See https://docs.bazel.build/versions/master/skylark/lib/globals.html#aspect
    """

    all_toolchains = [toolchain for toolchain in toolchains]
    if _TOOLCHAIN_TYPE not in toolchains:
        all_toolchains.append(_TOOLCHAIN_TYPE)

    return aspect(
        implementation = implementation,
        attr_aspects = [
            "deps",
        ],
        attrs = attrs,
        required_aspect_providers = required_aspect_providers,
        provides = provides,
        fragments = fragments,
        host_fragments = host_fragments,
        toolchains = all_toolchains,
        doc = doc,
    )

# Properties starting with `experimental_` are considered experimental and might
# change at any time.
proto_common = struct(
    TOOLCHAIN_TYPE = _TOOLCHAIN_TYPE,
    lang_proto_aspect_impl = _lang_proto_aspect_impl,
    lang_proto_aspect = _lang_proto_aspect,
)
