group { 'puppet':
  ensure => 'present'
}

package { 'git-core':
  ensure => present
}

package { 'bundler':
  provider => gem,
  ensure => '1.1.rc.7'
}