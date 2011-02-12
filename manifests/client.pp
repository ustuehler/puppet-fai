# Create an FAI client configuration.
define fai::client($macaddress, $ipaddress = undef)
{
	include fai::server::dhcpd

	host { "$name.virtual.box":
		ip => $ipaddress,
		notify => Service[dnsmasq]
	}

	concat::fragment { "dhcpd.conf.client($name)":
		target => $fai::server::dhcpd::target,
		order => 20,
		content => template("fai/dhcpd.conf.client")
	}
}
