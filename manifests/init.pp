#
# = Class: heat
#
# This class installs and manages heat
#
#
# == Parameters
#
# Refer to https://github.com/stdmod for official documentation
# on the stdmod parameters used
#
class heat (

  $conf_hash                 = undef,
  $generic_service_hash      = undef,

  $package_name              = $heat::params::package_name,
  $package_ensure            = 'present',

  $service_name              = $heat::params::service_name,
  $service_ensure            = 'running',
  $service_enable            = true,

  $config_file_path          = $heat::params::config_file_path,
  $config_file_replace       = $heat::params::config_file_replace,
  $config_file_require       = 'Package[heat]',
  $config_file_notify        = 'class_default',
  $config_file_source        = undef,
  $config_file_template      = undef,
  $config_file_content       = undef,
  $config_file_options_hash  = undef,
  $config_file_owner         = $heat::params::config_file_owner,
  $config_file_group         = $heat::params::config_file_group,
  $config_file_mode          = $heat::params::config_file_mode,

  $config_dir_path           = $heat::params::config_dir_path,
  $config_dir_source         = undef,
  $config_dir_purge          = false,
  $config_dir_recurse        = true,

  $dependency_class          = undef,
  $my_class                  = undef,

  $monitor_class             = undef,
  $monitor_options_hash      = { } ,

  $firewall_class            = undef,
  $firewall_options_hash     = { } ,

  $scope_hash_filter         = '(uptime.*|timestamp)',

  $tcp_port                  = undef,
  $udp_port                  = undef,

  ) inherits heat::params {


  # Class variables validation and management

  validate_bool($service_enable)
  validate_bool($config_dir_recurse)
  validate_bool($config_dir_purge)
  if $config_file_options_hash { validate_hash($config_file_options_hash) }
  if $monitor_options_hash { validate_hash($monitor_options_hash) }
  if $firewall_options_hash { validate_hash($firewall_options_hash) }

  $manage_config_file_content = default_content($config_file_content, $config_file_template)

  $manage_config_file_notify  = $config_file_notify ? {
    'class_default' => undef,
    ''              => undef,
    default         => $config_file_notify,
  }

  if $package_ensure == 'absent' {
    $manage_service_enable = undef
    $manage_service_ensure = stopped
    $config_dir_ensure = absent
    $config_file_ensure = absent
  } else {
    $manage_service_enable = $service_enable ? {
      ''      => undef,
      'undef' => undef,
      default => $service_enable,
    }
    $manage_service_ensure = $service_ensure ? {
      ''      => undef,
      'undef' => undef,
      default => $service_ensure,
    }
    $config_dir_ensure = directory
    $config_file_ensure = present
  }


  # Resources managed

  if $heat::package_name {
    package { 'heat':
      ensure   => $heat::package_ensure,
      name     => $heat::package_name,
    }
  }

  if $heat::config_file_path {
    file { 'heat.conf':
      ensure  => $heat::config_file_ensure,
      path    => $heat::config_file_path,
      mode    => $heat::config_file_mode,
      owner   => $heat::config_file_owner,
      group   => $heat::config_file_group,
      source  => $heat::config_file_source,
      content => $heat::manage_config_file_content,
      notify  => $heat::manage_config_file_notify,
      require => $heat::config_file_require,
    }
  }

  if $heat::config_dir_source {
    file { 'heat.dir':
      ensure  => $heat::config_dir_ensure,
      path    => $heat::config_dir_path,
      source  => $heat::config_dir_source,
      recurse => $heat::config_dir_recurse,
      purge   => $heat::config_dir_purge,
      force   => $heat::config_dir_purge,
      notify  => $heat::manage_config_file_notify,
      require => $heat::config_file_require,
    }
  }

  if $heat::service_name {
    service { 'heat':
      ensure     => $heat::manage_service_ensure,
      name       => $heat::service_name,
      enable     => $heat::manage_service_enable,
    }
  }


  # Extra classes
  if $conf_hash {
    create_resources('heat::conf', $conf_hash)
  }

  if $generic_service_hash {
    create_resources('heat::generic_service', $generic_service_hash)
  }


  if $heat::dependency_class {
    include $heat::dependency_class
  }

  if $heat::my_class {
    include $heat::my_class
  }

  if $heat::monitor_class {
    class { $heat::monitor_class:
      options_hash => $heat::monitor_options_hash,
      scope_hash   => {}, # TODO: Find a good way to inject class' scope
    }
  }

  if $heat::firewall_class {
    class { $heat::firewall_class:
      options_hash => $heat::firewall_options_hash,
      scope_hash   => {},
    }
  }

}

