# Manage the FAI configuration.
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


