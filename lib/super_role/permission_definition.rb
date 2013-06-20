module SuperRole
  class PermissionDefinition
    def self.run(&block)
      new.instance_eval(&block)
    end

    def permissions_for(classes, options = {}, &block)
      
    end
  end
end