module SuperRole
  module ActiveRecordExtension
    extend ActiveSupport::Concern

    module ClassMethods
      def permissions
        hierarchy_node = PermissionHierarchyNode.find(self)
        hierarchy_node.permissions
      end
    end
  end
end