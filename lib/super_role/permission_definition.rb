module SuperRole
  class PermissionDefinition

    def self.run(&block)
      new.instance_eval(&block)
    end

    def permissions_for(classes, options = {}, &block)
      
    end

    def group(group_name, permissions)
      
    end

    def alias_permission(alias_names, options)
      
    end
    
  end
end