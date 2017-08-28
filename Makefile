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

ifndef KITURA_IOS_BUILD_SCRIPTS_DIR
KITURA_IOS_BUILD_SCRIPTS_DIR = Scripts
endif

all: prepareXcode

prepareXcodeAll: iOSStaticLibraries/Curl ServerSide/Package.swift ClientSide/ClientSide.xcodeproj
	rm -f ServerSide/.build/checkouts/Kitura-net.git--*/Sources/CHTTPParser/include/module.modulemap
	@echo --- Generating ServerSide Xcode project
	cd ServerSide && swift package generate-xcodeproj
	cp ServerSide/*.xcodeproj/GeneratedModuleMap/CHTTPParser/module.modulemap \
		ServerSide/.build/checkouts/Kitura-net.git--*/Sources/CHTTPParser/include/
# regenerate xcode project with the generated module map
	cd ServerSide && swift package generate-xcodeproj
	@echo ——- Fixing Xcode projects
	-${KITURA_IOS_BUILD_SCRIPTS_DIR}/fixXcodeProjects.sh ${NUMBER_OF_BITS}
	@echo ——- Creating EndToEnd Xcode workspace
	rm -rf EndToEnd.xcworkspace
	-ruby ${KITURA_IOS_BUILD_SCRIPTS_DIR}/create_xcode_workspace.rb ClientSide/*.xcodeproj ServerSide/*.xcodeproj SharedServerClient/*.xcodeproj

prepareXcode32:
	make NUMBER_OF_BITS="32" prepareXcodeAll

prepareXcode:
	make NUMBER_OF_BITS="64" prepareXcodeAll

openXcode32: prepareXcode32
	open EndToEnd.xcworkspace

openXcode: prepareXcode
	open EndToEnd.xcworkspace

ServerSide/Package.swift:
	@echo --- Fetching submodules
	git submodule init
	git submodule update --remote --merge

ClientSide/ClientSide.xcodeproj:
	@echo --- Fetching submodules
	git submodule init
	git submodule update --remote --merge

iOSStaticLibraries/Curl:
	@echo "Please download a curl source, uncompress it and run Builder/Scripts/buildCurlStaticLibrary.sh <the uncompressed curl directory>"
	@echo "You can download curl source from https://curl.haxx.se/download/"
	exit 1

.PHONY: prepareXcode prepareXcode32 openXcode openXcode32
