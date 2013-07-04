ActiveRecord::Migration.create_table :permissions do |t|
  t.string :action
  t.string :resource_type
  t.timestamps
end

class Permission < ActiveRecord::Base
  include SuperRole::Permission
end

class ResourcePermission < ActiveRecord::Base
end