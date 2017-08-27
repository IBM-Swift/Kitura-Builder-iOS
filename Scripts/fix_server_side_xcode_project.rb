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
require_relative 'settings_helper'
require_relative 'target_helper'
require_relative 'constants'

def fix_server_project(server_project, main_module, kitura_net, library_file_path, headers_path, library_path)
    main_target = get_first_target_by_name(server_project, main_module)
    main_target.remove_from_project

    main_product = (server_project.products.select { |product| product.path == main_module }).first;
    main_product.remove_from_project

    kitura_net_target = get_first_target_by_name(server_project, kitura_net)

    server_project.targets.select { |target|
        target.build_settings('Debug').delete "SUPPORTED_PLATFORMS"
        target.build_settings('Release').delete "SUPPORTED_PLATFORMS"
    }

    #Add headers
    fix_build_settings_of_target(kitura_net_target, headers_path, library_path)

    #Add library
    build_phase = kitura_net_target.frameworks_build_phase
    framework_group = server_project.frameworks_group
    library_reference = framework_group.new_reference(library_file_path)
    build_file = build_phase.add_file_reference(library_reference)
end

server_project_file = ARGV[0];
main_module = ARGV[1];
number_of_bits = ARGV[2];

server_project = Xcodeproj::Project.open(server_project_file);
fix_server_project(server_project, main_module, Constants::KITURA_NET, Constants::LIBRARY_FILE_PATH,
                   Constants::get_headers_path(number_of_bits), Constants::LIBRARY_PATH)
server_project.save;
