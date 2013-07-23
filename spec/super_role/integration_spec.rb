require 'spec_helper'

describe 'integration', :focus do
  before do
    SuperRole.define_permissions do
      define_permissions_for Government, only: :update
      
      define_permissions_for Organization, extras: [:show_dashboard] do
        action_group :manage, [:update, :destroy]
        action_alias [:delete, :remove], :destroy
      end

      define_permissions_for [Project, Ticket, Employee, ProjectProfile]

      define_permissions_for [EmployeeProfile, EmployeeStatus], only: :update
    end

    SuperRole.define_role_owner_resource_types do
      owner_resource_type nil do
        owns Government do
          Organization
        end
      end

      owner_resource_type 'Organization' do
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

  it 'gasdf' do
    'asdf'
  end
end