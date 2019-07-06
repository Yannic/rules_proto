# Protobuf Rules for Bazel

This repository contains Starlark implementation of Protobuf rules in Bazel.

For the list of Proto rules, see the Bazel
[documentation](https://docs.bazel.build/versions/master/be/overview.html).

## Getting Started

There is no need to use rules from this repository just yet. If you want to use
rules\_proto anyway, add the following to your WORKSPACE file:

```
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "build_bazel_rules_proto",
    urls = ["https://github.com/Yannic/rules_proto/archive/TODO"],
    sha256 = "TODO",
)
load("//proto:repositories.bzl", "rules_proto_dependencies")
load("//proto:repositories.bzl", "rules_proto_toolchains")
rules_proto_dependencies()
rules_proto_toolchains()
```

Then, in your BUILD files, import and use the rules:

```
load("@build_bazel_rules_proto//proto:defs.bzl", "proto_library")

proto_library(
    ...
)
```

## Migration Tools

In the future, this repository will also contain tools to migrate your project
for Bazel incompatible changes.

## Contributing

Bazel and rules\_proto are the work of many contributors. We appreciate your help!

To contribute, please read the contribution guidelines:
[CONTRIBUTING.md](https://github.com/Yannic/rules_proto/blob/master/CONTRIBUTING.md).

Note that the rules\_proto use the GitHub issue tracker for bug reports and
feature requests only.

For asking questions see:

* [Stack Overflow](https://stackoverflow.com/questions/tagged/bazel)
* [rules_proto mailing list](https://groups.google.com/forum/#!forum/proto-bazel-discuss)
* Slack channel `#proto` on [slack.bazel.build](https://slack.bazel.build)
