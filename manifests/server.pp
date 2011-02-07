# Set up an FAI server for installing Linux in a fully automated fashion.
# A future goal for this class is to support operating systems other than
# Linux as the server.
#
# This class has been initially developed on Debian "squeeze".  Any other
# versions and other Debian-based distributions such as Ubuntu may or may
# not work out of the box.  However, since FAI setup involves many things
# and I've recently expericed many problems with setting up FAI on Ubuntu,
# I have decided to make this class proceed only on operating systems and
# releases which are known to work.
#
# Parameters (prefix: $linux_fai_server_):
#
# - debootstrap_suite: The distribution name of the Debian system (e.g.
#   sarge, etch, lenny, sid). Default: "squeeze"
# - debootstrap_mirror: The URL of a Debian mirror to retrieve packages
#   from.  The URL scheme can be http, file or ssh.  Default:
#   "http://ftp.debian.org/debian"
#
# Requires:
#
# - Class[puppet]
#   - File[$puppet::moduledatadir]
class fai::server
{
	case $operatingsystem {
		Debian: { require fai::server::debian }
		default: { fail("$operatingsystem is currently unsupported") }
	}

	require fai::server::interfaces
	require fai::server::configdir
	require fai::server::dnsmasq
	require fai::server::dhcpd
	require fai::server::nfs
	require fai::server::nat
}

class fai::server::debian
{
	case $lsbdistcodename {
		squeeze: {}
		default: { fail("$lsbdistcodename is currently unsupported") }
	}

	$debootstrap_suite = $linux_fai_server_debootstrap_suite ? {
		'' => "squeeze",
		default => $linux_fai_server_debootstrap_suite
	}

	$debootstrap_mirror = $linux_fai_server_debootstrap_mirror ? {
		'' => "http://ftp.debian.org/debian",
		default => $linux_fai_server_debootstrap_mirror
	}

	package { fai-server: }

	# Define additional variables for use in the template.
	$debootstrap = "$debootstrap_suite $debootstrap_mirror"

	file { '/etc/fai/make-fai-nfsroot.conf':
		content => template("fai/make-fai-nfsroot.conf"),
		owner => root,
		group => 0,
		mode => 444,
		require => Package[fai-server]
	}

	include puppet

	if ! $puppet::moduledatadir {
		fail("\$puppet::moduledatadir is not set")
	}

	file { ["$puppet::moduledatadir/fai",
	        "$puppet::moduledatadir/fai/server"]:
		ensure => directory,
		owner => root,
		group => 0,
		mode => 755
	}

	# This can take a very long time, so to be sure we don't continue
	# before this is done we set a timeout here.  If the download speed
	# is at least 100 KB/s, then one hour should be enough to download
	# about 300 MB.
	$cookie = "$puppet::moduledatadir/fai/server/fai-setup.done"
	exec { "/usr/sbin/fai-setup && touch $cookie":
		alias => fai-setup,
		creates => $cookie,
		logoutput => on_failure,
		timeout => 3600, # 1h
		require => [File["/etc/fai/make-fai-nfsroot.conf"],
		            File["$puppet::moduledatadir/fai/server"]]
	}

	exec { "/usr/sbin/fai-chboot -IB default":
		creates => "/srv/tftp/fai/pxelinux.cfg/default",
		require => Exec[fai-setup]
	}
}

class fai::server::configdir
{
	file { "/srv/fai/config":
		ensure => directory,
		source => ["puppet:///files/fai/config",
		           "puppet:///fai/config"],
		recurse => true,
		purge => true,
		backup => false,
		force => true,
		owner => root,
		group => 0,
		require => Exec[fai-setup]
	}
}

class fai::server::dhcpd
{
	require fai::server::dnsmasq
	require fai::server::interfaces

	package { isc-dhcp-server: }

	service { isc-dhcp-server:
		ensure => running,
		hasstatus => true,
		require => Package[isc-dhcp-server]
	}

	file { "/etc/dhcp/dhcpd.conf":
		content => template("fai/dhcpd.conf"),
		owner => root,
		group => root,
		mode => 444,
		notify => Service[isc-dhcp-server],
		require => Package[isc-dhcp-server]
	}
}

class fai::server::dnsmasq
{
	package { dnsmasq: }

	service { dnsmasq:
		ensure => running,
		hasstatus => true,
		require => Package[dnsmasq]
	}

	file { "/etc/dnsmasq.conf":
		content => template("fai/dnsmasq.conf"),
		owner => root,
		group => root,
		mode => 444,
		notify => Service[dnsmasq],
		require => Package[dnsmasq]
	}

	host { "fai-server.virtual.box":
		ip => '172.16.1.1',
		notify => Service[dnsmasq]
	}

	host { "fai-client.virtual.box":
		ip => '172.16.1.2',
		notify => Service[dnsmasq]
	}
}

class fai::server::nfs
{
	package { nfs-kernel-server: }

	service { nfs-kernel-server:
		ensure => running,
		hasstatus => true,
		require => Package[nfs-kernel-server]
	}

	file { "/etc/exports":
		content => template("fai/exports"),
		owner => root,
		group => root,
		mode => 444,
		notify => Service[nfs-kernel-server],
		require => Class['fai::server::debian']
	}
}

class fai::server::interfaces
{
	file { "/etc/network/interfaces":
		content => template("fai/interfaces"),
		owner => root,
		group => root,
		mode => 444,
		notify => Exec[restart-networking]
	}

	exec { "/etc/init.d/networking restart":
		alias => restart-networking,
		refreshonly => true
	}
}

class fai::server::nat
{
	file { "/etc/rc.local":
		content => template("fai/rc.local"),
		owner => root,
		group => root,
		mode => 755,
		notify => Exec["/etc/rc.local"]
	}

	exec { "/etc/rc.local":
		refreshonly => true,
		require => File["/etc/rc.local"]
	}
}
