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

class Constants
  LIBRARY_FILE_PATH = "../iOSStaticLibraries/Curl/lib/libcurl.a"
  LIBRARY_PATH  = "$(PROJECT_DIR)/../iOSStaticLibraries/Curl/lib"
  KITURA_NET = "KituraNet"
  CLIENT_SIDE_MAIN_TARGET = "ClientSide"
  SHARED_SERVER_CLIENT_SIDE_MAIN_TARGET = "SharedServerClient"

  def self.get_headers_path(number_of_bits)
    "$(PROJECT_DIR)/../iOSStaticLibraries/Curl/include" + "-" + number_of_bits
  end
end
