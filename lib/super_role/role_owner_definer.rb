module SuperRole
  module RoleOwnerDefiner
    
    include DslNormalizationHelper

    def self.run(&block)
      definer = new
      definer.instance_eval(&block)
      RoleOwner.all.freeze
    end

    def owner(resource_type, options = {}, &block)
      role_owner = RoleOwner.create(resource_type, options)
      role_owner.instance_eval(&block)
    end
  end
end