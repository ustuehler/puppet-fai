# Configure the ISC DHCP service on an FAI server.
class fai::server::dhcpd($network, $netmask, $domain,
    $domain_name_servers, $routers)
{
	require fai::server::dnsmasq
	require fai::server::interfaces

	package { isc-dhcp-server: }

	service { isc-dhcp-server:
		ensure => running,
		hasstatus => true,
		require => Package[isc-dhcp-server]
	}

	$target = "/etc/dhcp/dhcpd.conf"

	concat { $target:
		owner => root,
		group => root,
		mode => 444,
		notify => Service[isc-dhcp-server],
		require => Package[isc-dhcp-server]
	}

	concat::fragment { "dhcpd.conf":
		target => $target,
		content => template("fai/dhcpd.conf")
	}
}
