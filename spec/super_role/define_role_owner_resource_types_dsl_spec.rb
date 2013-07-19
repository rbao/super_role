require 'spec_helper'

describe 'DSL for SuperRole.define_role_owner' do
  
  describe 'one line definition' do

    let!(:update_organization) { Permission.create!(action: 'update', resource_type: 'Organization') }
    let!(:show_organization) { Permission.create!(action: 'show', resource_type: 'Organization') }
    let(:root) { SuperRole::PermissionHierarchy.find('Organization').root }

    context 'with no options' do
      subject do
        SuperRole.define_role_owner_resource_types do
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
        SuperRole.define_role_owner_resource_types do
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
        SuperRole.define_role_owner_resource_types do
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

end
