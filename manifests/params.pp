# Class: heat::params
#
# Defines all the variables used in the module.
#
class heat::params {

  $package_name = $::osfamily ? {
    'RedHat' => 'openstack-heat-common',
    default  => 'heat-common',
  }

  $service_name = $::osfamily ? {
    default => '',
  }

  $config_file_path = $::osfamily ? {
    default => '',
  }

  $config_file_mode = $::osfamily ? {
    default => '0644',
  }

  $config_file_owner = $::osfamily ? {
    default => 'heat',
  }

  $config_file_group = $::osfamily ? {
    default => 'heat',
  }

  $config_dir_path = $::osfamily ? {
    default => '/etc/heat',
  }

  case $::osfamily {
    'Debian','RedHat','Amazon': { }
    default: {
      fail("${::operatingsystem} not supported. Review params.pp for extending support.")
    }
  }
}
