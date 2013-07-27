require 'spec_helper'

describe SuperRole::PermissionHierarchyNode do
  
  describe '#initialize' do
    subject { SuperRole::PermissionHierarchyNode.new(resource_type, options) }
    let(:resource_type) { 'Organization' }
    
    context 'when no options given' do
      subject { SuperRole::PermissionHierarchyNode.new(resource_type) }
      let(:permission1) { double('permission1') } 
      let(:permission2) { double('permission2') }

      before do
        Permission.stub(:find_by).and_return(permission1, permission2)
        SuperRole::PermissionHierarchyNode.any_instance.stub(:default_actions).and_return(['action1', 'action2'])
      end

      it 'should add all the actions of the resource_type to the node' do
        subject.node_permissions.should match_array [permission1, permission2]
      end

      its(:children) { should eq [] }
      its(:resource_type) { should eq 'Organization' }
    end

    context 'when given :only option' do
      let(:options) { { only: ['action1', :action2] } }
      let(:permission1) { double('permission1') } 
      let(:permission2) { double('permission2') }
      let(:permission3) { double('permission3') }

      before do
        Permission.stub(:find_by).and_return(permission1, permission2, permission3)
        SuperRole::PermissionHierarchyNode.any_instance.stub(:default_actions).and_return(['action1', 'action2', 'action3'])
      end
      
      it 'should add only add the specified by the :only option' do
        subject.node_permissions.should match_array [permission1, permission2]
      end
    end

    context 'when given :except option' do
      let(:options) { { except: ['action3'] } }
      let(:permission1) { double('permission1') } 
      let(:permission2) { double('permission2') }
      let(:permission3) { double('permission3') }

      before do
        Permission.stub(:find_by).and_return(permission1, permission2, permission3)
        SuperRole::PermissionHierarchyNode.any_instance.stub(:default_actions).and_return(['action1', 'action2', 'action3'])
      end
      
      it 'should add all the actions except of the one specified' do
        subject.node_permissions.should match_array [permission1, permission2]
      end 
    end

    context 'when given :parent option' do
      let(:parent) { double(:resource_type => 'SomeType') }
      let(:options) { { parent: parent} }

      its(:parent) { should eq parent }
      its(:parent_foreign_key) { should eq 'some_type_id' }
    end

    context 'when given :foreign_key option' do
      let(:parent) { double('parent') }
      let(:options) { { foreign_key: 'g_id'} }

      it 'should set the parent to the given one' do
        subject.parent_foreign_key.should eq 'g_id'
      end
    end

    context 'when given :polymorphic option and :foreign_key option' do
      let(:parent) { double('parent') }
      let(:options) { { polymorphic: true, foreign_key: 'owner_id'} }

      it 'should set the polymorphic attribute' do
        subject.polymorphic.should be_true
      end
    end

    context 'when given :polymorphic option but no :foreign_key option' do
      let(:parent) { double('parent') }
      let(:options) { { polymorphic: true } }

      it 'should raise error' do
        expect { subject }.to raise_error(SuperRole::ForeignKeyRequiredForPolymorphicNode)
      end
    end
  end
  
  describe '#owns' do
    let(:node) { SuperRole::PermissionHierarchyNode.new('Organization') }
    let(:child_node) { double('child_node') }

    context 'when no block given' do
      subject { node.owns('Child') }
      
      it 'should add the given resource_type as a child node' do
        expect(SuperRole::PermissionHierarchyNode).to receive(:new).with('Child', { parent: node }).and_return(child_node)
        expect { subject }.to change { node.children.count }.by(1)
        node.children.should include(child_node)
      end
    end

    context 'when given some options' do
      subject { node.owns('Child', options) }
      let(:options) { { a: 1 } }

      it 'should add the given resource_type with the options as a child node' do
        expect(SuperRole::PermissionHierarchyNode).to receive(:new).with('Child', options.merge({ parent: node })).and_return(child_node)
        expect { subject }.to change { node.children.count }.by(1)
        node.children.should include(child_node)
      end
    end

    context 'when given a block' do
      subject { node.owns('Child', &block) }
      let(:block) { proc { } }

      it 'should evaluate the block at the child node instance' do
        expect(SuperRole::PermissionHierarchyNode).to receive(:new).with('Child', { parent: node }).and_return(child_node)
        expect(child_node).to receive(:instance_eval).with(&block)

        expect { subject }.to change { node.children.count }.by(1)
        node.children.should include(child_node)
      end
    end
  end

  describe '#find_descendant' do
    subject { node.find_descendant(permission) }

    let(:node) { SuperRole::PermissionHierarchyNode.new('Organization') }
    let(:permission) { double('permission') }
    
    context 'when the node it self have the permission' do
      before { node.stub_chain(:node_permissions, :include? => true) }
      it { should eq node }
    end

    context 'when the node it self does not have the permission' do
      context 'and also cannot be found from any of the node\'s children\'s descendant' do
        before do
          node.stub(:children => [double(:find_descendant => false)])
        end
        it { should be_nil }
      end

      context 'but cannot be found from one of the node\'s children\'s descendant' do
        let(:descendant_node) { double('descendant_node') }

        before do
          node.stub(:children => [double(:find_descendant => descendant_node)])
        end
        it { should eq descendant_node }
      end
    end
  end

  describe '#possible_resources_for_ancestor_resource' do
    subject { ticket_node.possible_resources_for_ancestor_resource(ancestor_resource) }
    
    context 'when ancestor_resource is the same type of the node it self' do
      setup_permission_hierarchy_for_nil
      let(:ancestor_resource) { ticket1 }

      it('should return ancestor_resource') { should match_array [ancestor_resource] }
    end

    context 'when ancestor_resource is the parent of the node' do
      setup_permission_hierarchy_for_nil
      let(:ancestor_resource) { project1 }
      
      it 'should return all the resources that belongs_to the ancestor_resource' do
        should match_array [ticket1, ticket2]
      end
    end

    context 'when ancestor_resource is the grand parent of the node' do
      setup_permission_hierarchy_for_nil
      let(:ancestor_resource) { organization1 }
      
      it 'should return all the resources that eventually belongs to the grand parent' do
        should match_array [ticket1, ticket2, ticket3]
      end
    end

    context 'when ancestor_resource is an ancestor of the node' do
      setup_permission_hierarchy_for_nil
      let(:ancestor_resource) { government1 }
      
      it 'should return all the resources that eventually belongs to that ancestor' do
        should match_array [ticket1, ticket2, ticket3, ticket4]
      end
    end

    context 'when ancestor_resource is nil' do
      setup_permission_hierarchy_for_nil
      let(:ancestor_resource) { nil }
      
      it 'should return all existing resources' do
        should match_array [ticket1, ticket2, ticket3, ticket4, ticket5]
      end
    end

    context 'when ancestor_resource is actually an descendant resource' do
      subject { project_node.possible_resources_for_ancestor_resource(ancestor_resource) }
      setup_permission_hierarchy_for_nil
      let(:ancestor_resource) { ticket1 }

      it { should match_array [] }
    end

    context 'when ancestor_resource is nil and nil_node is the root of the hierarchy' do
      subject { project_node.possible_resources_for_ancestor_resource(ancestor_resource) }
      setup_permission_hierarchy_for_nil
      let(:ancestor_resource) { nil }
      
      it { should match_array [project1, project2, project3, project4] }
    end

    context 'when ancestor_resource is nil but nil_node is not the root of the hierarchy' do
      subject { project_node.possible_resources_for_ancestor_resource(ancestor_resource) }
      setup_permission_hierarchy_for_government
      let(:ancestor_resource) { nil }
      
      it { should match_array [] }
    end

    context 'when ancestor_resource does not have a permission node in the hierarchy' do
      setup_permission_hierarchy_for_nil
      let(:ancestor_resource) { user }

      it { should match_array [] }
    end
  end

  describe '#ancestor_resource?' do
    subject { ticket_node.ancestor_resource?(resource, target_resource) }
    setup_permission_hierarchy_for_nil

    context 'when the resource directly belongs_to target_resource' do
      let(:resource) { ticket1 }
      let(:target_resource) { project1 }

      it { should be_true }
    end

    context 'when the permission node of target_resource is the parent of the permission node of resource but
      resource does not belongs_to target_resource' do
      let(:resource) { ticket1 }
      let(:target_resource) { project2 }

      it { should be_false }
    end

    context 'when the resource belongs_to a resource that belongs_to target_resource' do
      let(:resource) { ticket1 }
      let(:target_resource) { organization1 }

      it { should be_true }
    end

    context 'when the permission node of target_resource is the grand parent of the permission node of resource but
      resource does not belongs_to a resource that belongs_to target_resource' do
      let(:resource) { ticket1 }
      let(:target_resource) { organization2 }

      it { should be_false }
    end

    context 'when the resource belongs_to a resource that eventually belongs_to target_resource' do
      let(:resource) { ticket1 }
      let(:target_resource) { government1 }

      it { should be_true }
    end

    context 'when the permission node of target_resource is the ancestor of the permission node of resource but
      resource does not belongs_to a resource that eventually belongs_to target_resource' do
      let(:resource) { ticket1 }
      let(:target_resource) { government2 }

      it { should be_false }
    end

    context 'when target_resource is actually a descendant of resource' do
      subject { project_node.ancestor_resource?(resource, target_resource) }
      let(:resource) { project1 }
      let(:target_resource) { ticket1 }

      it { should be_false }
    end

    context 'when target_resource does not have a permission node in the hierarchy' do
      let(:resource) { ticket1 }
      let(:target_resource) { user }

      it { should be_false }
    end

    context 'when target_resource is nil and resource is directly under nil which has no foreign_key' do
      subject { government_node.ancestor_resource?(resource, target_resource) }
      let(:resource) { Government.new }
      let(:target_resource) { nil }

      it { should be_true }
    end
  end
  
end
