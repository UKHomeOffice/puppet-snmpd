# Puppet module: snmpd

This is a Puppet module for snmpd.
It manages its installation, configuration and service.

## USAGE - Basic management

* Install snmpd with default settings (package installed, service started, default configuration files)

        class { 'snmpd': }

* Remove snmpd package and purge all the managed files

        class { 'snmpd':
          ensure => absent,
        }

* Install a specific version of snmpd package

        class { 'snmpd':
          version => '1.0.1',
        }

* Install the latest version of snmpd package

        class { 'snmpd':
          version => 'latest',
        }

* Enable snmpd service. This is default.

        class { 'snmpd':
          service_ensure => 'running',
        }

* Enable snmpd service at boot. This is default.

        class { 'snmpd':
          service_status => 'enabled',
        }


* Do not automatically restart services when configuration files change (Default: Class['snmpd::config']).

        class { 'snmpd':
          service_subscribe => false,
        }

* Enable auditing (on all the arguments)  without making changes on existing snmpd configuration *files*

        class { 'snmpd':
          audit => 'all',
        }

* Module dry-run: Do not make any change on *all* the resources provided by the module

        class { 'snmpd':
          noop => true,
        }


## USAGE - Overrides and Customizations
## Some of these options have not been implemented
* Use custom source for main configuration file 

        class { 'snmpd':
          file_source => "puppet:///modules/snmpd/snmpd.conf-${hostname}" ,
                         
        }


* Use custom source directory for the whole configuration dir.

        class { 'snmpd':
          dir_source  => 'puppet:///modules/snmpd/conf/',
        }

* Use custom source directory for the whole configuration dir purging all the local files that are not on the dir.
  Note: This option can be used to be sure that the content of a directory is exactly the same you expect, but it is desctructive and may remove files.

        class { 'snmpd':
          dir_source => 'puppet:///modules/snmpd/conf/',
          dir_purge  => true, # Default: false.
        }

* Use custom source directory for the whole configuration dir and define recursing policy.

        class { 'snmpd':
          dir_source    => 'puppet:///modules/snmpd/conf/',
          dir_recursion => false, # Default: true.
        }

* Use custom template for main config file. Note that template and source arguments are alternative.

        class { 'snmpd':
          file_template => 'snmpd/snmpd.conf.erb',
        }

