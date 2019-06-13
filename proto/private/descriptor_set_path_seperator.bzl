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

DescriptorSetPathSeperatorInfo = provider(
    fields = [
        "path_seperator",
    ],
)

def _descriptor_set_path_seperator_impl(ctx):
    path_seperator = ctx.attr.path_seperator

    propagate_path_seperator = ctx.attr.propagate_path_seperator
    if "" == path_seperator:
        if not propagate_path_seperator:
            fail("One of {path_seperator,propagate_path_seperator} is required")
        info = propagate_path_seperator[DescriptorSetPathSeperatorInfo]
        path_seperator = info.path_seperator
    elif propagate_path_seperator:
        fail("Only one of {path_seperator,propagate_path_seperator} is allowed")

    return [
        DescriptorSetPathSeperatorInfo(
            path_seperator = path_seperator,
        ),
    ]

descriptor_set_path_seperator = rule(
    implementation = _descriptor_set_path_seperator_impl,
    attrs = {
        "path_seperator": attr.string(
            mandatory = False,
        ),
        "propagate_path_seperator": attr.label(
            mandatory = False,
            providers = [
                DescriptorSetPathSeperatorInfo,
            ],
        ),
    },
)
