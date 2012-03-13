group { 'puppet':
  ensure => 'present'
}

package { ['git-core', 'curl']:
  ensure => present
}

package { 'bundler':
  provider => gem,
  ensure => '1.1.rc.7'
}

package { 'foreman':
  provider => gem,
  ensure => present
}
