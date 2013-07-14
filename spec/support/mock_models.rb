ActiveRecord::Migration.create_table :permissions do |t|
  t.string :action
  t.string :resource_type
end

ActiveRecord::Migration.create_table :organization

ActiveRecord::Migration.create_table :project do |t|
  t.integer :organization_id
end

ActiveRecord::Migration.create_table :project_profile do |t|
  t.integer :project_id
end

ActiveRecord::Migration.create_table :ticket do |t|
  t.integer :proj_id
end

class Organization < ActiveRecord::Base; end

class Project < ActiveRecord::Base
  belongs_to :organization
end

class ProjectProfile < ActiveRecord::Base
  belongs_to :project
end

class Ticket < ActiveRecord::Base
  belongs_to :project, foreign_key: :proj_id
end

class Permission < ActiveRecord::Base
  include SuperRole::Permission
end

class ResourcePermission < ActiveRecord::Base
end