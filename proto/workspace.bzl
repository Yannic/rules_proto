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
load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")

def proto_import_dependencies():
    # TODO(yannic): Add options to skip / override dependencies.

    # TODO(yannic): Define dependencies in seperate file.

    _http_archive(
        name = "bazel_skylib",
        sha256 = "2ef429f5d7ce7111263289644d233707dba35e39696377ebab8b0bc701f7818e",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/0.8.0/bazel-skylib.0.8.0.tar.gz",
        ],
    )

    _http_archive(
        name = "com_google_protobuf",
        sha256 = "03d2e5ef101aee4c2f6ddcf145d2a04926b9c19e7086944df3842b1b8502b783",
        strip_prefix = "protobuf-3.8.0",
        urls = [
            "https://mirror.bazel.build/github.com/google/protobuf/archive/v3.8.0.tar.gz",
            "https://github.com/protocolbuffers/protobuf/archive/v3.8.0.tar.gz",
        ],
    )

    # TODO(yannic): Switch to mirror that contains build files.
    _http_archive(
        name = "zlib",
        build_file = "//third_party:zlib.BUILD.bazel",
        sha256 = "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1",
        strip_prefix = "zlib-1.2.11",
        urls = [
            "https://zlib.net/zlib-1.2.11.tar.gz",
        ],
    )

def proto_register_toolchains():
    native.register_toolchains(
        _DEFAULT_TOOLCHAIN,
    )
