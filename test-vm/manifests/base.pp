
group { 'puppet':
  ensure => 'present',
}

package { 'git-core':
  ensure => present
}