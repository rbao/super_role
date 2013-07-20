require 'spec_helper'

describe SuperRole::PermissionHierarchyNode do
  
  describe '#initialize' do
    subject { SuperRole::PermissionHierarchyNode.new(resource_type, options) }
    let(:resource_type) { 'Organization' }
    let!(:show_organization) { Permission.create!(action: 'show', resource_type: 'Organization') }
    let!(:update_organization) { Permission.create!(action: 'update', resource_type: 'Organization') }
    let!(:destroy_organization) { Permission.create!(action: 'destroy', resource_type: 'Organization') }
    
    context 'with no options' do
      let(:options) { {} }
      
      it 'should add all the actions of the resource_type to the node' do
        subject.node_permissions.should match_array [show_organization, update_organization, destroy_organization]
      end

      its(:children) { should eq [] }
      its(:parent) { should be_nil }
      its(:resource_type) { should eq 'Organization' }
    end

    context 'with :only option' do
      let(:options) { { only: :update } }
      
      it 'should add only the specified actions' do
        subject.node_permissions.should match_array [update_organization]
      end
    end

    context 'with :except option' do
      let(:options) { { except: ['update'] } }
      
      it 'should add all the actions except of the one specified' do
        subject.node_permissions.should match_array [show_organization, destroy_organization]
      end 
    end

    context 'with :parent option' do
      let(:parent) { SuperRole::PermissionHierarchyNode.new('Government') }
      let(:options) { { parent: parent} }

      its(:parent) { should eq parent }
      its(:parent_foreign_key) { should eq 'government_id' }
    end

    context 'with :foreign_key option' do
      let(:parent) { SuperRole::PermissionHierarchyNode.new('Government') }
      let(:options) { { foreign_key: 'g_id'} }

      it 'should set the parent to the given one' do
        subject.parent_foreign_key.should eq 'g_id'
      end
    end

  end
  
  describe '#owns' do
    let(:organization_node) { SuperRole::PermissionHierarchyNode.new('Organization') }

    context 'with no block given' do
      it 'should add the given resource_type as a child node' do
        expect do
          organization_node.owns('Project')  
        end.to change { organization_node.children.count }.by(1)
      end

      it 'should create a child node with the given resource_type' do
        organization_node.owns('Project')
        organization_node.children.first.resource_type.should eq 'Project'
      end
    end

    context 'with a block which creates grand children' do
      it 'should add the given resource_type as children' do
        expect do
          organization_node.owns('Project') do
            owns('ProjectProfile')
            owns('Ticket')
          end
        end.to change { organization_node.children.count }.by(1)
      end

      it 'should also add the grand children to the child' do
        organization_node.owns('Project') do
          owns('ProjectProfile')
          owns('Ticket')
        end

        organization_node.children.first.children.map(&:resource_type).should match_array ['ProjectProfile', 'Ticket']
      end
    end
  end

  describe '#children_permissions' do
    subject { organization_node.children_permissions }
    
    let!(:show_project) { Permission.create!(action: 'show', resource_type: 'Project') }
    let!(:show_project_profile) { Permission.create!(action: 'show', resource_type: 'ProjectProfile') }
    let!(:show_ticket) { Permission.create!(action: 'show', resource_type: 'Ticket') }
    
    let(:organization_node) { SuperRole::PermissionHierarchyNode.new('Organization') }
    let(:project_node) { SuperRole::PermissionHierarchyNode.new('Project') }
    let(:project_profile) { SuperRole::PermissionHierarchyNode.new('ProjectProfile') }
    let(:ticket_node) { SuperRole::PermissionHierarchyNode.new('Ticket') }

    before do
      project_node.children << project_profile
      project_node.children << ticket_node
      organization_node.children << project_node
    end

    it 'should include all the permissions of the children' do
      subject.should match_array [show_project, show_project_profile, show_ticket]
    end
  end

  describe '#find_child', :focus do
    subject { organization_node.find_child(show_project_profile) }
    
    let!(:show_project) { Permission.create!(action: 'show', resource_type: 'Project') }
    let!(:show_project_profile) { Permission.create!(action: 'show', resource_type: 'ProjectProfile') }
    let!(:show_ticket) { Permission.create!(action: 'show', resource_type: 'Ticket') }
    
    let(:organization_node) { SuperRole::PermissionHierarchyNode.new('Organization') }
    let(:project_node) { SuperRole::PermissionHierarchyNode.new('Project') }
    let(:proejct_profile_node) { SuperRole::PermissionHierarchyNode.new('ProjectProfile') }
    let(:ticket_node) { SuperRole::PermissionHierarchyNode.new('Ticket') }
    
    before do
      project_node.children << proejct_profile_node
      project_node.children << ticket_node
      organization_node.children << project_node
    end

    it 'should return the child node that have the given permission' do
      should eq proejct_profile_node
    end
  end

  describe '#possible_ids_for_ancestor_resource', :focus do
    subject { ticket_node.possible_ids_for_ancestor_resource(ancestor_resource) }

    let(:government_node) { SuperRole::PermissionHierarchyNode.new('Government') }
    let(:organization_node) { SuperRole::PermissionHierarchyNode.new('Organization', parent: government_node) }
    let(:project_node) { SuperRole::PermissionHierarchyNode.new('Project', parent: organization_node) }
    let(:proejct_profile_node) { SuperRole::PermissionHierarchyNode.new('ProjectProfile', parent: project_node) }
    let(:ticket_node) { SuperRole::PermissionHierarchyNode.new('Ticket', parent: project_node) }

    let!(:government) { Government.create! }
    let!(:organization1) { Organization.create!(government_id: government.id) }
    let!(:project1) { Project.create!(organization_id: organization1.id) }
    let!(:project2) { Project.create!(organization_id: organization1.id) }
    let!(:project_profile) { ProjectProfile.create!(project_id: project1.id) }
    let!(:ticket1) { Ticket.create!(proj_id: project1.id) }
    let!(:ticket12) { Ticket.create!(proj_id: project1.id) }
    let!(:ticket2) { Ticket.create!(proj_id: project2.id) }

    context 'when given ancestor_resource is the same type of the node it self' do
      let(:ancestor_resource) { ticket1 }
      it('should return ancestor_resource.id') { should match_array [ancestor_resource.id] }
    end

    context 'when given ancestor_resource is the parent of node' do
      let(:ancestor_resource) { project1 }
      it 'should return all the resources which belongs_to the ancestor_resource' do
        should match_array [ticket1.id, ticket12.id]
      end
    end

  end
  
end
