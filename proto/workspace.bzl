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

load("//proto/private:labels.bzl", _DEFAULT_TOOLCHAIN = "DEFAULT_TOOLCHAIN")
load("//proto/private:labels.bzl", _ZLIB_BUILD_FILE = "ZLIB_BUILD_FILE")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def proto_import_dependencies():
    # TODO(yannic): Add options to skip / override dependencies.

    # TODO(yannic): Define dependencies in seperate file.

    http_archive(
        name = "bazel_skylib",
        sha256 = "2ef429f5d7ce7111263289644d233707dba35e39696377ebab8b0bc701f7818e",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/0.8.0/bazel-skylib.0.8.0.tar.gz",
        ],
    )

    http_archive(
        name = "com_google_protobuf",
        sha256 = "03d2e5ef101aee4c2f6ddcf145d2a04926b9c19e7086944df3842b1b8502b783",
        strip_prefix = "protobuf-3.8.0",
        urls = [
            "https://mirror.bazel.build/github.com/google/protobuf/archive/v3.8.0.tar.gz",
            "https://github.com/protocolbuffers/protobuf/archive/v3.8.0.tar.gz",
        ],
    )

    http_archive(
        name = "zlib",
        sha256 = "831e1be9ea79dc8cc427123531f926f1df514927cddb39b05245bd24632340bc",
        strip_prefix = "org_zlib-394a8944cfed3568242196176779df8333af8596",
        urls = [
            "https://github.com/bazel-packages/org_zlib/archive/394a8944cfed3568242196176779df8333af8596.tar.gz",
        ],
    )

def proto_register_toolchains():
    native.register_toolchains(
        _DEFAULT_TOOLCHAIN,
    )
