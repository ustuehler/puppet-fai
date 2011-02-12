# Configure the NFS service for an FAI server.
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
