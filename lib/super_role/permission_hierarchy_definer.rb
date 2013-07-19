module SuperRole
  class PermissionHierarchyDefiner
    
    include DslNormalizationHelper

    def self.run(&block)
      definer = new
      definer.instance_eval(&block)
      PermissionHierarchy.all.freeze
    end

    def owner_resource_type(resource_type, options = {}, &block)
      role_owner = PermissionHierarchy.create(resource_type, options)
      role_owner.instance_eval(&block) if block_given?
    end
  end
end