module SuperRole
  class PermissionHierarchyDefinition
    def self.run(&block)
      new.instance_eval(&block)
    end
    
  end
end