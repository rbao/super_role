# role
# - Name
# permission
# - action
# - resource_type
# role_permission_relationships
# - role_id
# - permission_id
# - resource_id

SuperRole.configure do |config|
  config.raise_exception_if_pending_update_exists = true
  config.role_class = Role
  config.permission_class = Permission
  config.role_permission_relationship_class = RolePermissionRelationship
end

SuperRole.define_permissions do
  
  # Add [:create, :update, :destroy, :show] permissions for both Organizatnion and Contact
  permissions_for [Project, Contact]

  # Add [:create, :update, :destroy, :show, :show_dashboard] permissions for Organization
  permissions_for Organization, extra: [:show_dashboard] do
    group :manage, [:create, :update, :destroy]
  end
  
  # Add :update permissions for OrganizationSetting and OrganizationProfile
  permissions_for [OrganizationSetting, OrganizationProfile], only: [:update]

end

SuperRole.define_role_owners do
  
  # Role that does not have any owner can have permissions for everything
  root do
    children :all
  end

  # A role can belongs_to organization, and can have all its permission except for create.
  # A has_many :roles will also be injected to the Organization class.
  owner Organization do
    # A role that is owned by an organization can also have permissions for these children
    # object, an instance of the following object are considered to be a child of an 
    # organization if its organization_id equals to organization.id. For example a role for
    # an organization can have permission to create an OrganizationProfile only
    # if the OrganizationProfile's organization_id equals organization.id.
    children [OrganizationUserRelationship, OrganizationProfile, Contact]

    # If foreign_key is different, it must be specified here. This means an instance of
    # OrganizationSetting must have its org_id equals to organization.id in order to
    # be consider as a child of the organization
    children OrganizationSetting, foreign_key: :org_id

    # An organization's role can have permissions on any project it owns, but not anything else 
    # the project role can have. If shallow is false or not specified, an organization role can have
    # every permission a project role can have as defined further below. 
    children Project, shallow: true
  end

  owner Project do
    children [ProjectProfile, ProjectSetting, ProjectUserRelationship]
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
@role.has_permission?(:update, @organization) #=> true

# Can this role create any project?
@role.has_permission?(:create, Project) #=> false

# Can this role create project in another organization?
@role.has_permission?(:create, Project.new(organization_id: 999)) #=> false

# Can this role create project in this organization
@role.has_permission?(:create, @organization.project.build) #=> true

# We can also check against a permission group
@role.has_permission?(:manage, @organization) #=> true

