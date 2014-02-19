# = Class: heat::example42
#
# Example42 puppi additions. To add them set:
#   my_class => 'heat::example42'
#
class heat::example42 {

  puppi::info::module { 'heat':
    packagename => $heat::package_name,
    servicename => $heat::service_name,
    processname => 'heat',
    configfile  => $heat::config_file_path,
    configdir   => $heat::config_dir_path,
    pidfile     => '/var/run/heat.pid',
    datadir     => '',
    logdir      => '/var/log/heat',
    protocol    => 'tcp',
    port        => '5000',
    description => 'What Puppet knows about heat' ,
    # run         => 'heat -V###',
  }

  puppi::log { 'heat':
    description => 'Logs of heat',
    log         => [ '/var/log/heat/api.log' , '/var/log/heat/registry.log' ],
  }

}
