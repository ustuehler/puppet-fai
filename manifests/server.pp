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
# == Parameters
#
# - linux_fai_server_debootstrap_suite: The distribution name of the Debian
#   system (e.g. sarge, etch, lenny, sid). Default: "squeeze"
#
# - linux_fai_server_debootstrap_mirror: The URL of a Debian mirror to
#   retrieve packages from.  The URL scheme can be http, file or ssh.
#   Default: "http://ftp.debian.org/debian"
#
# == Requires
#
# - Class[puppet]
#   - File[$puppet::moduledatadir]
#
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
