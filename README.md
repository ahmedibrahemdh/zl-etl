Zanmi Lasante(ZL) - ETL Jobs to support reporting and analytics from OpenMRS at APZU
============================================================================

This repository hold the ETL files for ZL.

# Installation

For implementers, see [Puppet](https://github.com/PIH/mirebalais-puppet/tree/master/mirebalais-modules/petl)

### Install Java
The recommended Java version is **OpenJDK 8 JDK**

### Source MySQL databases
You must have access to source MySQL databases for Upper and Lower Neno.
The recommendation is that these databases are replicas of production DBs, not the actual production instances, as a 
precaution to ensure no production data is inadvertently affected by the ETL process.

### Target MySQL databases
* You must have access to a target MySQL instance

Example:

```bash
mysql> create database neno_reporting default charset utf8;
Query OK, 1 row affected (0.00 sec)

mysql> create database lisungwi_reporting default charset utf8;
Query OK, 1 row affected (0.00 sec)
```

### Target SQL Server databases
* You must have access to a SQL Server target instance into which to ETL from MySQL
* You can use the Docker instance [described here](https://github.com/PIH/petl/tree/master/docs/examples/sqlserver-docker).

### Install PETL application and jobs

1. Create a directory to serve as your execution environment directory
2. Install the jobs and datasources into this directory
   1. For developers, create a symbolic link to the datasources and jobs folders of this project
   2. For implementers, download the zip artifact from maven and extract it into this directory
3. Install an application.yml file into this directory
   1. For developers, copy or create a symolic link to example-application.yml, and modify settings to match your database configuration
   2. For implementers, install the application.yml file, and ensure all of the database settings are setup correctly
   3. For more details on configuration options for application.yml, see the [PETL](https://github.com/PIH/petl) project
4. Install the PETL executable jar file
   1. For developers, you can clone and build the PETL application locally and create a symbolic link to target/petl-*.jar
   2. For developers or implementers, you can download the latest PETL jar from Bamboo

The directory structure should look like this:

```bash
configurations/datasources#
.
├── openmrs-cange.yml
├── openmrs-hinche.yml
├── openmrs-hiv.yml
├── openmrs-humci.yml
├── openmrs-lacolline.yml
├── openmrs-mirebalais.yml
├── openmrs-saint_marc_hsn.yml
├── openmrs-thomonde.yml
├── warehouse-hiv.yml
└── warehouse.yml

configurations/jobs#
- create-partitions.yml  
- create-source-views-and-functions.yml  
- import-to-table-partition.yml  
- refresh-base-tables.yml  
- refresh-hiv-data.yml  
- refresh-humci-data.yml  
- refresh-openmrs-data.yml  
- sql folder
```

# Execution

To execute the ETL pipeline

```shell
service petl start
```