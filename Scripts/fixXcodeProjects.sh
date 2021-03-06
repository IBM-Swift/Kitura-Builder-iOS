#!/bin/bash

# Copyright IBM Corporation 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

MAIN_DOT_SWIFT=`find ServerSide/Sources -name main.swift`
MAIN_MODULE_DIRECTORY=`dirname ${MAIN_DOT_SWIFT}`
MAIN_MODULE=`basename ${MAIN_MODULE_DIRECTORY}`

ruby ${KITURA_IOS_BUILD_SCRIPTS_DIR}/fix_server_side_xcode_project.rb ServerSide/*.xcodeproj ${MAIN_MODULE} ${1}
ruby ${KITURA_IOS_BUILD_SCRIPTS_DIR}/fix_client_side_xcode_project.rb ServerSide/*.xcodeproj ClientSide/*.xcodeproj SharedServerClient/*.xcodeproj ${1}
ruby ${KITURA_IOS_BUILD_SCRIPTS_DIR}/fix_shared_client_server_xcode_project.rb ServerSide/*.xcodeproj SharedServerClient/*.xcodeproj ${1}

ruby ${KITURA_IOS_BUILD_SCRIPTS_DIR}/copy_tests.rb ClientSide/*.xcodeproj "./ClientSideTests" "ClientSide/KituraiOSTests"
${KITURA_IOS_BUILD_SCRIPTS_DIR}/copy_resources.sh
ruby ${KITURA_IOS_BUILD_SCRIPTS_DIR}/copy_resources.rb ClientSide/*.xcodeproj
