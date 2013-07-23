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

    context 'with :polymorphic option and :foreign_key option' do
      let(:parent) { SuperRole::PermissionHierarchyNode.new('Organization') }
      let(:options) { { polymorphic: true, foreign_key: 'owner_id'} }

      it 'should set the polymorphic attribute' do
        subject.polymorphic.should be_true
      end
    end

    context 'with :polymorphic option but no :foreign_key option' do
      let(:parent) { SuperRole::PermissionHierarchyNode.new('Organization') }
      let(:options) { { polymorphic: true, foreign_key: 'owner_id'} }

      it 'should raise error' do
        pending
      end
    end

  end
  
  describe '#owns' do
    let(:organization_node) { SuperRole::PermissionHierarchyNode.new('Organization') }

    context 'with no block given' do
      it 'should add the given resource_type as a child node' do
        expect do
          organization_node.owns('Employee')  
        end.to change { organization_node.children.count }.by(1)
      end

      it 'should create a child node with the given resource_type' do
        organization_node.owns('Employee')
        organization_node.children.first.resource_type.should eq 'Employee'
      end
    end

    context 'with a block which creates grand children' do
      it 'should add the given resource_type as children' do
        expect do
          organization_node.owns('Employee') do
            owns('EmployeeProfile')
            owns('EmployeeStatus')
          end
        end.to change { organization_node.children.count }.by(1)
      end

      it 'should also add the grand children to the child' do
        organization_node.owns('Employee') do
          owns('EmployeeProfile')
          owns('EmployeeStatus')
        end

        organization_node.children.first.children.map(&:resource_type).should match_array ['EmployeeProfile', 'EmployeeStatus']
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

  describe '#find_child' do
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

  describe '#possible_resources_for_ancestor_resource' do
    subject { ticket_node.possible_resources_for_ancestor_resource(ancestor_resource) }
    
    context 'when ancestor_resource is the same type of the node it self' do
      setup_permission_hierarchy_for_nil
      let(:ancestor_resource) { ticket1 }

      it('should return ancestor_resource') { should match_array [ancestor_resource] }
    end

    context 'when ancestor_resource is the parent of the node' do
      setup_permission_hierarchy_for_nil
      let(:ancestor_resource) { project1 }
      
      it 'should return all the resources that belongs_to the ancestor_resource' do
        should match_array [ticket1, ticket2]
      end
    end

    context 'when ancestor_resource is the grand parent of the node' do
      setup_permission_hierarchy_for_nil
      let(:ancestor_resource) { organization1 }
      
      it 'should return all the resources that eventually belongs to the grand parent' do
        should match_array [ticket1, ticket2, ticket3]
      end
    end

    context 'when ancestor_resource is an ancestor of the node' do
      setup_permission_hierarchy_for_nil
      let(:ancestor_resource) { government1 }
      
      it 'should return all the resources that eventually belongs to that ancestor' do
        should match_array [ticket1, ticket2, ticket3, ticket4]
      end
    end

    context 'when ancestor_resource is nil' do
      setup_permission_hierarchy_for_nil
      let(:ancestor_resource) { nil }
      
      it 'should return all existing resources' do
        should match_array [ticket1, ticket2, ticket3, ticket4, ticket5]
      end
    end

    context 'when ancestor_resource is actually an descendant resource' do
      subject { project_node.possible_resources_for_ancestor_resource(ancestor_resource) }
      setup_permission_hierarchy_for_nil
      let(:ancestor_resource) { ticket1 }

      it { should match_array [] }
    end

    context 'when ancestor_resource is nil and nil_node is the root of the hierarchy' do
      subject { project_node.possible_resources_for_ancestor_resource(ancestor_resource) }
      setup_permission_hierarchy_for_nil
      let(:ancestor_resource) { nil }
      
      it { should match_array [project1, project2, project3, project4] }
    end

    context 'when ancestor_resource is nil but nil_node is not the root of the hierarchy' do
      subject { project_node.possible_resources_for_ancestor_resource(ancestor_resource) }
      setup_permission_hierarchy_for_government
      let(:ancestor_resource) { nil }
      
      it { should match_array [] }
    end

    context 'when ancestor_resource does not have a permission node in the hierarchy' do
      setup_permission_hierarchy_for_nil
      let(:ancestor_resource) { user }

      it { should match_array [] }
    end
  end

  describe '#ancestor_resource?' do
    subject { ticket_node.ancestor_resource?(resource, target_resource) }
    setup_permission_hierarchy_for_nil

    context 'when the resource directly belongs_to target_resource' do
      let(:resource) { ticket1 }
      let(:target_resource) { project1 }

      it { should be_true }
    end

    context 'when the permission node of target_resource is the parent of the permission node of resource but
      resource does not belongs_to target_resource' do
      let(:resource) { ticket1 }
      let(:target_resource) { project2 }

      it { should be_false }
    end

    context 'when the resource belongs_to a resource that belongs_to target_resource' do
      let(:resource) { ticket1 }
      let(:target_resource) { organization1 }

      it { should be_true }
    end

    context 'when the permission node of target_resource is the grand parent of the permission node of resource but
      resource does not belongs_to a resource that belongs_to target_resource' do
      let(:resource) { ticket1 }
      let(:target_resource) { organization2 }

      it { should be_false }
    end

    context 'when the resource belongs_to a resource that eventually belongs_to target_resource' do
      let(:resource) { ticket1 }
      let(:target_resource) { government1 }

      it { should be_true }
    end

    context 'when the permission node of target_resource is the ancestor of the permission node of resource but
      resource does not belongs_to a resource that eventually belongs_to target_resource' do
      let(:resource) { ticket1 }
      let(:target_resource) { government2 }

      it { should be_false }
    end

    context 'when target_resource is actually a descendant of resource' do
      subject { project_node.ancestor_resource?(resource, target_resource) }
      let(:resource) { project1 }
      let(:target_resource) { ticket1 }

      it { should be_false }
    end

    context 'when target_resource does not have a permission node in the hierarchy' do
      let(:resource) { ticket1 }
      let(:target_resource) { user }

      it { should be_false }
    end

    context 'when target_resource is nil and resource is directly under nil which has no foreign_key', :focus do
      subject { government_node.ancestor_resource?(resource, target_resource) }
      let(:resource) { Government.new }
      let(:target_resource) { nil }

      it { should be_true }
    end
  end
  
end
