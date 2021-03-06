clustercontrol Cookbook
=======================
Installs ClusterControl on your existing database cluster. ClusterControl is an agentless management and automation software for database clusters. It helps deploy, monitor, manager and scale your database cluster. This cookbook will install ClusterControl and configure it to manage and monitor an **existing** database cluster.

Supported database clusters:

- Galera Cluster for MySQL
- Percona XtraDB Cluster
- MariaDB Galera Cluster
- MySQL Replication
- MySQL Cluster
- MongoDB Replica Set
- MongoDB Sharded Cluster
- TokuMX Cluster

More details at [Severalnines](http://www.severalnines.com/clustercontrol) website.

This cookbook is a replacement for deprecated [cmon](https://supermarket.chef.io/cookbooks/cmon) cookbook that we have built earlier. It manages and configures ClusterControl and all of its components:

- Install ClusterControl controller, cmonapi and UI via Severalnines package repository.
- Install and configure MySQL, create CMON DB, grant cmon user and configure DB for ClusterControl UI.
- Install and configure Apache, check permission and install SSL.
- Copy the generated SSH key to all nodes.

If you have any questions, you are welcome to get in touch via our [contact us](http://www.severalnines.com/contact-us) page or email us at [info@severalnines.com](mailto:info@severalnines.com).


Requirements
------------

### Platform

- CentOS, Redhat, Fedora
- Debian, Ubuntu
- x86_64 architecture only

Tested on Chef Server 11.1/12.0 on following platforms:

- CentOS 6.5 64bit
- Ubuntu 12.04 64bit
- Ubuntu 14.04 64bit
- Debian 7 64bit

Make sure you meet following criteria prior to the deployment:

- ClusterControl node must run on a clean dedicated host with internet connection.
- ClusterControl node must run on the same operating system distribution with your database hosts (mixing Debian with Ubuntu or CentOS with Red Hat is possible)
- Make sure your database cluster is up and running.
- If you are running as sudo user, make sure the user is able to escalate to root with sudo command.
- SELinux/AppArmor must be turned off. Services or ports to be enabled are listed [here](http://www.severalnines.com/docs/clustercontrol-administration-guide/administration/securing-clustercontrol).


Attributes
----------

Please refer to `attributes/default.rb`

Data Bags
---------

Data items are used by the ClusterControl controller recipe to configure SSH public key on database hosts, grants cmon database user and setting up CMON configuration file. We provide a helper script located under `clustercontrol/files/default/s9s_helper.sh`. Please run this script prior to the deployment.

### Helper script - s9s_helper.sh
```bash
$ cd ~/chef-repo/cookbooks/clustercontrol/files/default
$ ./s9s_helper.sh
```

Answer all the questions and at the end of the wizard, it will generate a data bag file called `config.json` and a set of command that you can use to create and upload the data bag. If you run the script for the first time, it will ask to re-upload the cookbook since it contains a newly generated SSH key:
```bash
$ knife cookbook upload clustercontrol
```

### Example data bag - clustercontrol/files/default/config.json
```json
{
  "id"                      : "config",
  "cluster_type"            : "galera",
  "email_address"           : "admin@localhost.xyz",
  "ssh_user"                : "ubuntu",
  "cmon_password"           : "cmonP4ss",
  "mysql_root_password"     : "myR00tP4ssword",
  "mysql_server_addresses"  : "192.168.1.11,192.168.1.12,192.168.1.13",
  "clustercontrol_host"     : "192.168.1.10",
  "clustercontrol_api_token": "b7e515255db703c659677a66c4a17952515dbaf5"
}
```

*We highly recommend you to use encrypted data bag since it contains confidential information*

### ClusterControl general options

Following options are used for the general ClusterControl set up:

`id`
The data item identifier. Do not change this value.

`cluster_type`
The database cluster type. MySQL replication falls under mysql_single. Supported values: galera, mysqlcluster, replication, mysql_single, mongodb
- Default: 'galera'

`email_address`
Specify an email as root user for ClusterControl UI. You will login using this email with default password 'admin'.
- Default: 'admin@localhost.xyz'

`ssh_user`
Specify the SSH user that ClusterControl will use to manage the database nodes. Unless root, make sure this user is in sudoers list. 
- Default: 'root'

`ssh_port`
Specify the SSH port used by ClusterControl to SSH into database hosts. All nodes in the cluster must use the same SSH port.
- Default: 22

`cmon_password`
Specify the MySQL password for user cmon. The recipe will grant this user with specified password, and is needed by ClusterControl.
-Default: 'cmon'

`clustercontrol_host`
The ClusterControl host IP address
- Example: '11.22.33.44'

`clustercontrol_api_token`
40-character ClusterControl token generated from s9s_helper script. 
- Example: 'b7e515255db703c659677a66c4a17952515dbaf5'

`datadir`
Path to the database cluster's data directory that ClusterControl should monitor
- Default: `/var/lib/mysql`

### MySQL specific options

Following options are used for supported MySQL-based cluster type particularly MySQL standalone, Galera Cluster, MySQL Replication or MySQL Cluster.

`mysql_server_addresses`
Comma-separated list of MySQL servers' IP address that ClusterControl should monitor. For MySQL cluster, specify the MySQL API nodes list instead. 
- Example: '12.12.12.12,13.13.13.13,14.14.14.14'

`vendor`
Database cluster provider (Galera Clusters only). Supported values: percona, mariadb or codership. 
- Default: 'percona'

`mysql_root_password`
MySQL root password of your database cluster to be monitored by ClusterControl.
- Default: 'password'

`datanode_addresses`
Comma-separated list of MySQL data nodes' IP address that ClusterControl should monitor (MySQL Cluster only).
- Example: '12.12.12.12,13.13.13.13,14.14.14.14'

`mgmnode_addresses`
Comma-separated list of MySQL data nodes' IP address that ClusterControl should monitor (MySQL Cluster only).
- Example: '12.12.12.12,13.13.13.13,14.14.14.14'

### MongoDB specific options
Following options are used for supported MongoDB and TokuMX cluster type particularly Sharded Cluster or Replica Set.

`mongodb_server_addresses`
Comma-separated list of IP address/hostname with port of MongoDB/TokuMX shard/replica set nodes that ClusterControl should monitor.
- Example: '12.12.12.12:27017,13.13.13.13:27017'

`mongoarbiter_server_addresses`
Comma-separated list of IP address/hostname with port of MongoDB/TokuMX arbiter node (if any) that ClusterControl should monitor.
- Example: '12.12.12.12:30000,13.13.13.13:30000'

`mongocfg_server_addresses`
Comma-separated list of IP address/hostname with port of MongoDB/TokuMX config node (sharded cluster only) that ClusterControl should monitor.
- Example: '12.12.12.12:27019,13.13.13.13:27019'

`mongos_server_addresses`
Comma-separated list of IP address/hostname with port of MongoDB/TokuMX mongos node (sharded cluster only) that ClusterControl should monitor.
- Example: '12.12.12.12:27017,13.13.13.13:27017'


Usage
-----
#### clustercontrol::default, clustercontrol::controller

For ClusterControl host, just include `clustercontrol` or `clustercontrol::controller` in your node's `run_list`:

```json
{
  "name":"clustercontrol_node",
  "run_list": [
    "recipe[clustercontrol]"
  ]
}
```

### clustercontrol::db_hosts

For database hosts, include `clustercontrol::db_hosts` in your node's `run_list`:

```json
{
  "name":"database_nodes",
  "run_list": [
    "recipe[clustercontrol::db_hosts]"
  ]
}
```

** Do not forget to generate databag before the deployment begins! Once the cookbook is applied to all nodes, open ClusterControl web UI at `https://[ClusterControl IP address]/clustercontrol` and login using specified email address with default password 'admin'.

Limitations
-----------

This module has been tested on following platforms:

- Debian 7 (wheezy)
- Ubuntu 14.04 LTS (trusty)
- Ubuntu 12.04 LTS (precise)
- RHEL 5/6
- CentOS 5/6

This module only supports bootstrapping MySQL servers with IP address only (it expects skip-name-resolve is enabled on all MySQL nodes). However, for MongoDB you can specify hostname as described under MongoDB Specific Options.

[ClusterControl known issues and limitations](http://www.severalnines.com/docs/clustercontrol-troubleshooting-guide/known-issues-limitations).

Change History
--------------

- v0.1.3 - Add datadir into s9s_helper
- v0.1.2 - Fixed sudoer with password
- v0.1.1 - Cleaning up and updated README
- v0.1.0 - Initial recipes based on ClusterControl v1.2.8

License and Authors
-------------------
Ashraf Sharif (ashraf@severalnines.com) Derived from Opscode, Inc cookbook recipes examples.

Copyright (c) 2014 Severalnines AB.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

`http://www.apache.org/licenses/LICENSE-2.0`

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

Please report bugs or suggestions via our support channel: [https://support.severalnines.com](https://support.severalnines.com)
