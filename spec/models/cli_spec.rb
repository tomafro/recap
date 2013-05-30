require 'spec_helper'

describe Recap::Support::CLI do
  subject { Recap::Support::CLI.new }

  describe 'ssh' do

    p `env`

    File.write('recap-ssh-config', %{
Host default
  HostName 127.0.0.1
  Port 22
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentitiesOnly yes
  LogLevel FATAL
      })

    p `ssh -F recap-ssh-config env`
    p `ssh 127.0.0.1 env`

  end
end
