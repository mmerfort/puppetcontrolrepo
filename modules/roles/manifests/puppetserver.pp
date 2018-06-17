class roles::puppetserver {
  # foreman plugins depends on puppetdb
  # foreman_proxy depends on foreman (which can be installed on a different node, that's why this is a single profile)
  # puppetserver depends on puppetdb
  # foreman wants to setup postgres form centos if it gets included before puppetdb
  include profiles::basics
  include profiles::puppetserver
  include profiles::puppetserverproxy
  include profiles::puppetdb
  include profiles::foreman
  include profiles::choriaclient
  include profiles::choriaserver
  Clas['Profiles::Basics']
  -> Class['Profiles::Puppetdb']
  -> Class['profiles::Puppetserver']
  -> Class['Profiles::Foreman']
  -> Class['Profiles::Puppetserverproxy']
}