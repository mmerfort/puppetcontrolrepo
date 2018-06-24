class profiles::choriaserver {
  if($facts['os']['name'] == 'CentOS') {
    package{'libffi-devel':
      ensure => 'present',
      before => Class['mcollective'],
    }
  }
  include gcc
  include make
  include mcollective
  include choria

  Class['make']
  -> Class['mcollective']

  Class['gcc']
  -> Class['mcollective']
}
