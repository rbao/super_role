## Required Resources ##

ActiveRecord::Migration.create_table :permissions do |t|
  t.string :action
  t.string :resource_type
end

class Permission < ActiveRecord::Base
  include SuperRole::Permission
end

class ResourcePermission < ActiveRecord::Base
end

## Mock Models For Testing ##

ActiveRecord::Migration.create_table :government

ActiveRecord::Migration.create_table :organizations do |t|
  t.integer :government_id
end

ActiveRecord::Migration.create_table :projects do |t|
  t.integer :organization_id
end

ActiveRecord::Migration.create_table :project_profiles do |t|
  t.integer :project_id
end

ActiveRecord::Migration.create_table :tickets do |t|
  t.integer :proj_id
end

class Government < ActiveRecord::Base; end

class Organization < ActiveRecord::Base
  belongs_to :government
end

class Project < ActiveRecord::Base
  belongs_to :organization
end

class ProjectProfile < ActiveRecord::Base
  belongs_to :project
end

class Ticket < ActiveRecord::Base
  belongs_to :project, foreign_key: :proj_id
end

