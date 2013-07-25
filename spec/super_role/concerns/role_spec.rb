require 'spec_helper'

describe SuperRole::Role do
  subject { role } 
  
  describe '#can?', :focus do
    subject { role.can?(action, resource_or_resource_type, options) }
    let(:role) { Role.new }

    context 'when action is a group' do

      let(:action) { 'manage' }
      let(:project) { Project.new }
      let(:resource_or_resource_type) { project }

      before do
        role.stub(:find_actions_for_group => ['update', 'destroy'])
      end

      context 'with no options' do
        let(:options) { {} }

        context 'and has_permission_to? returns true for all the actions in the group' do
          it do
            expect(role).to receive(:has_permission_to?).with('update', project).and_return(true)
            expect(role).to receive(:has_permission_to?).with('destroy', project).and_return(true)
            should be_true
          end
        end

        context 'and has_permission_to? returns false for some actions in the group' do
          it do
            expect(role).to receive(:has_permission_to?).with('update', project).and_return(true)
            expect(role).to receive(:has_permission_to?).with('destroy', project).and_return(false)
            should be_false
          end
        end
      end

      context 'with :any option set to true' do
        let(:options) { { any: true } }

        context 'and has_permission_to? returns true for at least one action in the group' do
          it do
            expect(role).to receive(:has_permission_to?).with('update', project).and_return(false)
            expect(role).to receive(:has_permission_to?).with('destroy', project).and_return(true)
            should be_true
          end
        end

        context 'and has_permission_to? returns false for all the actions in the group' do
          it do
            expect(role).to receive(:has_permission_to?).with('update', project).and_return(false)
            expect(role).to receive(:has_permission_to?).with('destroy', project).and_return(false)
            should be_false
          end
        end
      end

    end



  end

end