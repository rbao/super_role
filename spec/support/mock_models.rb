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

ActiveRecord::Migration.create_table :governments

ActiveRecord::Migration.create_table :organizations do |t|
  t.integer :government_id
end

ActiveRecord::Migration.create_table :projects do |t|
  t.integer :owner_id
  t.string :owner_type
end

ActiveRecord::Migration.create_table :employees do |t|
  t.integer :organization_id
end

ActiveRecord::Migration.create_table :employee_profiles do |t|
  t.integer :employee_id
end

ActiveRecord::Migration.create_table :employee_status do |t|
  t.integer :employee_id
end

ActiveRecord::Migration.create_table :project_profiles do |t|
  t.integer :project_id
end

ActiveRecord::Migration.create_table :tickets do |t|
  t.integer :proj_id
end

ActiveRecord::Migration.create_table :tasks do |t|
  t.integer :owner_id
  t.integer :owner_type
end

ActiveRecord::Migration.create_table :users do |t|
end

class User < ActiveRecord::Base; end

class Government < ActiveRecord::Base; end

class Organization < ActiveRecord::Base
  belongs_to :government
end

class Employee < ActiveRecord::Base
  belongs_to :organization
end

class EmployeeProfile < ActiveRecord::Base
  belongs_to :employee
end

class EmployeeStatus < ActiveRecord::Base
  belongs_to :employee
end

class Project < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
end

class ProjectProfile < ActiveRecord::Base
  belongs_to :project
end

class Ticket < ActiveRecord::Base
  belongs_to :project, foreign_key: :proj_id
end

