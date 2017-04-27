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

client_project_file = ARGV[0]
client_target = "ClientSide"
resources_dirs = ['ClientSide/Views','ClientSide/public','ClientSide/.build']
client_project = Xcodeproj::Project.open(client_project_file)
client_main_group = client_project.main_group

target_to_fix = (client_project.targets.select { |target| target.name == client_target }).first;
tests_group = client_project.main_group["KituraiOS"]

copy_build_phase = client_project.new(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase)
copy_build_phase.symbol_dst_subfolder_spec = :frameworks
target_to_fix.build_phases << copy_build_phase

['ClientSide/public'].each { |dir|
    file_reference = Xcodeproj::Project::Object::FileReferencesFactory.new_reference(client_main_group, dir ,:project)
    build_file = copy_build_phase.add_file_reference(file_reference)
    build_file.settings = { 'ATTRIBUTES' => ['CodeSignOnCopy', 'RemoveHeadersOnCopy'] }
}

client_project.save
