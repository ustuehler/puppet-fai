# Configure the dnsmasq service for an FAI server.
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
}
