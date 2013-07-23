require 'spec_helper'

describe SuperRole::Role do
  subject { role } 
  
  describe '#can?' do
    subject { role.can?(action, resource_or_resource_type) }
    let(:role) { Role.new }

    context 'when action is an group' do
      let(:action) { 'manage' }
      let(:all_project) { Project.new }
      let(:resource_or_resource_type) { all_project }

      before do
        role.stub(:find_actions_for_group => ['update', 'destroy'])
      end

      it 'should call has_permission? with the right arguments' do
        expect(role).to receive(:has_permission_to?).with(['update', 'destroy'], all_project)
        subject
      end
    end

    context 'when action is an alias' do
      let(:action) { 'remove' }
      let(:all_project) { Project.new }
      let(:resource_or_resource_type) { all_project }

      before do
        role.stub(:find_action_for_alias => 'destroy')
      end

      it 'should call has_permission? with the right arguments' do
        expect(role).to receive(:has_permission_to?).with(['destroy'], all_project)
        subject
      end
    end
  end

  describe '#has_permission_to?' do
    
  end
end