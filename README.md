# puppet-appdynamics

## Overview

Module to manage AppDynamics agents Install, Update, Change Config, Remove

Currently supported agents: Machine, Database

## Module Description

This module installs and configures AppDynamics agents and allows their management
from hiera. 

Currently only Windows is supported but adding Linux should be a lot simpler

It will download appd zip bundles from S3 bucket install and configure agents

It provides ability to change all the parameters that are defined in controller-info.xml settings file.

* When provided with different version of zip bundle it will automatically stop service unpack, install and start again new version as system service
* When configuration change will be made it will automatically restart agent to pick up changes
* Setting `agent_present: false` allows you to perform clean uninstall of agent
* Configuration is passed through Hiera
* Ability to install as standalone global modules or included in profiles and manage settings per profile


## Parameters

### Paremeters list

```yaml
# Machine Agent
appdynamics::agent::machine::s3_bucket_name: null
appdynamics::agent::machine::s3_bucket_folder: null
appdynamics::agent::machine::controller_host: null
appdynamics::agent::machine::controller_port: 80
appdynamics::agent::machine::controller_ssl_enabled: false
appdynamics::agent::machine::account_name: null
appdynamics::agent::machine::account_access_key: null
appdynamics::agent::machine::agent_present: true
appdynamics::agent::machine::agent_base: "/opt/AppDynamics"
appdynamics::agent::machine::agent_installer: machineagent-bundle-64bit.zip

appdynamics::agent::machine::sim_enabled: true
appdynamics::agent::machine::app: ''
appdynamics::agent::machine::tier: ''
appdynamics::agent::machine::node_name: ''
appdynamics::agent::machine::force_agent_registration: false
appdynamics::agent::machine::enable_orchestration: false

#Database Agent
appdynamics::agent::database::s3_bucket_name: null
appdynamics::agent::database::s3_bucket_folder: null
appdynamics::agent::database::controller_host: null
appdynamics::agent::database::controller_port: 80
appdynamics::agent::database::controller_ssl_enabled: false
appdynamics::agent::database::account_name: null
appdynamics::agent::database::account_access_key: null
appdynamics::agent::database::agent_present: true
appdynamics::agent::database::agent_base: "/opt/AppDynamics"
appdynamics::agent::database::agent_installer: db-agent-64bit.zip
```

### Set up common parameters

Put common parameters like S3,Controller settings and account into common hiera yaml

Put windows specific parameters like `agent_base` and `agent_installer` in windows specific hiera yaml (if you have such one, if not put in common as well)

All agents will be installed in the `agent_base` directory following `agent_base\agent_name` scheme

Wether to install or uninstall agent is decided by `agent_present` flag setting for each agent individually

### Machine agent parameters

By Default Server Visibility (SIM) feature is enabled for Extended Machine metrics provided in Servers Dashboard. 
If you don't have licences for it you can disable it with `sim_enabled: false` flag, but then you will need to pin agent to specific app running any APM on the same node as well, this way Machine Agent will run under APM license but will provide basic Machine metrics only on Applications dashboard under the App to which it was pinned

Machine Agent specific settings for pinning are `app`, `tier` and `node_name` - you need to provide them to pin Machine Agent to specific app

Machine Agent can run both with sim enabled and pinning configured, providing Basic metrics on the App dashboard and Extended metrics on Servers dashboard

Machine agent parameters should be specified on node level if you want to pin

For only Server Visibility (SIM) mode you don't need to specify anything on node level as by default it is turned on and will figure out agent name from hostname and present itself under Servers Dashboard with hostname name.

More info on Machine agents and how to set them up with/without APMs etc is in official Appdynamics docs

### Database agent parameters

Database agent doesnt have any specific params except for the `agent_present` flag, as normally one database agent should serve all your database collectors, and any additional database agents will serve as a backup to the primary one.

## Global standalone module installation

Once you've placed parameters settings in hiera make the following class declaration to install agent(s) using those settings:

```puppet
  class { 'appdynamics::agent::machine': }
  class { 'appdynamics::agent::database': }
```

You can overload settings in the manifest directly if you want, but its advised to keep everything in hiera:
```puppet
  class { 'appdynamics::agent::machine':
    machine_app                => 'Web',
    machine_tier               => 'Frontend',
    machine_controller_host    => 'ad.controller.example.com',
    machine_controller_port    => 8080,
    machine_account_name       => 'abc',
    machine_account_access_key => 'abc123abc123',
  }
```
## Profile based installation

### Sample Profile declaration

Create below profiles ofc you can overload more settings if you want

```puppet
  class profiles::appd_agent_database (
    Boolean $agent_present = true,
  ) {
    class { 'appdynamics::agent::database':
      agent_present   => $agent_present,
    }
    contain appdynamics::agent::database
  }
```
```puppet
  class profiles::appd_agent_machine (
    Boolean $agent_present = true,
    Optional[String] $sim_enabled = $appdynamics::agent::machine::sim_enabled,
    Optional[String] $tier = $appdynamics::agent::machine::tier,
    Optional[String] $app = $appdynamics::agent::machine::app,
    Optional[String] $node_name = $appdynamics::agent::machine::node_name,
    Optional[String] $unique_host_id = $appdynamics::agent::machine::unique_host_id,
  ) {
    class { 'appdynamics::agent::machine':
      agent_present   => $agent_present,
      sim_enabled     => $sim_enabled,
      app             => $app,
      tier            => $tier,
      node_name       => $node_name,
      unique_host_id  => $unique_host_id,
    }
    contain appdynamics::agent::machine
  }
```

Attach those profiles to role, it will install agents with settings you've specified

Then provide profile specific settings in profile hiera yaml if you need to override global or profile defaults

### Sample Profile Specific Config

Pinned Machine Agent without SIM

```yaml
profiles::appd_agent_machine::sim_enabled: false
profiles::appd_agent_machine::app: Web
profiles::appd_agent_machine::tier: frontend
profiles::appd_agent_machine::node: node-a
```

Machine Agent SIM and Database Agent running on same machine

```yaml
profiles::appd_agent_machine::unique_host_id: "%{hostname}-ma"
```

Uninstall/prevent from installation of Machine Agent (put it in role settings yaml to which profile is attached)

```yaml
profiles::appd_agent_machine::agent_present: false
```