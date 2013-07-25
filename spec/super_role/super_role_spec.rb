require 'spec_helper'

describe 'SuperRole' do
  
  describe '.define_permissions' do
    let(:block_result) { 'hi' }
    
    it 'should pass the block to PermissionDefiner.run' do
      expect(SuperRole::PermissionDefiner).to receive(:run) do |&block|
        expect(block.call).to eq block_result
      end
      SuperRole.define_permissions { block_result }
    end
  end

  describe '.define_role_owner_permission_hierarchy' do
    let(:block_result) { 'hi' }
    
    it 'should pass the block to PermissionHierarchyDefiner.run' do
      expect(SuperRole::PermissionHierarchyDefiner).to receive(:run) do |&block|
        expect(block.call).to eq block_result
      end
      SuperRole.define_role_owner_permission_hierarchy { block_result }
    end
  end
  
end