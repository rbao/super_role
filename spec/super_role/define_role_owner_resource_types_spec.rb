require 'spec_helper'

describe 'SuperRole.define_role_owner_permission_hierarchy' do
  
  describe 'one line definition' do
    let!(:update_organization) { Permission.create!(action: 'update', resource_type: 'Organization') }
    let!(:show_organization) { Permission.create!(action: 'show', resource_type: 'Organization') }
    let(:root) { SuperRole::PermissionHierarchy.find('Organization').root }

    context 'with no options' do
      subject do
        SuperRole.define_role_owner_permission_hierarchy do
          owner_resource_type 'Organization'
        end 
      end

      it 'should add a root node of itself with no parent and no children' do
        subject
        root.resource_type.should eq 'Organization'
        root.parent.should be_nil
        root.children.should eq []
      end

      it 'should add a root node which owns all actions of itself' do
        subject
        root.permissions.should include(update_organization)
        root.permissions.should include(show_organization)
      end
    end

    context 'with :only options' do
      subject do
        SuperRole.define_role_owner_permission_hierarchy do
          owner_resource_type 'Organization', only: :update
        end
      end

      it 'should add a root node which owns only the specified actions' do
        subject
        root.permissions.should include(update_organization)
        root.permissions.should_not include(show_organization)
      end
    end

    context 'with :only options' do
      subject do
        SuperRole.define_role_owner_permission_hierarchy do
          owner_resource_type 'Organization', except: :show
        end
      end

      it 'should add a root node which owns only the specified actions' do
        subject
        root.permissions.should include(update_organization)
        root.permissions.should_not include(show_organization)
      end
    end
  end

  describe 'muti-line non-nested definition' do
    subject do

      SuperRole.define_role_owner_permission_hierarchy do
        owner_resource_type Organization do
          owns Project, polymorphic: true, foreign_key: :owner_id
        end
      end

    end

    let!(:show_organization) { Permission.create!(action: 'show', resource_type: 'Organization') }
    let!(:create_project) { Permission.create!(action: 'create', resource_type: 'Project') }

    it 'should create a new permission hierarchy' do
      subject
      SuperRole::PermissionHierarchy.find(Organization).should_not be_nil
    end

    it 'should add the right children' do
      subject
      child = SuperRole::PermissionHierarchy.find(Organization).find_node(create_project)
      child.resource_type.should eq 'Project'
      child.polymorphic.should be_true
      child.parent_foreign_key.should eq 'owner_id'
    end
  end

  describe 'muti-line nested definition' do
    before do
      create_permissions_for(Organization, Project, ProjectProfile, Ticket, Employee, EmployeeStatus, EmployeeProfile)
      
      SuperRole.define_role_owner_permission_hierarchy do
        owner_resource_type Organization do
          
          owns Project, polymorphic: true, foreign_key: :owner_id do
            owns ProjectProfile, only: :update
            owns Ticket, foreign_key: :proj_id
          end

          owns Employee do
            owns EmployeeProfile, only: :update
            owns EmployeeStatus
          end
        end
      end
    end

    it 'should create a new permission hierarchy' do
      SuperRole::PermissionHierarchy.find(Organization).should_not be_nil
    end

    it 'should create the right hierarchy structure' do
      hierarchy = SuperRole::PermissionHierarchy.find(Organization)
      root = hierarchy.root

      create_project = Permission.new(action: 'create', resource_type: 'Project')
      create_project_node = hierarchy.find_node(create_project)
      create_project_node.resource_type.should eq 'Project'
      create_project_node.parent.should eq root

      create_employee = Permission.new(action: 'create', resource_type: 'Employee')
      create_employee_node = hierarchy.find_node(create_employee)
      create_employee_node.resource_type.should eq 'Employee'
      create_employee_node.parent.should eq root

      create_ticket = Permission.new(action: 'create', resource_type: 'Ticket')
      create_ticket_node = hierarchy.find_node(create_ticket)
      create_ticket_node.resource_type.should eq 'Ticket'
      create_ticket_node.parent.should eq create_project_node

      update_employee_profile = Permission.new(action: 'update', resource_type: 'EmployeeProfile')
      update_employee_profile_node = hierarchy.find_node(update_employee_profile)
      update_employee_profile_node.resource_type.should eq 'EmployeeProfile'
      update_employee_profile_node.parent.should eq create_employee_node
    end
  end

end
