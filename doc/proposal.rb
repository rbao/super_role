# roles
# - name
# permissions
# - action
# - resource_type
# resource_permissions
# - role_id
# - permission_id
# - resource_id

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

SuperRole.define_permissions_hierarchy do

  parent Organization do
    # A role that can have permissions for organization can also have permissions for its
    # children. An instance of the following object are considered to be a child of an 
    # organization if its organization_id equals to organization.id. For example a role for
    # an organization can have permission to create an OrganizationProfile only
    # if the OrganizationProfile's organization_id equals organization.id.
    children [OrganizationUserRelationship, OrganizationProfile, Contact]

    # If foreign_key is different, it must be specified here. This means an instance of
    # OrganizationSetting must have its org_id equals to organization.id in order to
    # be consider as a child of the organization
    children OrganizationSetting, foreign_key: :org_id

    # An organization's role can have permissions on any project it owns, but not on any of project's
    # children. This mean the role can have :edit, :update, :destroy permissions for an project, but 
    # not for the project's ProjectSetting. If shallow is set to false or not specified, the organization's
    # role will be able to have permissions for project's ProjectSetting and any other children a project
    # have.
    children Project, shallow: true
  end

  parent Contact do
    children [ContactProfile]
  end

  parent Project do
    children [ProjectProfile, ProjectSetting, ProjectUserRelationship]
  end

end

SuperRole.define_role_owners do
  
  # Role can have no owner, and they will be considered as the root role.
  owner :root do
    # Root role can have all permissions.
    can_have_permissions_for :all
  end

  # A role can belongs_to an instance of Organization, and it can have all of its permissions including
  # its children's permissions except for [:create, Organization]. If no block is given, it will
  # automatically add its own permissions to it. This is the same as writing:
  # owner Organization do
  #   can_have_permissions_for Organization, except: [:create]
  # end
  owner Organization

  owner Project

  # A role can belongs_to an instance of Government and it can have all permissions for organization including any of
  # organization's children.
  owner Government do
    can_have_permissions_for Government, only: :update
    can_have_permissions_for Organization
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

@rooe.can?(:edit, @organization.contacts.first.contact_profile) #=> true