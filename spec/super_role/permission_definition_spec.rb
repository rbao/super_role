require 'spec_helper'

describe SuperRole::PermissionDefinition, :focus do
  let(:definition) { SuperRole::PermissionDefinition.new(['Project', 'Organization']) }

  describe '#actions' do
    subject { definition.actions(actions) }

    let(:actions) { ['a1', 'a2'] }
    let(:a1_project) { Permission.new(action: 'a1', resource_type: 'Project') }
    let(:a2_project) { Permission.new(action: 'a2', resource_type: 'Project') }
    let(:a1_organization) { Permission.new(action: 'a1', resource_type: 'Organization') }
    let(:a2_organization) { Permission.new(action: 'a2', resource_type: 'Organization') }

    it 'should add in permissions for each actions and resouce_types' do
    	expect { subject }.to change { definition.permissions.count }.by 4
    	definition.permissions.should match_array [a1_project, a2_project, a1_organization, a2_organization]
    end
  end
end