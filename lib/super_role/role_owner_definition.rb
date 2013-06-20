module SuperRole
  class RoleOwnerDefinition
    def self.run(&block)
      new.instance_eval(&block)
    end

    def root(&block)
      
    end

    def owner(klass, options = {}, &block)
      
    end

    def children(classes, options = {})
      
    end
  end
end