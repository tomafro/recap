require 'spec_helper'

describe 'deploying a project' do
  let(:server) { Server.instance }
  let(:project) { Project.new(type: 'ruby', server: server) }

  # it 'deploying for the first time' do
  #   project.run_cap 'bootstrap'
  #   project.run_cap 'deploy:setup'
  #   project.run_cap 'deploy'
  #   expect(deployed_version(project)).to eql(project.latest_version)
  # end

  # it 'deploying changes' do
  #   project.run_cap 'bootstrap'
  #   project.run_cap 'deploy:setup'
  #   project.run_cap 'deploy'
  #   project.repository.write_and_commit('new-file', 'new-file-content')
  #   project.run_cap 'deploy'
  #   expect(deployed_version(project)).to eql(project.latest_version)
  # end

  # it 'rolling back changes' do
  #   project.run_cap 'bootstrap'
  #   project.run_cap 'deploy:setup'
  #   project.run_cap 'deploy'
  #   previous_version = project.latest_version

  #   project.repository.write_and_commit('new-file', 'new-file-content')
  #   project.run_cap 'deploy'
  #   expect(deployed_version(project)).to_not eql(previous_version)

  #   project.run_cap 'deploy:rollback'

  #   expect(deployed_version(project)).to eql(previous_version)
  # end

  def deployed_version(project)
    server.run("cd #{project.deployment_path} && git rev-parse HEAD").strip
  end
end
