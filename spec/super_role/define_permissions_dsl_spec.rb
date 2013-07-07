require 'spec_helper'

class Project; end
class Contact; end

describe 'DSL for SuperRole.define_permissions' do

  let(:default_actions) { SuperRole::PermissionDefiner.new.default_actions }
  let(:action_groups) { SuperRole::ActionGroup.all }
  let(:project_permissions) { Permission.where(resource_type: Project) }
  let(:contact_permissions) { Permission.where(resource_type: Contact) }

  describe 'one line definition' do

    describe 'for a single class with no options' do
      before do
        SuperRole.define_permissions do
          define_permissions_for Project
        end
      end

      it 'should add in the default permissions for that class' do
        project_permissions.map(&:action).should match_array default_actions
      end
    end

    describe 'for an array of classes with no options' do
      before do
        SuperRole.define_permissions do
          define_permissions_for [Project, Contact]
        end
      end

      it 'should add in the default permissions for all the classes in the array' do
        project_permissions.map(&:action).should match_array default_actions
        contact_permissions.map(&:action).should match_array default_actions
      end
    end

    describe 'with :only options' do
      before do
        SuperRole.define_permissions do
          define_permissions_for [Project, Contact], only: [:update, :create]
        end
      end

      it 'should only add in the default permissions specified with only' do
        project_permissions.map(&:action).should match_array ['update', 'create']
        contact_permissions.map(&:action).should match_array ['update', 'create']
      end
    end

    describe 'with :except options' do
      before do
        SuperRole.define_permissions do
          define_permissions_for [Project, Contact], except: [:update, :create]
        end
      end

      it 'should only add in the default permissions specified with only' do
        project_permissions.map(&:action).should match_array default_actions - ['update', 'create']
        contact_permissions.map(&:action).should match_array default_actions - ['update', 'create']
      end
    end

    describe 'with :extra options' do
      before do
        SuperRole.define_permissions do
          define_permissions_for [Project, Contact], extra: [:action1, :action2]
        end
      end

      it 'should only add in the default permissions specified with only' do
        project_permissions.map(&:action).should match_array default_actions + ['action1', 'action2']
        contact_permissions.map(&:action).should match_array default_actions + ['action1', 'action2']
      end
    end

  end
  
  describe 'multiple line definition' do
    
    describe 'with action_group' do
      before do
        SuperRole.define_permissions do
          define_permissions_for [Project, Contact] do
            action_group :manage, [:update, :destroy]
          end
        end
      end

      it 'should add in the default permissions' do
        project_permissions.map(&:action).should match_array default_actions
        contact_permissions.map(&:action).should match_array default_actions
      end

      it 'should add in the action_group' do
        SuperRole::ActionGroup.find(:manage, Project).actions.should match_array ['update', 'destroy']
      end
    end
  end

end