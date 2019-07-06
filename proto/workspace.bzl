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

load("//proto:repositories.bzl", "rules_proto_dependencies")
load("//proto:repositories.bzl", "rules_proto_toolchains")

_DEPRECATED_REPOSITORY_RULE_MESSAGE = " ".join([
    "{old_rule}() is deprecated.",
    "Please import @build_bazel_rules_proto//proto:repositories.bzl and use {new_rule}().",
    "See https://github.com/Yannic/rules_proto/issues/6",
])

def proto_import_dependencies():
    print(_DEPRECATED_REPOSITORY_RULE_MESSAGE.format(
        old_rule = "proto_import_dependencies",
        new_rule = "rules_proto_dependencies",
    ))

    rules_proto_dependencies()

def proto_register_toolchains():
    print(_DEPRECATED_REPOSITORY_RULE_MESSAGE.format(
        old_rule = "proto_register_toolchains",
        new_rule = "rules_proto_toolchains",
    ))

    rules_proto_toolchains()
