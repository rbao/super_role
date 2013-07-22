def setup_permission_hierarchy_for_nil

  let!(:hierarchy) { SuperRole::PermissionHierarchy.create(nil) }

  let!(:nil_node) { hierarchy.root }
  let!(:government_node) { SuperRole::PermissionHierarchyNode.new('Government', parent: nil_node) }
  let!(:organization_node) { SuperRole::PermissionHierarchyNode.new('Organization', parent: government_node) }
  let!(:project_node) { SuperRole::PermissionHierarchyNode.new('Project', parent: organization_node, polymorphic: true, foreign_key: :owner_id) }
  let!(:proejct_profile_node) { SuperRole::PermissionHierarchyNode.new('ProjectProfile', parent: project_node) }
  let!(:ticket_node) { SuperRole::PermissionHierarchyNode.new('Ticket', parent: project_node) }

  setup_resources
end

def setup_permission_hierarchy_for_government

  let!(:hierarchy) { SuperRole::PermissionHierarchy.create('Government') }

  let!(:government_node) { hierarchy.root }
  let!(:organization_node) { SuperRole::PermissionHierarchyNode.new('Organization', parent: government_node) }
  let!(:project_node) { SuperRole::PermissionHierarchyNode.new('Project', parent: organization_node, polymorphic: true, foreign_key: :owner_id) }
  let!(:proejct_profile_node) { SuperRole::PermissionHierarchyNode.new('ProjectProfile', parent: project_node) }
  let!(:ticket_node) { SuperRole::PermissionHierarchyNode.new('Ticket', parent: project_node) }

  setup_resources
end

def setup_resources
  let!(:user) { User.create! }

  let!(:government1) { Government.create! }
  
  let!(:organization1) { Organization.create!(government_id: government1.id) }
  let!(:project1) { Project.create!(owner: organization1) }
  
  let!(:project_profile) { ProjectProfile.create!(project_id: project1.id) }
  let!(:ticket1) { Ticket.create!(proj_id: project1.id) }
  let!(:ticket2) { Ticket.create!(proj_id: project1.id) }
  
  let!(:project2) { Project.create!(owner: organization1) }
  let!(:ticket3) { Ticket.create!(proj_id: project2.id) }

  let!(:organization2) { Organization.create!(government_id: government1.id) }
  let!(:project3) { Project.create!(owner: organization2) }
  let!(:ticket4) { Ticket.create!(proj_id: project3.id) }

  let!(:government2) { Government.create! }
  let!(:organization3) { Organization.create!(government_id: government2.id) }
  let!(:project4) { Project.create!(owner: organization3) }
  let!(:ticket5) { Ticket.create!(proj_id: project4.id) }
end