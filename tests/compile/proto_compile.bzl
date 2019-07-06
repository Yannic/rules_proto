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

load("//proto:proto_common.bzl", "proto_common")

_ProtoCompileInfo = provider()

def _cpp_output_name(src):
    base = src[:-6]
    return [
        "{}.pb.h".format(base),
        "{}.pb.cc".format(base),
    ]

def _cpp_options(params):
    return ""

def _proto_compile_aspect_impl(target, ctx):
    files = []
    for dep in ctx.rule.attr.deps:
        files.append(dep[_ProtoCompileInfo].files)

    cpp = proto_common.lang_proto_aspect_impl(
        actions = ctx.actions,
        toolchain = ctx.toolchains[proto_common.TOOLCHAIN_TYPE],
        flavor = "C++",
        get_generator_options = _cpp_options,
        get_output_files = _cpp_output_name,
        language = "internal_rules_proto",
        target = target,
    )
    files.append(cpp)

    return [
        _ProtoCompileInfo(
            files = depset([], transitive = files),
        ),
    ]

_proto_compile_aspect = proto_common.lang_proto_aspect(
    implementation = _proto_compile_aspect_impl,
    provides = [
        _ProtoCompileInfo,
    ],
)

def _proto_compile_impl(ctx):
    return [
        DefaultInfo(
            files = ctx.attr.deps[0][_ProtoCompileInfo].files,
        ),
    ]

proto_compile = rule(
    attrs = {
        "deps": attr.label_list(
            mandatory = True,
            providers = [ProtoInfo, _ProtoCompileInfo],
            aspects = [_proto_compile_aspect],
        ),
    },
    implementation = _proto_compile_impl,
)
