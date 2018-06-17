# Puppet All In One Stack on CentOS 7

This guide will provision an all in one stack on CentOS 7. It is based on the
new [Hetzner Online](https://www.hetzner.de/cloud) cloud instances.

* [Setup](#setup)
    * [Basics Profile](#basics-profile)
    * [GitLab Profile](#gitlab-profile)
* [Provision script](#provision-script)
* [Constraints](#constraints)
* [Related issues and pull requests](#related-issues-and-pull-requests)

---

## Setup

We provide profiles for the following services:

* [Basics](modules/profiles/manifests/basics.pp)
* [Puppetserver](modules/profiles/manifests/puppetserver.pp)
    * [Foreman Proxy](modules/profiles/manifests/foremanproxy.pp)
* [PuppetDB](modules/profiles/manifests/puppetdb.pp)
* [Foreman](modules/profiles/manifests/foreman.pp)
* [Choria Server](modules/profiles/manifests/choriaserver.pp)
* [Choria Client](modukes/profiles/manifests/choriaclient.pp)
* [GitLab](modules/profiles/manifestsgitlab.pp)


### `basics` Profile

This profile handles common utilities that are shared across every potential
node. Currently this is the firewall handling. The `ferm` class is included
with needed parameters. They are set in hiera as well, but that is a bit tricky
if you run `puppet apply`. All other profiles, that require open ports, include
the ferm class as well. You need to ensure to evaluate the `basics` class
before any other class.

ToDo: Implement handling of common packages

### `gitlab` Profile

Everybody wants a central collaboration platform, with chat software, git
hosting, issue handling and CI/CD stack, right? GitLab provides all of that!

## Provision script

First of we need to fix selinux:

```bash
# /etc/sysconfig/selinux is the wrong file
sed -i 's/SELINUX=disabled/SELINUX=enforcing/' /etc/selinux/config
touch /.autorelabel
reboot
```

Afterwards we start the real setup:

```bash
yum update --assumeyes
yum install --assumeyes https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm
yum install --assumeyes puppet puppetserver
source /etc/profile.d/puppet-agent.sh
puppet module install puppet-r10k
puppet cert generate puppet.local --dns_alt_names=puppet.local,puppet,puppetdb,puppetdb.local
puppet apply -e 'include r10k'
sed -i 's#remote:.*#remote: https://github.com/bastelfreak/puppetcontrolrepo.git#' /etc/puppetlabs/r10k/r10k.yaml
r10k deploy environment --puppetfile --verbose
puppet apply -e 'include roles::puppetserver'
```

## Constraints

The FQDN of the puppserver node should be `puppet.local`. The certificate is
valid for `puppet` and `puppet.local`. We create an entry in `/etc/hosts` for
each client, so it can reach the server under that FQDN and we don't need to
deal with DNS.

## Related issues and pull requests

During the work on this project we run into several issues. They are documented below

* https://github.com/puppetlabs/puppetlabs-puppetdb/pull/251
* https://github.com/theforeman/puppet-puppet/pull/600
* https://github.com/voxpupuli/puppet-make/pull/29
* https://github.com/choria-io/mcollective-choria/pull/514
* https://github.com/choria-io/puppet-mcollective/pull/184
* https://github.com/joshuabaird/foreman_noenv/issues/19
* https://github.com/teemow/prometheus-borg-exporter/pull/6
* https://github.com/puppetlabs/puppetlabs-gcc/pull/17
* https://tickets.puppetlabs.com/browse/MODULES-7317
* https://tickets.puppetlabs.com/browse/MODULES-4124
* https://tickets.puppetlabs.com/browse/MODULES-4266