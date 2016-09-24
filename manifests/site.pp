Package { allow_virtual => false }

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

  case $::osfamily {
    /(?i:^redhat$)/:  { include "${::customer_name}_role::${::application_name}::${::application_role}" }
    default: {
      fail("OSfamily ${::osfamily} is not supported!")
    }
  }
}
