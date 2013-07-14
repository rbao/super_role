require 'active_record'
require 'active_support/core_ext/module/attribute_accessors'

module SuperRole
  
  mattr_accessor :resource_permission_class
  @@resource_permission_class = nil

  mattr_accessor :permission_class
  @@permission_class = nil

  def self.configure
    yield self
  end

  def self.permission_class
    @@permission_class.constantize
  end

  def self.define_permissions(&block)
    PermissionDefiner.run(&block)
  end

  def self.define_role_owners(&block)
    RoleOwnerDefiner.run(&block)
  end

end

require 'super_role/concerns/dsl_normalization_helper'
require 'super_role/concerns/permission'
require 'super_role/action_group'
require 'super_role/action_alias'
require 'super_role/permission_definition'
require 'super_role/role_owner_definition'
require 'super_role/permission_definer'
