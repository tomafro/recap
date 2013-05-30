require 'spec_helper'

describe Recap::Support::CLI do
  subject { Recap::Support::CLI.new }

  describe 'ssh' do

    puts `env`
    puts "B"
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

    puts `ssh -F recap-ssh-config default env`
    puts "C"
    p `ssh 127.0.0.1 env`

  end
end
