module SuperRole
  module Permission

    extend ActiveSupport::Concern

    included do
      has_many :resource_permissions, class_name: SuperRole.resource_permission_class
    end

    def ==(other_object)
      other_object.class == self.class && other_object.state == state
    end
    alias_method :eql?, :==

    protected
    
    def state
      [action.to_s, resource_type.to_s]
    end
    
  end
end