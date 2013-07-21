def setup_mock_permission_hierarchy

  let(:nil_node) { SuperRole::PermissionHierarchyNode.new('') }
  let(:government_node) { SuperRole::PermissionHierarchyNode.new('Government', parent: nil_node) }
  let(:organization_node) { SuperRole::PermissionHierarchyNode.new('Organization', parent: government_node) }
  let(:project_node) { SuperRole::PermissionHierarchyNode.new('Project', parent: organization_node) }
  let(:proejct_profile_node) { SuperRole::PermissionHierarchyNode.new('ProjectProfile', parent: project_node) }
  let(:ticket_node) { SuperRole::PermissionHierarchyNode.new('Ticket', parent: project_node) }

  let!(:user) { User.create! }

  let!(:government1) { Government.create! }
  
  let!(:organization1) { Organization.create!(government_id: government1.id) }
  let!(:project1) { Project.create!(organization_id: organization1.id) }
  
  let!(:project_profile) { ProjectProfile.create!(project_id: project1.id) }
  let!(:ticket1) { Ticket.create!(proj_id: project1.id) }
  let!(:ticket2) { Ticket.create!(proj_id: project1.id) }
  
  let!(:project2) { Project.create!(organization_id: organization1.id) }
  let!(:ticket3) { Ticket.create!(proj_id: project2.id) }

  let!(:organization2) { Organization.create!(government_id: government1.id) }
  let!(:project3) { Project.create!(organization_id: organization2.id) }
  let!(:ticket4) { Ticket.create!(proj_id: project3.id) }

  let!(:government2) { Government.create! }
  let!(:organization3) { Organization.create!(government_id: government2.id) }
  let!(:project4) { Project.create!(organization_id: organization3.id) }
  let!(:ticket5) { Ticket.create!(proj_id: project4.id) }
end