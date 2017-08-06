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

def append_to_build_settings(target,mode,setting,value)
    if target.build_settings(mode)[setting].kind_of?(Array)
        target.build_settings(mode)[setting].push(value)
    else
        target.build_settings(mode)[setting] = value
    end
end

def append_to_build_setting_all_modes(target,setting,value)
    append_to_build_settings(target,"Release",setting,value)
    append_to_build_settings(target,"Debug",setting,value)
end

def fix_build_settings_of_target(target, headers_path, library_path)
    append_to_build_setting_all_modes(target,"HEADER_SEARCH_PATHS",headers_path)
    append_to_build_setting_all_modes(target,"OTHER_LDFLAGS","-lz")
    append_to_build_setting_all_modes(target,"LIBRARY_SEARCH_PATHS",library_path)
end

def fix_server_project(server_project, main_module, kitura_net, library_file_path, headers_path, library_path)
    main_target = (server_project.targets.select { |target| target.name == main_module }).first;
    main_target.remove_from_project

    main_product = (server_project.products.select { |product| product.path == main_module }).first;
    main_product.remove_from_project

    kitura_net_target = (server_project.targets.select { |target| target.name == kitura_net }).first;

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

def add_frameworks_to_project(source_project, destination_project_build_phase, destionation_project_embed_frameworks_build_phase, destionation_project_framework_group)
    frameworks_to_add_references = []
    source_project.products.each {|p| frameworks_to_add_references.push(p) if p.path.include? 'framework'}

    destination_project_frameworks = destination_project_build_phase.file_display_names
    frameworks_to_add_references.each do |f|
        if destination_project_frameworks.include? f.display_name
          puts f.display_name + "already exist in destination project"
          next
        end

        file_reference = Xcodeproj::Project::Object::FileReferencesFactory.new_reference(destionation_project_framework_group, f.path,:built_products)
        build_file = destionation_project_embed_frameworks_build_phase.add_file_reference(file_reference)
        destination_project_build_phase.add_file_reference(file_reference)
        build_file.settings = { 'ATTRIBUTES' => ['CodeSignOnCopy', 'RemoveHeadersOnCopy'] }
    end
end

def create_framework_build_phase(project, target_name_to_fix)
    target_to_fix = (project.targets.select { |target| target.name == target_name_to_fix }).first;

    framework_group = project.frameworks_group
    framework_build_phase = target_to_fix.frameworks_build_phase

    embed_frameworks_build_phase = target_to_fix.build_phases.find {|build_phase| build_phase.to_s == 'Embed Frameworks'}
    if embed_frameworks_build_phase == nil
        embed_frameworks_build_phase = project.new(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase)
        embed_frameworks_build_phase.name = 'Embed Frameworks'
        embed_frameworks_build_phase.symbol_dst_subfolder_spec = :frameworks
        target_to_fix.build_phases << embed_frameworks_build_phase
    end
    return framework_build_phase, embed_frameworks_build_phase, framework_group
end

def fix_client_project(client_project, server_project, shared_server_client_project, client_target_name_to_fix, shared_server_client_name_to_fix)
    #Add server frameworks to client
    client_framework_build_phase, client_embed_frameworks_build_phase, client_framework_group =  create_framework_build_phase(client_project, client_target_name_to_fix)
    shared_framework_build_phase, shared_embed_frameworks_build_phase, shared_framework_group =  create_framework_build_phase(shared_server_client_project, shared_server_client_name_to_fix)

    add_frameworks_to_project(server_project, client_framework_build_phase, client_embed_frameworks_build_phase, client_framework_group)
    add_frameworks_to_project(shared_server_client_project, client_framework_build_phase, client_embed_frameworks_build_phase, client_framework_group)
    add_frameworks_to_project(server_project, shared_framework_build_phase, shared_embed_frameworks_build_phase, shared_framework_group)
end

server_project_file = ARGV[0];
main_module = ARGV[1];
client_project_file = ARGV[2];
shared_server_client_project_file = ARGV[3];
number_of_bits = ARGV[4];

library_file_path = "../iOSStaticLibraries/Curl/lib/libcurl.a"
headers_path = "$(PROJECT_DIR)/../iOSStaticLibraries/Curl/include" + "-" + number_of_bits
library_path= "$(PROJECT_DIR)/../iOSStaticLibraries/Curl/lib"
kitura_net = "KituraNet"

server_project = Xcodeproj::Project.open(server_project_file);
client_project = Xcodeproj::Project.open(client_project_file);
shared_server_client_project = Xcodeproj::Project.open(shared_server_client_project_file);

fix_server_project(server_project, main_module, kitura_net, library_file_path, headers_path, library_path)
fix_client_project(client_project, server_project, shared_server_client_project, "ClientSide", "SharedServerClient")

server_project.save;
client_project.save;
shared_server_client_project.save;
