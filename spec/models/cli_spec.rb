require 'spec_helper'

describe Recap::Support::CLI do
  subject { Recap::Support::CLI.new }

  describe "#setup" do
    it 'determines the git repository URL' do
      Recap::Support::ShellCommand.stubs(:execute).with('git config --get remote.origin.url').returns(%{git@github.com:freerange/recap.git})
      subject.stubs(:template)
      subject.setup
      subject.repository.should eql('git@github.com:freerange/recap.git')
    end

    it 'handles exception when no git repository present and uses <unkown>' do
      Recap::Support::ShellCommand.stubs(:execute).with('git config --get remote.origin.url').raises
      subject.stubs(:template)
      subject.expects(:warn)
      lambda { subject.setup }.should_not raise_error
      subject.repository.should eql('<unknown>')
    end
  end
end
