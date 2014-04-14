# == Class: itv_snmpd_hiera
#
# This module manages itv_snmpd_hiera
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
class itv_snmpd_hiera (

  $snmpname             = $::fqdn,
  $snmplocation         = 'Server Room',
  $snmpcontact          = 'root@localhost',

  $ensure               = 'present',
  $version              = undef,
  $audit_only           = undef,

  $package_name         = $itv_snmpd_hiera::params::package_name,

  $service_name         = $itv_snmpd_hiera::params::service_name,
  $service_ensure       = running,
  $service_enable       = true,

  $config_file          = $itv_snmpd_hiera::params::config_file,
  $config_file_owner    = $itv_snmpd_hiera::params::config_file_owner,
  $config_file_group    = $itv_snmpd_hiera::params::config_file_group,
  $config_file_mode     = $itv_snmpd_hiera::params::config_file_mode,
  $config_file_replace  = true,
  $config_file_content  = undef,
  $config_file_source   = undef,
  $config_file_template = $itv_snmpd_hiera::params::config_file_template,

  $config_dir_path      = $itv_snmpd_hiera::params::config_dir_path,
  $config_dir_source    = undef,
  $config_dir_purge     = false,
  $config_dir_recurse   = false,

  $conf_hash            = undef

  ) inherits itv_snmpd_hiera::params {

  # Parameter validation
  validate_re($ensure, ['present','absent'], 'Valid values are: present, absent. WARNING: If set to absent all the resources managed by the module are removed.')
  validate_bool($config_file_replace)
  validate_bool($service_enable)
  validate_bool($config_dir_purge)
  validate_bool($config_dir_recurse)
  if $conf_hash { validate_hash($conf_hash) }

  if $itv_snmpd_hiera::config_file_content {
    $managed_file_content = $itv_snmpd_hiera::config_file_content
  } else {
    if $itv_snmpd_hiera::config_file_template {
      $managed_file_content = $itv_snmpd_hiera::config_file_template
    } else {
      $managed_file_content = undef
    }
  }
  # Determine behaviour of module based on the values used

  if $itv_snmpd_hiera::version {
    $managed_package_ensure = $itv_snmpd_hiera::version
  } else {
    $managed_packaged_ensure = $itv_snmpd_hiera::ensure
  }

  if $itv_snmpd_hiera::ensure == 'absent' {
    $managed_service_enable = undef
    $managed_service_ensure = stopped
    $dir_ensure = absent
    $file_ensure = absent
  } else {
    $managed_service_enable = $itv_snmpd_hiera::service_enable
    $managed_service_ensure = $itv_snmpd_hiera::service_ensure
    $dir_ensure = directory
    $file_ensure = present
  }

  # Managed Resources

  if $itv_snmpd_hiera::package_name {
    package { $itv_snmpd_hiera::package_name:
      ensure => $itv_snmpd_hiera::managed_package_ensure,
    }
  }

  if $itv_snmpd_hiera::service_name {
    service { $itv_snmpd_hiera::service_name:
      ensure  => $itv_snmpd_hiera::managed_service_ensure,
      enable  => $itv_snmpd_hiera::managed_service_enable,
      require => Package[$itv_snmpd_hiera::package_name]
    }
  }

  if $itv_snmpd_hiera::config_file and $itv_snmpd_hiera::config_file_content {
    file { 'snmpd.conf':
      ensure  => $itv_snmpd_hiera::config_file_ensure,
      path    => $itv_snmpd_hiera::config_file,
      mode    => $itv_snmpd_hiera::config_file_mode,
      owner   => $itv_snmpd_hiera::config_file_owner,
      group   => $itv_snmpd_hiera::config_file_group,
      require => Package[$itv_snmpd_hiera::package_name],
      notify  => Service[$itv_snmpd_hiera::service_name],
      source  => $itv_snmpd_hiera::config_file_source,
      replace => $itv_snmpd_hiera::config_file_replace,
      audit   => $itv_snmpd_hiera::manage_audit,
    }
  } else {
    if $itv_snmpd_hiera::config_file {
      datacat { $itv_snmpd_hiera::config_file:
        path     => $itv_snmpd_hiera::config_file,
        mode     => $itv_snmpd_hiera::config_file_mode,
        owner    => $itv_snmpd_hiera::config_file_owner,
        group    => $itv_snmpd_hiera::config_file_group,
        notify   => Service[$itv_snmpd_hiera::service_name],
        require  => Package[$itv_snmpd_hiera::package_name],
        template => $itv_snmpd_hiera::managed_file_content,
        replace  => $itv_snmpd_hiera::config_file_replace,
      }

      datacat_fragment { 'snmpd.options':
	target => $itv_snmpd_hiera::config_file,
	data   => {
	  sysname     => $itv_snmpd_hiera::snmpname,
	  syslocation => $itv_snmpd_hiera::snmplocation,
	  syscontact  => $itv_snmpd_hiera::snmpcontact,
	},
      }
    }
  }

  if $itv_snmpd_hiera::config_dir_source {
    file { 'snmpd.dir':
      ensure  => $itv_snmpd_hiera::config_dir_ensure,
      path    => $itv_snmpd_hiera::config_dir,
      source  => $itv_snmpd_hiera::config_dir_source,
      recurse => $itv_snmpd_hiera::config_dir_recurse,
      purge   => $itv_snmpd_hiera::config_dir_purge,
      force   => $itv_snmpd_hiera::config_dir_purge,
      notify  => Service[$itv_snmpd_hiera::service_name],
      require => Package[$itv_snmpd_hiera::package_name],
    }
  }

  # Supplying a hash value allows v3/usm snmp users to created
  # form hiera
  if $conf_hash {
    create_resources(create_usmsnmp, $conf_hash)
  }
}
