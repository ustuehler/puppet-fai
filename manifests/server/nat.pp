# Configure the FAI server as a NAT gateway for FAI clients.
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
