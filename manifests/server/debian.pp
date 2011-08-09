# Install the FAI server on a Debian system.
class fai::server::debian($suite, $mirror)
{
	case $lsbdistcodename {
		squeeze: {}
		default: { fail("$lsbdistcodename is currently unsupported") }
	}

	package { fai-server:
		ensure => present
	}

	# Define additional variables for use in the template.
	$debootstrap = "$suite $mirror"

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
