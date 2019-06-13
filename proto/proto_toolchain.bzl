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

load("//proto/private:descriptor_set_path_seperator.bzl", _DescriptorSetPathSeperatorInfo = "DescriptorSetPathSeperatorInfo")
load("//proto/private:labels.bzl", _DESCRIPTOR_SET_PATH_SEPERATOR = "DESCRIPTOR_SET_PATH_SEPERATOR")

def get_path_seperator_info(ctx):
    descriptor_set_path_seperator = ctx.attr._descriptor_set_path_seperator
    return descriptor_set_path_seperator[_DescriptorSetPathSeperatorInfo]

def _proto_toolchain_impl(ctx):
    path_seperator_info = get_path_seperator_info(ctx)

    return [
        platform_common.ToolchainInfo(
            protoc = ctx.attr.protoc.files_to_run,
            descriptor_set_path_seperator = path_seperator_info.path_seperator,
        ),
    ]

proto_toolchain = rule(
    implementation = _proto_toolchain_impl,
    attrs = {
        "protoc": attr.label(
            mandatory = True,
            executable = True,
            cfg = "host",
        ),
        "_descriptor_set_path_seperator": attr.label(
            mandatory = False,
            default = _DESCRIPTOR_SET_PATH_SEPERATOR,
            providers = [
                _DescriptorSetPathSeperatorInfo,
            ],
        ),
    },
    provides = [platform_common.ToolchainInfo],
)
