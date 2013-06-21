require "super_role/engine"
require "super_role/permission_definition"
require "super_role/role_owner_definition"

module SuperRole
  
  def self.configure
    
  end

  def self.define_permissions(&block)
    PermissionDefinition.run(&block)
  end

  def self.define_role_owners(&block)
    RoleOwnerDefinition.run(&block)
  end

end
