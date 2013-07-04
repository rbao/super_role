require "active_record"
require "active_support/core_ext/module/attribute_accessors"



module SuperRole
  
  mattr_accessor :resource_permission_class
  @@resource_permission_class = nil

  def self.configure
    
  end

  def self.define_permissions(&block)
    PermissionDefiner.run(&block)
  end

  def self.define_permission_hierarchy(&block)
    PermissionHierarchyDefinitions.run(&block)
  end

  def self.define_role_owners(&block)
    RoleOwnerDefinitions.run(&block)
  end

end

require "super_role/permission_definition"
require "super_role/role_owner_definition"
require "super_role/concerns/permission"