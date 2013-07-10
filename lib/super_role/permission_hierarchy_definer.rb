module SuperRole
  class PermissionHierarchyDefiner
    def self.run(&block)
      new.instance_eval(&block)
    end

    def node(klass)
      
    end
    
  end
end