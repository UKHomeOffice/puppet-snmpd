# = Class: snmpd
#
# This is the main snmpd class
#
#
# == Parameters
#
# Standard class parameters
# Define the general class behaviour and customizations
#
# [*source*]
#   Sets the content of source parameter for main configuration file
#   If defined, snmpd main config file will have the param: source => $source
#   Can be defined also by the (top scope) variable $snmpd_source
#
# [*source_dir*]
#   If defined, the whole snmpd configuration directory content is retrieved
#   recursively from the specified source
#   (source => $source_dir , recurse => true)
#   Can be defined also by the (top scope) variable $snmpd_source_dir
#
# [*source_dir_purge*]
#   If set to true (default false) the existing configuration directory is
#   mirrored with the content retrieved from source_dir
#   (source => $source_dir , recurse => true , purge => true)
#   Can be defined also by the (top scope) variable $snmpd_source_dir_purge
#
# [*template*]
#   Sets the path to the template to use as content for main configuration file
#   If defined, snmpd main config file has: content => content("$template")
#   Note source and template parameters are mutually exclusive: don't use both
#   Can be defined also by the (top scope) variable $snmpd_template
#
# [*content*]
#   Defines the content of the main configuration file, to be used as alternative
#   to template when the content is populated on other ways.
#   If defined, snmpd main config file has: content => $content
#   Note: source, template and content are mutually exclusive.
#   If a template is defined, that has precedence on the content parameter
#
# [*options*]
#   An hash of custom options to be used in templates for arbitrary settings.
#   Can be defined also by the (top scope) variable $snmpd_options
#
# [*service_autorestart*]
#   Automatically restarts the snmpd service when there is a change in
#   configuration files. Default: true, Set to false if you don't want to
#   automatically restart the service.
#
# [*version*]
#   The package version, used in the ensure parameter of package type.
#   Default: present. Can be 'latest' or a specific version number.
#   Note that if the argument uninstall (see below) is set to true, the
#   package is removed, whatever the value of version parameter.
#
# [*uninstall*]
#   Set to 'true' to remove package(s) installed by module
#   Can be defined also by the (top scope) variable $snmpd_uninstall
#
# [*disable*]
#   Set to 'true' to disable service(s) managed by module
#   Can be defined also by the (top scope) variable $snmpd_disable
#
# [*disableboot*]
#   Set to 'true' to disable service(s) at boot, without checks if it's running
#   Use this when the service is managed by a tool like a cluster software
#   Can be defined also by the (top scope) variable $snmpd_disableboot
#
# [*debug*]
#   Set to 'true' to enable modules debugging
#   Can be defined also by the (top scope) variables $snmpd_debug and $debug
#
# [*audit_only*]
#   Set to 'true' if you don't intend to override existing configuration files
#   and want to audit the difference between existing files and the ones
#   managed by Puppet.
#   Can be defined also by the (top scope) variables $snmpd_audit_only
#   and $audit_only
#
# Default class params - As defined in snmpd::params.
# Note that these variables are mostly defined and used in the module itself,
# overriding the default values might not affected all the involved components.
# Set and override them only if you know what you're doing.
# Note also that you can't override/set them via top scope variables.
#
# [*package*]
#   The name of snmpd package
#
# [*service*]
#   The name of snmpd service
#
# [*service_status*]
#   If the snmpd service init script supports status argument
#
# [*process*]
#   The name of snmpd process
#
# [*process_args*]
#   The name of snmpd arguments. Used by puppi and monitor.
#   Used only in case the snmpd process name is generic (java, ruby...)
#
# [*process_user*]
#   The name of the user snmpd runs with. Used by puppi and monitor.
#
# [*config_dir*]
#   Main configuration directory. Used by puppi
#
# [*config_file*]
#   Main configuration file path
#
# [*config_file_mode*]
#   Main configuration file path mode
#
# [*config_file_owner*]
#   Main configuration file path owner
#
# [*config_file_group*]
#   Main configuration file path group
#
# [*config_file_init*]
#   Path of configuration file sourced by init script
#
# [*pid_file*]
#   Path of pid file. Used by monitor
#
# [*data_dir*]
#   Path of application data directory. Used by puppi
#
# [*log_dir*]
#   Base logs directory. Used by puppi
#
# [*log_file*]
#   Log file(s). Used by puppi
#
# [*port*]
#   The listening port, if any, of the service.
#   This is used by monitor, firewall and puppi (optional) components
#   Note: This doesn't necessarily affect the service configuration file
#   Can be defined also by the (top scope) variable $snmpd_port
#
# [*protocol*]
#   The protocol used by the the service.
#   This is used by monitor, firewall and puppi (optional) components
#   Can be defined also by the (top scope) variable $snmpd_protocol
#
#
# == Examples
#
# You can use this class in 2 ways:
# - Set variables (at top scope level on in a ENC) and "include snmpd"
# - Call snmpd as a parametrized class
#
# See README for details.
#
#
# == Author
#   Alessandro Franceschi <al@lab42.it/>
#
class snmpd (
  $snmpname            = params_lookup( 'snmpname' ),
  $snmplocation        = params_lookup( 'snmplocation' ),
  $snmpcontact         = params_lookup( 'snmpcontact' ),
  $source              = params_lookup( 'source' ),
  $source_dir          = params_lookup( 'source_dir' ),
  $source_dir_purge    = params_lookup( 'source_dir_purge' ),
  $template            = params_lookup( 'template' ),
  $content             = params_lookup( 'content' ),
  $service_autorestart = params_lookup( 'service_autorestart' , 'global' ),
  $options             = hiera_hash( 'options', [] ),
  $users               = params_lookup( 'users' ),
  $version             = params_lookup( 'version' ),
  $uninstall           = params_lookup( 'uninstall' ),
  $disable             = params_lookup( 'disable' ),
  $disableboot         = params_lookup( 'disableboot' ),
  $debug               = params_lookup( 'debug' , 'global' ),
  $audit_only          = params_lookup( 'audit_only' , 'global' ),
  $package             = params_lookup( 'package' ),
  $service             = params_lookup( 'service' ),
  $service_status      = params_lookup( 'service_status' ),
  $process             = params_lookup( 'process' ),
  $process_args        = params_lookup( 'process_args' ),
  $process_user        = params_lookup( 'process_user' ),
  $config_dir          = params_lookup( 'config_dir' ),
  $config_file         = params_lookup( 'config_file' ),
  $config_file_mode    = params_lookup( 'config_file_mode' ),
  $config_file_owner   = params_lookup( 'config_file_owner' ),
  $config_file_group   = params_lookup( 'config_file_group' ),
  $config_file_init    = params_lookup( 'config_file_init' ),
  $pid_file            = params_lookup( 'pid_file' ),
  $data_dir            = params_lookup( 'data_dir' ),
  $log_dir             = params_lookup( 'log_dir' ),
  $log_file            = params_lookup( 'log_file' ),
  $port                = params_lookup( 'port' ),
  $protocol            = params_lookup( 'protocol' )
  ) inherits snmpd::params {

  $bool_source_dir_purge=any2bool($source_dir_purge)
  $bool_service_autorestart=any2bool($service_autorestart)
  $bool_uninstall=any2bool($uninstall)
  $bool_disable=any2bool($disable)
  $bool_disableboot=any2bool($disableboot)
  $bool_debug=any2bool($debug)
  $bool_audit_only=any2bool($audit_only)

  ### Definition of some variables used in the module
  $manage_package = $snmpd::bool_uninstall ? {
    true  => 'absent',
    false => $snmpd::version,
  }

  $require_package = $snmpd::package ? {
    ''      => undef,
    default => $snmpd::package
  }

  $manage_service_enable = $snmpd::bool_disableboot ? {
    true    => false,
    default => $snmpd::bool_disable ? {
      true    => false,
      default => $snmpd::bool_uninstall ? {
        true  => false,
        false => true,
      },
    },
  }

  $manage_service_ensure = $snmpd::bool_disable ? {
    true    => 'stopped',
    default =>  $snmpd::bool_uninstall ? {
      true    => 'stopped',
      default => 'running',
    },
  }

  $manage_service_autorestart = $snmpd::bool_service_autorestart ? {
    true    => Service[snmpd],
    false   => undef,
  }

  $manage_file = $snmpd::bool_uninstall ? {
    true    => 'absent',
    default => 'present',
  }

  $manage_audit = $snmpd::bool_audit_only ? {
    true  => 'all',
    false => undef,
  }

  $manage_file_replace = $snmpd::bool_audit_only ? {
    true  => false,
    false => true,
  }

  $manage_file_source = $snmpd::source ? {
    ''        => undef,
    default   => $snmpd::source,
  }

  $manage_file_content = $snmpd::template ? {
    ''        => undef,
    default   => $snmpd::template,
  }

  ### Managed resources
  package { $snmpd::package:
    ensure => $snmpd::manage_package,
  }

  service { 'snmpd':
    ensure     => $snmpd::manage_service_ensure,
    name       => $snmpd::service,
    enable     => $snmpd::manage_service_enable,
    hasstatus  => $snmpd::service_status,
    pattern    => $snmpd::process,
    require    => Package["$snmpd::package"],
  }

  datacat { "${snmpd::config_file}":
    path     => $snmpd::config_file,
    mode     => $snmpd::config_file_mode,
    owner    => $snmpd::config_file_owner,
    group    => $snmpd::config_file_group,
    require  => Package[$snmpd::require_package],
    notify   => $snmpd::manage_service_autorestart,
    template => $snmpd::manage_file_content,
    replace  => $snmpd::manage_file_replace,
    audit    => $snmpd::manage_audit,
  }

  datacat_fragment { 'snmp.options':
    target => $snmpd::config_file,
      data =>  {
        syslocation => $snmpd::snmplocation,
        sysname     => $snmpd::snmpname,
        syscontact  => $snmpd::snmpcontact,
      },
  }

  # Hiera can be used to create specific logic for define "create_snmpusm"
  create_resources('snmpd::create_snmpusm', $snmpd::options)

  # The whole snmpd configuration directory can be recursively overriden
  if $snmpd::source_dir {
    file { 'snmpd.dir':
      ensure  => directory,
      path    => $snmpd::config_dir,
      require => $require_package,
      notify  => $snmpd::manage_service_autorestart,
      source  => $snmpd::source_dir,
      recurse => true,
      purge   => $snmpd::bool_source_dir_purge,
      replace => $snmpd::manage_file_replace,
      audit   => $snmpd::manage_audit,
    }
  }

  ### Debugging, if enabled ( debug => true )
  if $snmpd::bool_debug == true {
    file { 'debug_snmpd':
      ensure  => $snmpd::manage_file,
      path    => "${settings::vardir}/debug-snmpd",
      mode    => '0640',
      owner   => 'root',
      group   => 'root',
      content => inline_template('<%= scope.to_hash.reject { |k,v| k.to_s =~ /(uptime.*|path|timestamp|free|.*password.*|.*psk.*|.*key)/ }.to_yaml %>'),
    }
  }

}
