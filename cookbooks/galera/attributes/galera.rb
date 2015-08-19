default[:galera_config] = {
  "id" => "config",
  "mysql_wsrep_tarball_x86_64" => "mysql-5.5.29_wsrep_23.7.3-linux-x86_64.tar.gz",
  "mysql_wsrep_tarball_i686" => "mysql-5.5.29_wsrep_23.7.3-linux-i686.tar.gz",
  "galera_package_i386" => {
    "deb" => "galera-23.2.4-i386.deb",
    "rpm" => "galera-23.2.4-1.rhel5.i386.rpm"},
  "galera_package_x86_64" => {
    "deb" => "galera-23.2.4-amd64.deb",
    "rpm" => "galera-23.2.4-1.rhel5.x86_64.rpm"
  },
  "mysql_wsrep_source" => "https://launchpad.net/codership-mysql/5.5/5.5.29-23.7.3/+download",
  "galera_source" => "https://launchpad.net/galera/2.x/23.2.4/+download",
  "sst_method" => "rsync",
  "init_node" => "10.0.3.140",
  "galera_nodes" => ["10.0.3.140", "10.0.3.150", "10.0.3.160"],
  "secure" => "yes",
  "update_wsrep_urls" => "yes",
  "purge_mysql" => "no",
  "vagrant_host" => true,
  "hostnames" => false,
}
