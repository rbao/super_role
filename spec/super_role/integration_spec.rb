require 'spec_helper'

describe 'given definition files' do
  before do
    SuperRole.define_permissions do
      define_permissions_for [User,Project, Ticket, Employee, ProjectProfile]
      
      define_permissions_for Organization, extras: [:show_dashboard] do
        action_group :manage, [:update, :destroy]
        action_alias [:delete, :remove], :destroy
      end

      define_permissions_for [Government, EmployeeProfile, EmployeeStatus], only: :update
    end

    SuperRole.define_role_owner_resource_types do
      owner_resource_type nil do
        owns User

        owns Government do
          owns Organization
        end
      end

      owner_resource_type 'Organization', only: :update do
        owns Project, polymorphic: true, foreign_key: :owner_id do
          owns ProjectProfile, only: :update
          owns Ticket
        end

        owns Employee do
          owns EmployeeProfile
          owns EmployeeStatus
        end
      end
    end
  end

  describe 'creating a role with some invalid owner' do
    subject { role }
    let(:project) { Project.create! }
    let(:role) { Role.new(owner: project )}

    before { subject.valid? }

    it { should_not be_valid }
    its(:errors) { should have_key(:owner) }
  end

  describe 'creating a resource permission with invalid permission' do
    subject { resource_permission }
    let(:create_ticket) { Permission.find_by(action: 'create', resource_type: 'Ticket') }
    let(:role) { Role.create! }
    let(:resource_permission) { ResourcePermission.new(role: role, permission: create_ticket) }

    before { subject.valid? }

    it { should_not be_valid }
    its(:errors) { should have_key(:permission) }
  end

  describe 'A role with no owner' do
    let(:role) { Role.create! }

    describe 'check permissions for user' do
      let(:create) { Permission.find_by(action: 'create', resource_type: 'User') }
      let(:show) { Permission.find_by(action: 'show', resource_type: 'User') }
      let(:update) { Permission.find_by(action: 'update', resource_type: 'User') }
      let(:destroy) { Permission.find_by(action: 'destroy', resource_type: 'User') }

      it 'should not be able to create when not given any related permission' do
        user = User.create!

        role.can?('create', User.new).should be_false
        role.can?('create', user).should be_false
      end

      it 'should be able to create when given the permission' do
        user = User.create!
        role.resource_permissions.create!(permission: create)

        role.can?('create', User.new).should be_true
        role.can?('create', user).should be_true
      end

      it 'should not be able to show when not given the permission' do
        user = User.create!

        role.can?('show', User.new).should be_false
        role.can?('show', user).should be_false
      end

      it 'should be able to show when given the permission to show all user' do
        user = User.create!
        role.resource_permissions.create!(permission: show)

        role.can?('show', User.new).should be_true
        role.can?('show', user).should be_true
      end

      it 'should be able to show a specific user when given the permission to show that user' do
        user1 = User.create!
        user2 = User.create!
        role.resource_permissions.create!(permission: show, resource_id: user1.id)

        role.can?('show', user1).should be_true
        role.can?('show', user2).should be_false
        role.can?('show', User.new).should be_false
      end

      it 'should not be able to update when not given the permission' do
        user = User.create!

        role.can?('update', User.new).should be_false
        role.can?('update', user).should be_false
      end

      it 'should be able to update if given the permission' do
        user = User.create!
        role.resource_permissions.create!(permission: update)

        role.can?('update', User.new).should be_true
        role.can?('update', user).should be_true
      end

      it 'should not be able to destroy if not given the permission' do
        user = User.create!
        
        role.can?('update', User.new).should be_false
        role.can?('update', user).should be_false
      end

      it 'should be able to destroy when given the permission to destroy any user' do
        user = User.create!
        role.resource_permissions.create!(permission: destroy)

        role.can?('destroy', User.new).should be_true
        role.can?('destroy', user).should be_true
      end

      it 'should be able to destroy a specific user when given the permission to destroy that user' do
        user1 = User.create!
        user2 = User.create!
        role.resource_permissions.create!(permission: destroy, resource_id: user1.id)

        role.can?('destroy', user1).should be_true
        role.can?('destroy', user2).should be_false
        role.can?('destroy', User.new).should be_false
      end
    end

    describe 'check permissions for government' do
      let(:update) { Permission.find_by(action: 'update', resource_type: 'Government') }

      it 'should not be able to update when not given the permission' do
        government = Government.create!

        role.can?('update', Government.new).should be_false
        role.can?('update', government).should be_false
      end

      it 'should be able to update if given the permission' do
        government = Government.create!
        role.resource_permissions.create!(permission: update)

        role.can?('update', Government.new).should be_true
        role.can?('update', government).should be_true
      end

      it 'should not be able to destroy if not given the permission' do
        government = Government.create!
        
        role.can?('update', Government.new).should be_false
        role.can?('update', government).should be_false
      end
    end

    describe 'check permissions for organization' do
      let!(:government1) { Government.create! }
      let!(:government2) { Government.create! }
      let(:update) { Permission.find_by(action: 'update', resource_type: 'Organization') }

      it 'should not be able to update organization if not given the permission' do
        organization1 = Organization.create!
        organization2 = Organization.create!(government: government1)

        role.can?('update', Organization.new(government: government1)).should be_false
        role.can?('update', Organization.new).should be_false
        role.can?('update', organization1).should be_false
        role.can?('update', organization2).should be_false
      end

      it 'should be able to update organization if given permission to update all' do
        organization1 = Organization.create!(government: government1)
        role.resource_permissions.create!(permission: update)

        role.can?('update', Organization.new(government: government1)).should be_true
        role.can?('update', organization1).should be_true
      end

      it 'should not be able to update organization that does not belongs to any government
        even if given the update all spermission' do
        role.resource_permissions.create!(permission: update)
        organization = Organization.create!

        role.can?('update', Organization.new).should be_false
        role.can?('update', organization).should be_false
      end

      it 'should be able to update a specific organization when given the permission to update that organization' do
        organization1 = Organization.create!
        organization2 = Organization.create!
        role.resource_permissions.create!(permission: update, resource_id: organization1.id)

        role.can?('update', organization1).should be_true
        role.can?('update', organization2).should be_false
        role.can?('update', Organization.new).should be_false
        role.can?('update', Organization.new(government: government1)).should be_false
      end


    end

  end


end