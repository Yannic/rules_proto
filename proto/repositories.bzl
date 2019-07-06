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

load("//proto/private:dependencies.bzl", "dependencies")
load("//proto/private:labels.bzl", "DEFAULT_TOOLCHAIN")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def rules_proto_dependencies():
    for name in dependencies:
        if name in native.existing_rules():
            continue

        http_archive(
            name = name,
            **dependencies[name]
        )

def rules_proto_toolchains():
    native.register_toolchains(
        DEFAULT_TOOLCHAIN,
    )
