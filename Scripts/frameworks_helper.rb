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
require_relative 'target_helper'

def get_frameworks(project)
    frameworks = []
    project.products.each do |product|
      frameworks.push(product) if product.path.include? 'framework'
    end

    frameworks
end

def add_framework_to_project(file, destination_project_build_phase,
                             destination_project_embed_frameworks_build_phase,
                             destination_project_framework_group)
        file_reference = Xcodeproj::Project::Object::FileReferencesFactory.new_reference(
          destination_project_framework_group, file.path, :built_products)

        build_file =
          destination_project_embed_frameworks_build_phase.add_file_reference(file_reference)
        destination_project_build_phase.add_file_reference(file_reference)
        build_file.settings = { 'ATTRIBUTES' => ['CodeSignOnCopy', 'RemoveHeadersOnCopy'] }
end

def add_frameworks_to_project(source_project, destination_project_build_phase,
                              destination_project_embed_frameworks_build_phase,
                              destination_project_framework_group)

    frameworks_to_add = get_frameworks(source_project)
    destination_project_frameworks = destination_project_build_phase.file_display_names

    frameworks_to_add.each do |file|
        unless destination_project_frameworks.include? file.display_name
          add_framework_to_project(file, destination_project_build_phase,
                                   destination_project_embed_frameworks_build_phase,
                                   destination_project_framework_group)
        end
    end
end

def get_embed_frameworks_build_phase(project, target_to_fix)
    embed_frameworks_build_phase = target_to_fix.build_phases.find do |build_phase|
        build_phase.to_s == 'Embed Frameworks'
    end

    if embed_frameworks_build_phase == nil
        embed_frameworks_build_phase =
          project.new(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase)
        embed_frameworks_build_phase.name = 'Embed Frameworks'
        embed_frameworks_build_phase.symbol_dst_subfolder_spec = :frameworks
        target_to_fix.build_phases << embed_frameworks_build_phase
    end

    embed_frameworks_build_phase
end

def create_framework_build_phase(project, target_name_to_fix)
    target_to_fix = get_first_target_by_name(project, target_name_to_fix)

    framework_group = project.frameworks_group
    framework_build_phase = target_to_fix.frameworks_build_phase
    embed_frameworks_build_phase = get_embed_frameworks_build_phase(project, target_to_fix)

    return framework_build_phase, embed_frameworks_build_phase, framework_group
end
