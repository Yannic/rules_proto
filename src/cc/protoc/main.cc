// Copyright 2019 The Rules Protobuf Authors. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include "google/protobuf/compiler/command_line_interface.h"
#include "google/protobuf/compiler/cpp/cpp_generator.h"
#include "google/protobuf/compiler/js/js_generator.h"

int main(int argc, char* argv[]) {
  google::protobuf::compiler::CommandLineInterface cli;
  cli.AllowPlugins("protoc-");

  google::protobuf::compiler::cpp::CppGenerator cpp_generator;
  cli.RegisterGenerator(
      "--internal_rules_proto_out", "--internal_rules_proto_out",
      &cpp_generator, "Deprecated. DO NOT USE.");

  google::protobuf::compiler::js::Generator js_generator;
  cli.RegisterGenerator(
      "--js_out", "--js_out", &js_generator, "Deprecated. DO NOT USE.");

  return cli.Run(argc, argv);
}
