require 'spec_helper'

class Organization < ActiveRecord::Base; end

describe 'DSL for SuperRole.define_role_owner' do
  
  describe 'one line definition' do

    let(:organization) { Organization.create! }    
    let!(:update_organization) { Permission.create!(action: 'update', resource_type: 'Organization') }
    let!(:show_organization) { Permission.create!(action: 'show', resource_type: 'Organization') }
    let(:hierarchy_root) { SuperRole::RoleOwner.find('Organization').hierarchy_root }

    context 'with no options' do
      subject do
        SuperRole.define_role_owners do
          owner 'Organization'
        end 
      end

      it 'should add a root node of itself with no parent and no children' do
        subject
        hierarchy_root.resource_type.should eq 'Organization'
        hierarchy_root.parent.should be_nil
        hierarchy_root.children.should eq []
      end

      it 'should add a root node which owns all actions of itself' do
        subject
        hierarchy_root.permissions.should include(update_organization)
        hierarchy_root.permissions.should include(show_organization)
      end
    end

    context 'with :only options' do
      subject do
        SuperRole.define_role_owners do
          owner 'Organization', only: :update
        end
      end

      it 'should add a root node which owns only the specified actions' do
        subject
        hierarchy_root.permissions.should include(update_organization)
        hierarchy_root.permissions.should_not include(show_organization)
      end
    end

    context 'with :only options' do
      subject do
        SuperRole.define_role_owners do
          owner 'Organization', except: :show
        end
      end

      it 'should add a root node which owns only the specified actions' do
        subject
        hierarchy_root.permissions.should include(update_organization)
        hierarchy_root.permissions.should_not include(show_organization)
      end
    end
    
    
  end

end
