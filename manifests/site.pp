Package { allow_virtual => false }
- 
# Only support the following OS
case "${::operatingsystem}${::operatingsystemrelease}" {
  /(?i:^centos)(6|7)/: { }
  /(?i:^redhat)(6|7)/: { }
  default: {
    fail("OS ${::operatingsystem}${::operatingsystemrelease} is not supported!")
  }
}


# A node have only a default role that we inlcude from the itshosted_role module
node default {

  # Puppet master setup
  if ($::hostname == 'puppetmaster' ) {
    class { 'puppetdb':
      listen_address  => 'puppetmaster.example.com',
      manage_firewall => false,
    }
    class { 'puppetdb::master::config':
      manage_report_processor => true,
      enable_reports          => true,
    }

    # Configure Apache on this server
    class { 'apache':
      purge_configs => true,
      mpm_module    => 'prefork',
      default_vhost => true,
      default_mods  => false,
    }

    class { 'apache::mod::wsgi': }

    # Configure Puppetboard
    class { 'puppetboard':
      puppetdb_host     => $::ipaddress_eth0,
      manage_git        => true,
      manage_virtualenv => false,
    }

    # Access Puppetboard through 
    class { 'puppetboard::apache::vhost':
      vhost_name => 'puppetboard.example.com',
      port       => 80,
    }
  }


  case $::osfamily {
    /(?i:^redhat$)/:  { include "${::customer_name}_role::${::application_name}::${::application_role}" }
    default: {
      fail("OSfamily ${::osfamily} is not supported!")
    }
  }
}
