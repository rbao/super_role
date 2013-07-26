require 'spec_helper'

describe SuperRole::Role do
  subject { role } 
  
  describe '#can?' do
    subject { role.can?(action, resource_or_resource_type, options) }
    let(:role) { Role.new }

    shared_examples 'should return whatever #has_permission_to? returns' do
      context 'and has_permission_to? returns true' do
        it do
          expect(role).to receive(:has_permission_to?).with(actual_action, project).and_return(true)
          should be_true
        end
      end

      context 'and has_permission_to? returns false the actions' do
        it do
          expect(role).to receive(:has_permission_to?).with(actual_action, project).and_return(false)
          should be_false
        end
      end
    end

    context 'given an action and resource' do
      let(:action) { 'update' }
      let(:actual_action) { action }
      let(:project) { Project.new }
      let(:resource_or_resource_type) { project }
      let(:options) { {} }

      include_examples 'should return whatever #has_permission_to? returns'
    end

    context 'given an action and resource_type' do
      let(:action) { 'update' }
      let(:resource_or_resource_type) { Project }
      let(:options) { {} }

      context 'and has_permission_to? returns true' do
        it do
          expect(role).to receive(:has_permission_to?).with(action, kind_of(Project)).and_return(true)
          should be_true
        end
      end

      context 'and has_permission_to? returns false the actions' do
        it do
          expect(role).to receive(:has_permission_to?).with(action, kind_of(Project)).and_return(false)
          should be_false
        end
      end
    end

    context 'given an action alias and resource' do
      let(:action) { 'remove' }
      let(:actual_action) { 'destroy' }
      let(:project) { Project.new }
      let(:resource_or_resource_type) { project }
      let(:options) { {} }
      let(:action_alias) { double(:action => actual_action) }

      before { SuperRole::ActionAlias.stub(:find => action_alias) }
      include_examples 'should return whatever #has_permission_to? returns'
    end

    context 'given an action group and resource' do
      let(:action) { 'manage' }
      let(:project) { Project.new }
      let(:resource_or_resource_type) { project }
      let(:action_group) { double(:actions => ['update', 'destroy']) }

      before do
        SuperRole::ActionGroup.stub(:find => action_group)
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

    context 'given an array of action, action group and alias and a resource' do
      let(:action) { ['show', 'manage', 'remove'] }
      let(:project) { Project.new }
      let(:resource_or_resource_type) { project }
      let(:action_group) { double(:actions => ['create', 'update']) }
      let(:action_alias) { double(:action => 'destroy') }

      before do
        SuperRole::ActionGroup.stub(:find).and_return(nil)
        SuperRole::ActionGroup.stub(:find).with('manage', Project).and_return(action_group)


        SuperRole::ActionAlias.stub(:find).and_return(nil)
        SuperRole::ActionAlias.stub(:find).with('remove', Project).and_return(action_alias)
      end

      context 'with no options' do
        let(:options) { {} }

        context 'and has_permission_to? returns true for all the actual actions' do
          it do
            expect(role).to receive(:has_permission_to?).with('show', project).and_return(true)
            expect(role).to receive(:has_permission_to?).with('create', project).and_return(true)
            expect(role).to receive(:has_permission_to?).with('update', project).and_return(true)
            expect(role).to receive(:has_permission_to?).with('destroy', project).and_return(true)
            should be_true
          end
        end

        context 'and has_permission_to? returns false for one of the actual actions' do
          it do
            expect(role).to receive(:has_permission_to?).with('show', project).and_return(true)
            expect(role).to receive(:has_permission_to?).with('create', project).and_return(false)
            should be_false
          end
        end
      end

      context 'with :any option set to true' do
        let(:options) { { any: true } }

        context 'and has_permission_to? returns true for one of the actual actions' do
          it do
            expect(role).to receive(:has_permission_to?).with('show', project).and_return(false)
            expect(role).to receive(:has_permission_to?).with('create', project).and_return(true)
            should be_true
          end
        end

        context 'and has_permission_to? returns false for all the actual actions' do
          it do
            expect(role).to receive(:has_permission_to?).with('show', project).and_return(false)
            expect(role).to receive(:has_permission_to?).with('create', project).and_return(false)
            expect(role).to receive(:has_permission_to?).with('update', project).and_return(false)
            expect(role).to receive(:has_permission_to?).with('destroy', project).and_return(false)
            should be_false
          end
        end
      end
    end
  end

  describe '#has_permission_to?' do
    subject { role.has_permission_to?(action, resource) }
    let(:role) { Role.new }
    let(:action) { 'any_action' }
    let(:resource) { 'any_resource' }

    context 'when one related resource permission includes the resource' do
      let(:rp1) { double(:include_resource? => false) }
      let(:rp2) { double(:include_resource? => true) }

      before do
        role.stub_chain(:resource_permissions, :related_to => [rp1, rp2])
      end

      it { should be_true }
    end

    context 'when no related resource permission includes the resource' do
      let(:rp1) { double(:include_resource? => false) }
      let(:rp2) { double(:include_resource? => false) }

      before do
        role.stub_chain(:resource_permissions, :related_to => [rp1, rp2])
      end

      it { should be_false }
    end
  end

  describe '#permission_hierarchy' do
    subject { role.permission_hierarchy }
    let(:role) { Role.new }
    let(:hierarchy) { double(:resource_type => 'some_type') }

    before do
      role.stub(:owner_type => 'some_type')
    end

    it 'should return the permission_hierarchy corresponding to the role\'s owner' do
      SuperRole::PermissionHierarchy.stub(:find => hierarchy)
      should eq hierarchy
    end

    it 'should not try to find the permission_hierarchy again if it was already found' do
      expect(SuperRole::PermissionHierarchy).to receive(:find).and_return(hierarchy).once
      role.permission_hierarchy
      role.permission_hierarchy
    end

    it 'should try to find the new permission_hierarchy if the owner_type changed' do
      expect(SuperRole::PermissionHierarchy).to receive(:find).and_return(hierarchy).twice
      role.permission_hierarchy
      role.stub(:owner_type => 'another_type')
      role.permission_hierarchy
    end
  end

end