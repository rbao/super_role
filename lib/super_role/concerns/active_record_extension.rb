module SuperRole
  module ActiveRecordExtension
    extend ActiveSupport::Concern

    module ClassMethods
      def permissions
        role_owner = SuperRole::RoleOwner.find(self)
        role_owner.permissions
      end
    end
  end
end