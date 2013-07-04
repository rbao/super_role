module SuperRole
  module Permission
    extend ActiveSupport::Concern

    included do
      has_many :resource_permissions, class_name: SuperRole.resource_permission_class
    end

    def ==(other_object)
      other_object.class == self.class && other_object._state == _state
    end
    alias_method :eql?, :==

    protected
      def _state
        [action, resource_type]
      end
  end
end