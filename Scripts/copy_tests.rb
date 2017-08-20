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
test_target = "ClientSideTests"
test_source_dir = ARGV[1]
test_destination_dir = ARGV[2]
client_project = Xcodeproj::Project.open(client_project_file)

target_to_fix = (client_project.targets.select { |target| target.name == test_target }).first;
tests_group = client_project.main_group["KituraiOSTests"]

Dir.foreach(test_source_dir) do |item|
    next if not item.include? "Test"
    next if not client_project["KituraiOSTests"].find_file_by_path(item) === nil
    #full_path = Pathname.new(File.expand_path(item))
    full_path = test_source_dir + "/" + item
    destionation = Pathname.new(File.expand_path(test_destination_dir + "/" + item))
    FileUtils.cp(full_path, destionation)
    file = client_project["KituraiOSTests"].new_file(destionation)
    target_to_fix.add_file_references([file])
end

client_project.save
