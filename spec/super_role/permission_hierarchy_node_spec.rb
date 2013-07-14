require 'spec_helper'

describe SuperRole::PermissionHierarchyNode do
  
  describe '#initialize' do
    subject { SuperRole::PermissionHierarchyNode.new(resource_type, options) }
    let(:resource_type) { 'Organization' }
    let!(:show_organization) { Permission.create!(action: 'show', resource_type: 'Organization') }
    let!(:update_organization) { Permission.create!(action: 'update', resource_type: 'Organization') }
    let!(:destroy_organization) { Permission.create!(action: 'destroy', resource_type: 'Organization') }
    
    context 'with no options' do
      let(:options) { {} }
      
      it 'should add all the actions of the resource_type to the node' do
        subject.node_permissions.should match_array [show_organization, update_organization, destroy_organization]
      end

      its(:children) { should eq [] }
      its(:parent) { should be_nil }
      its(:resource_type) { should eq 'Organization' }
    end

    context 'with :only options' do
      let(:options) { { only: :update } }
      
      it 'should add only the specified actions' do
        subject.node_permissions.should match_array [update_organization]
      end
    end

    context 'with :except options' do
      let(:options) { { except: ['update'] } }
      
      it 'should add all the actions except of the one specified' do
        subject.node_permissions.should match_array [show_organization, destroy_organization]
      end 
    end

  end
  
  describe '#owns' do
    let(:parent_node) { SuperRole::PermissionHierarchyNode.new('Organization') }

    context 'with no block given' do
      it 'should add the given resource_type as a child node' do
        expect do
          parent_node.owns('Project')  
        end.to change { parent_node.children.count }.by(1)
      end

      it 'should create a child node with the given resource_type' do
        parent_node.owns('Project')
        parent_node.children.first.resource_type.should eq 'Project'
      end
    end

    context 'with a block which creates grand children' do
      it 'should add the given resource_type as children' do
        expect do
          parent_node.owns('Project') do
            owns('ProjectProfile')
            owns('Ticket')
          end
        end.to change { parent_node.children.count }.by(1)
      end

      it 'should also add the grand children to the child' do
        parent_node.owns('Project') do
          owns('ProjectProfile')
          owns('Ticket')
        end

        parent_node.children.first.children.map(&:resource_type).should match_array ['ProjectProfile', 'Ticket']
      end
    end

    describe '#children_permissions' do
      
    end
    
    
  end
  
end
