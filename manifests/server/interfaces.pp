# Configure the network interfaces of an FAI server.
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
