module SuperRole
  class PermissionHierarchyDefiner
    
    include DslNormalizationHelper

    def self.run(&block)
      definer = new
      definer.instance_eval(&block)
      PermissionHierarchy.all.freeze
    end

    def owner_resource_type(resource_type, options = {}, &block)
      permission_hierarchy = PermissionHierarchy.create(resource_type, options)
      permission_hierarchy.instance_eval(&block) if block_given?
    end
  end
end