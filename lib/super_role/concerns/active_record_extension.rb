module SuperRole
  module ActiveRecordExtension
    extend ActiveSupport::Concern

    module ClassMethods
      def permissions
        permission_hierarchy = SuperRole::PermissionHierarchy.find(self)
        return permission_hierarchy.permissions if permission_hierarchy
        []
      end
    end
  end
end