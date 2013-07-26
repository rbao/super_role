require 'active_record'
require 'active_support/core_ext/module/attribute_accessors'

module SuperRole
  
  mattr_accessor :permission_class
  @@permission_class = nil

  mattr_accessor :resource_permission_class
  @@resource_permission_class = nil

  mattr_accessor :role_class
  @@role_class = nil

  def self.configure
    yield self
  end

  def self.define_permissions(&block)
    PermissionDefiner.run(&block)
  end

  def self.define_role_owner_permission_hierarchy(&block)
    PermissionHierarchyDefiner.run(&block)
  end

end

require 'super_role/concerns/input_normalization_helper'

require 'super_role/action_group'
require 'super_role/action_alias'
require 'super_role/permission_definer'
require 'super_role/permission_definition'

require 'super_role/permission_hierarchy_node'
require 'super_role/permission_hierarchy'
require 'super_role/permission_hierarchy_definer'

require 'super_role/concerns/permission'
require 'super_role/concerns/resource_permission'
require 'super_role/concerns/role'
