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
require_relative 'frameworks_helper'
require_relative 'constants'
require_relative 'libraries'

def fix_client_project(client_project, server_project, shared_server_client_project,
                       libraries)
  client_target_name_to_fix = Constants::CLIENT_SIDE_MAIN_TARGET
  client_framework_build_phase, client_embed_frameworks_build_phase, client_framework_group =
      create_framework_build_phase(client_project, client_target_name_to_fix)

  add_frameworks_to_project(server_project, client_framework_build_phase,
                            client_embed_frameworks_build_phase, client_framework_group)
  add_frameworks_to_project(shared_server_client_project, client_framework_build_phase,
                            client_embed_frameworks_build_phase, client_framework_group)

  client_target_to_fix = get_first_target_by_name(client_project, client_target_name_to_fix)
  fix_build_settings_of_target(client_target_to_fix, libraries.headers_path, libraries.library_path)
end

server_project_file = ARGV[0];
client_project_file = ARGV[1];
shared_server_client_project_file = ARGV[2];
number_of_bits = ARGV[3];

server_project = Xcodeproj::Project.open(server_project_file);
client_project = Xcodeproj::Project.open(client_project_file);
shared_server_client_project = Xcodeproj::Project.open(shared_server_client_project_file);

fix_client_project(client_project, server_project, shared_server_client_project,
                   Libraries.new(number_of_bits))

client_project.save;
