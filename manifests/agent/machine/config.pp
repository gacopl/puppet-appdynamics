# == Class: appdynamics::agent::machine::config::machine
#
class appdynamics::agent::machine::config
(
  String $agent_name = $appdynamics::agent::machine::agent_name,
  String $agent_home = $appdynamics::agent::machine::agent_home,
  String $controller_host = $appdynamics::agent::machine::controller_host,
  Integer $controller_port = $appdynamics::agent::machine::controller_port,
  Boolean $controller_ssl_enabled = $appdynamics::agent::machine::controller_ssl_enabled,
  String $account_name = $appdynamics::agent::machine::account_name,
  String $account_access_key = $appdynamics::agent::machine::account_access_key,
  Optional[Boolean] $sim_enabled = $appdynamics::agent::machine::sim_enabled,
  Optional[String] $app = $appdynamics::agent::machine::app,
  Optional[String] $tier = $appdynamics::agent::machine::tier,
  Optional[String] $node_name = $appdynamics::agent::machine::node_name,
  Optional[Boolean] $enable_orchestration = $appdynamics::agent::machine::enable_orchestration,
  Optional[Boolean] $force_agent_registration = $appdynamics::agent::machine::force_agent_registration,
  Optional[String] $unique_host_id = $appdynamics::agent::machine::unique_host_id,
) {

  file { "${agent_home}/conf/controller-info.xml":
    content => template("appdynamics/agent/${agent_name}/controller-info_xml.erb"),
    require => Class['appdynamics::agent::machine::install'],
  }

}
