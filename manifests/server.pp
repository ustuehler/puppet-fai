# Set up an FAI server
#
# This class has been initially developed on Debian 6.x (squeeze).  Other
# versions and other Debian-based distributions such as Ubuntu may or may
# not work out of the box.  However, since FAI setup involves many things
# and I've recently expericed many problems with setting up FAI on Ubuntu,
# I have decided to make this class proceed only on operating systems and
# releases which are known to work.
#
# == Parameters
#
# - suite: The distribution name of the Debian system (e.g. sarge, etch,
#   lenny, sid). Default: 'squeeze'
#
# - mirror: The URL of a Debian mirror to retrieve packages from.  The
#   URL scheme can be http, file or ssh.
#
class fai::server($suite = 'squeeze',
  $mirror = 'http://ftp.debian.org/debian')
{
  case $::operatingsystem {
    Debian: {
      $class = 'fai::server::debian'
    }

    default: {
      fail("${::operatingsystem} is currently unsupported")
    }
  }

  class {
    $class:
      suite  => $suite,
      mirror => $mirror;

# XXX: It's not the responsibility of this class to set up a DHCP server.
#
# There might already be another DHCP server running on the network and
# if one wants to run FAI and DHCP server on the same node, that can be
# arranged for in a site-specific class.
#
# On the other hand, we could provide a wrapper class for convenience?
#
#    'fai::server::dhcpd':
#      network             => $network,
#      netmask             => $netmask,
#      domain              => $domain,
#      domain_name_servers => $domain_name_servers,
#      routers             => $routers;
  }

  require $class
  require fai::server::interfaces
  require fai::server::configdir
  require fai::server::dnsmasq
  #require fai::server::dhcpd
  require fai::server::nfs
  require fai::server::nat
}
