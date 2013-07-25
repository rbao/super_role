# roles
# - name
# permissions
# - action
# - resource_type
# resource_permissions
# - role_id
# - permission_id
# - resource_id
# - reference_id
# - reference_type

SuperRole.configure do |config|
  config.raise_exception_if_pending_update_exists = true
  config.role_class = Role
  config.permission_class = Permission
  config.resource_permission_class = ResourcePermission
end

SuperRole.define_permissions do
  
  # Add [:create, :update, :destroy, :show] permissions for both Organizatnion and Contact
  # Also add :new as alias for :create, :edit as alias for :update
  define_permissions_for [Project, Contact, Government]

  # Add [:create, :update, :destroy, :show, :show_dashboard] permissions for Organization
  define_permissions_for Organization, extras: [:show_dashboard] do
    action_group :manage, [:update, :destroy]
    action_alias [:delete, :remove], :destroy
  end
  
  # Add :update permissions for OrganizationSetting and OrganizationProfile
  define_permissions_for [OrganizationSetting, OrganizationProfile], only: [:update]
end

SuperRole.define_role_owner_permission_hierarchy do
  
  owner_resource_type nil do
    owns Government
  end

  owner_resource_type Government do
    owns Organization
  end

  # By default this also implicitly means it owns Organization
  # If you can also provide options to include or exclude certain action
  # owner Organization, except: :create
  owner_resource_type Organization do

    # A role that is owned by an organization can also have permissions for its
    # children node. An instance of the following object are considered to be a child node of an 
    # organization if its organization_id equals to organization.id. For example an organization role
    # can have permission to create an OrganizationUserRelationship only
    # if the OrganizationUserRelationship's organization_id equals organization.id.
    owns [OrganizationUserRelationship, OrganizationFinance]

    # We can also set the :only key. In this case the organization's role can only have permission
    # for :update OrganizationProfile.
    owns OrganizationProfile, only: :update

    # If foreign_key is different, it must be specified here. This means an instance of
    # OrganizationSetting must have its org_id equals to organization.id in order to
    # be consider as a child of the organization
    owns OrganizationSetting, foreign_key: :org_id

    # Children node can be nested. In this case the organization role have permissions on
    # ContactProfile if ContactProfile's contact_id is in organization.contacts.map(&:id).
    owns Contact do
      owns ContactProfile
    end

    # We can also provide options for the nested children node
    owns Project do
      owns ProjectUserRelationship
      owns [ProjectProfile, ProjectSetting], only: :update
    end
  end

  owner_resource_type Project do
    owns [ProjectProfile, ProjectSetting, ProjectUserRelationship], only: :update
  end

end

# An app define its classes and gets SuperRole functaionlity by including concerns.
# All the association will be set accordingly
class Role < ActiveRecord::Base
  include SuperRole::Role
end

class Permission < ActiveRecord::Base
  include SuperRole::Permission
end

class RolePermissionRelationship < ActiveRecord::Base
  include SuperRole::RolePermissionRelationship
end

# SuperRole will inject a class method on all object that have permissions defined
Organization.permissions
# => [#<Permission id: 1 action: "update", resource_type="Organization">,
#     ...
#     #<Permission id: 39 action: "destroy", resource_type="Contact">]

Organization.permissions(exclude_children: true)
# => [#<Permission id: 1 action: "update", resource_type="Organization">,
#     #<Permission id: 2 action: "show", resource_type="Organization">,
#     #<Permission id: 3 action: "destroy", resource_type="Organization">]

# Assume this organization role have every permission it can have
@role = @organization.roles.first

# Can this role update its organization?
@role.can?(:update, @organization) #=> true

# Since edit is an alias of update, this always return the same result
# as above
@role.can?(:edit, @organization) #=> true

# Can this role destroy its organization?
@role.can?(:destroy, @organization) #=> true

# Since delete and remove is an alias of destroy, this always return the same result
# as above
@role.can?(:delete, @organization) #=> true
@role.can?(:remove, @organization) #=> true

# Can this role create any project?
@role.can?(:create, Project) #=> false

# Can this role create project in another organization?
@role.can?(:create, Project.new(organization_id: 999)) #=> false

# Can this role create project in this organization
@role.can?(:create, @organization.project.build) #=> true

# We can also check against a permission group
@role.can?(:manage, @organization) #=> true

# Since we used the shallow: true options for projects, we will not be able
# to edit an project's project_setting
@role.can?(:edit, @organization.projects.first.project_setting) #=> false

@role.can?(:edit, @organization.contacts.first.contact_profile) #=> true

# Can this role be given the permission to create a project?
@role.can_have_permission?(:create, Project) # => true

# If the role owner is a project then this will return false
@role.owner = Project.first
@role.can_have_permission?(:create, Project) # => false


@role.owner = Organization.first
# Preferrably return an ActiveRecord::Relation
@role.possible_resources_for_permission(:update, Project) #=> [#<Project id:1, organization_id: 1>]
# or maybe?
Project.possible_for_role(@role, to: :update)

@contact = Organization.first.contacts.first

@role.possible_resources_for_permission(:update, ContactProfile, scope: { contact_id: [1] } ) #=>


Organization project.org_id ticket.proj_id

