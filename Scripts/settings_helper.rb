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

gem 'xcodeproj'
require 'xcodeproj'

def append_to_build_settings(target, mode, setting, value)
    if target.build_settings(mode)[setting].kind_of?(Array)
        target.build_settings(mode)[setting].push(value)
    else
        target.build_settings(mode)[setting] = value
    end
end

def append_to_build_setting_all_modes(target, setting, value)
    target.build_configuration_list.build_configurations.each do |configuration|
      append_to_build_settings(target,configuration.name, setting, value)
    end
end

def fix_build_settings_of_target(target, headers_path, library_path, linked_libraries)
    append_to_build_setting_all_modes(target, 'HEADER_SEARCH_PATHS', headers_path)
    append_to_build_setting_all_modes(target, 'LIBRARY_SEARCH_PATHS', library_path)
    linked_libraries.each do |linked_library|
      append_to_build_setting_all_modes(target, 'OTHER_LDFLAGS','-l' + linked_library)
    end
end
