# Create an FAI client configuration.
define fai::client($macaddress, $ipaddress = undef, $domain = $domain)
{
	include fai::server::dhcpd

	host { "$name.$domain":
		ip => $ipaddress,
		notify => Service[dnsmasq]
	}

	concat::fragment { "dhcpd.conf.client($name)":
		target => $fai::server::dhcpd::target,
		order => 20,
		content => template("fai/dhcpd.conf.client")
	}
}
