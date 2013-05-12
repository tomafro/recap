require 'spec_helper'

describe Recap::Support::CapistranoExtensions do
  let :config do
    Capistrano::Configuration.new
  end

  describe "#edit_file" do
    before do
      Tempfile.any_instance.stubs(:path).returns('path/to/tempfile')
      config.stubs(:as_app)
      Recap::Support::ShellCommand.stubs(:execute_interactive)
      config.stubs(:get)
      config.stubs(:editor).returns("some-editor")
    end

    it 'downloads the file to a temporary file for editing' do
      config.expects(:get).with('remote/path/to/file', 'path/to/tempfile')
      File.stubs(:read).with('path/to/tempfile')
      config.edit_file('remote/path/to/file')
    end

    it 'opens the editor using `execute_interactive` so that Vi works' do
      config.stubs(:editor).returns('vi')
      File.stubs(:read).with('path/to/tempfile')
      Recap::Support::ShellCommand.expects(:execute_interactive).with('vi path/to/tempfile')
      config.edit_file('remote/path/to/file')
    end

    it 'returns the locally edited file contents' do
      File.expects(:read).with('path/to/tempfile').returns('edited contents')
      config.edit_file('remote/path/to/file').should eql('edited contents')
    end

    it 'fails if no EDITOR is set' do
      config.stubs(:editor).returns(nil)
      config.expects(:abort).with(regexp_matches(/To edit a remote file, either the EDITOR or DEPLOY_EDITOR environment variables must be set/))
      config.edit_file('remote/path/to/file')
    end
  end

  describe '#trigger_update?' do
    context 'when forcing full deploy' do
      before(:each) do
        config.stubs(:force_full_deploy).returns(true)
      end

      it 'returns true' do
        config.trigger_update?('path/to/file').should be_true
      end
    end

    context 'when not forcing full deploy' do
      before(:each) do
        config.stubs(:force_full_deploy).returns(false)
        config.stubs(:changed_files).returns(['path/to/changed/file', 'directory/containing/changed/file'])
      end

      it 'returns false for a file path which has not changed' do
        config.trigger_update?('no/changes/here').should be_false
      end

      it 'returns true for a file path which has changed' do
        config.trigger_update?('path/to/changed/file').should be_true
      end

      it 'returns true for a directory path which contains a changed file' do
        config.trigger_update?('directory/containing/changed/').should be_true
      end
    end
  end
end
