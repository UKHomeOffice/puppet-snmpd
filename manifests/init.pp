# == Class: snmpd
#
# This module manages snmpd
#
# == Parameters:
#
# Standard class parameters
# These parameters can be applied to almost any service especially those
# that depend on the OS's native package and init service utilities
#
# [*config_file_source*]
# This is used to set the value of the File resources "source" parameter
# The value is used to point to snmpd's main configuration file:
# source => $file_source
#
# [*dir_source*]
# If defined the files located in this source directory are retrieved
# recursively:
# source => $dir_source and recurse => true
#
# [*dir_purge*]
# if set to true and source_dir is set then mirror the configuration
# directory with the contents retrieved from $dir_source
# Default: false
#
# [*config_file_template*]
# This is used to set the path of the File resources "content" parameter
# This value is used as the template for snmpd's main configuration file:
# content => $file_template
#
# [*service_autorestart*]
# Set to "true" to restart the packages service if the main configuration file
# has changed.
# Default: true
#
# [*version*]
# This is used as a convenient way to set the version of the package needed to
# be installed.
# Value can be "present", "latest" or underlying package managers package
# version name.
# if packages ensure is set to absent package will be removed regardless of
# $version value.
# Default: present
#
# [*uninstall*]
# Set to true to remove package
# Default: false
#
# [*service_ensure*]
# Set to 'true' to stop the service
# Default: 'true'
#
# [*service_enable*]
# Set to 'true' to disable the service at boot. This does not stop the service
# from running
# Default: 'false'
#
# [*debug*]
# Set to 'true' to enable modules debugging
#
# [*audit_only*]
# Set to 'true' if you do not want to override existing configuration files
#
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class snmpd (

  $snmpname             = $::fqdn,
  $snmplocation         = 'Server Room',
  $snmpcontact          = 'root@localhost',

  $ensure               = 'present',
  $version              = undef,
  $audit_only           = undef,

  $package_name         = $snmpd::params::package_name,

  $service_name         = $snmpd::params::service_name,
  $service_ensure       = running,
  $service_enable       = true,

  $config_file          = $snmpd::params::config_file,
  $config_file_owner    = $snmpd::params::config_file_owner,
  $config_file_group    = $snmpd::params::config_file_group,
  $config_file_mode     = $snmpd::params::config_file_mode,
  $config_file_replace  = true,
  $config_file_content  = undef,
  $config_file_source   = undef,
  $config_file_template = $snmpd::params::config_file_template,

  $config_dir_path      = $snmpd::params::config_dir_path,
  $config_dir_source    = undef,
  $config_dir_purge     = false,
  $config_dir_recurse   = false,

  $conf_hash            = undef

  ) inherits snmpd::params {

  # Parameter validation
  validate_re($ensure, ['present','absent'], 'Valid values are: present, absent. WARNING: If set to absent all the resources managed by the module are removed.')
  validate_bool($config_file_replace)
  validate_bool($service_enable)
  validate_bool($config_dir_purge)
  validate_bool($config_dir_recurse)
  if $conf_hash { validate_hash($conf_hash) }

  if $snmpd::config_file_content {
    $managed_file_content = $snmpd::config_file_content
  } else {
    if $snmpd::config_file_template {
      $managed_file_content = $snmpd::config_file_template
    } else {
      $managed_file_content = undef
    }
  }
  # Determine behaviour of module based on the values used

  if $snmpd::version {
    $managed_package_ensure = $snmpd::version
  } else {
    $managed_packaged_ensure = $snmpd::ensure
  }

  if $snmpd::ensure == 'absent' {
    $managed_service_enable = undef
    $managed_service_ensure = stopped
    $dir_ensure = absent
    $file_ensure = absent
  } else {
    $managed_service_enable = $snmpd::service_enable
    $managed_service_ensure = $snmpd::service_ensure
    $dir_ensure = directory
    $file_ensure = present
  }

  # Managed Resources

  if $snmpd::package_name {
    package { $snmpd::package_name:
      ensure => $snmpd::managed_package_ensure,
    }
  }

  if $snmpd::service_name {
    service { $snmpd::service_name:
      ensure  => $snmpd::managed_service_ensure,
      enable  => $snmpd::managed_service_enable,
      require => Package[$snmpd::package_name]
    }
  }

  if $snmpd::config_file and $snmpd::config_file_content {
    file { 'snmpd.conf':
      ensure  => $snmpd::config_file_ensure,
      path    => $snmpd::config_file,
      mode    => $snmpd::config_file_mode,
      owner   => $snmpd::config_file_owner,
      group   => $snmpd::config_file_group,
      require => Package[$snmpd::package_name],
      notify  => Service[$snmpd::service_name],
      source  => $snmpd::config_file_source,
      replace => $snmpd::config_file_replace,
      audit   => $snmpd::manage_audit,
    }
  } else {
    if $snmpd::config_file {
      datacat { $snmpd::config_file:
        path     => $snmpd::config_file,
        mode     => $snmpd::config_file_mode,
        owner    => $snmpd::config_file_owner,
        group    => $snmpd::config_file_group,
        notify   => Service[$snmpd::service_name],
        require  => Package[$snmpd::package_name],
        template => $snmpd::managed_file_content,
        replace  => $snmpd::config_file_replace,
      }

      datacat_fragment { 'snmpd.options':
	target => $snmpd::config_file,
	data   => {
	  sysname     => $snmpd::snmpname,
	  syslocation => $snmpd::snmplocation,
	  syscontact  => $snmpd::snmpcontact,
	},
      }
    }
  }

  if $snmpd::config_dir_source {
    file { 'snmpd.dir':
      ensure  => $snmpd::config_dir_ensure,
      path    => $snmpd::config_dir,
      source  => $snmpd::config_dir_source,
      recurse => $snmpd::config_dir_recurse,
      purge   => $snmpd::config_dir_purge,
      force   => $snmpd::config_dir_purge,
      notify  => Service[$snmpd::service_name],
      require => Package[$snmpd::package_name],
    }
  }

  # Supplying a hash value allows v3/usm snmp users to created
  # form hiera
  if $conf_hash {
    create_resources(create_usmsnmp, $conf_hash)
  }
}
