# == Class: appdynamics::agent::database::config::machine
#
class appdynamics::agent::database::config
(
  String $agent_name = $appdynamics::agent::database::agent_name,
  String $agent_home = $appdynamics::agent::database::agent_home,
  String $controller_host = $appdynamics::agent::database::controller_host,
  Integer $controller_port = $appdynamics::agent::database::controller_port,
  Boolean $controller_ssl_enabled = $appdynamics::agent::database::controller_ssl_enabled,
  String $account_name = $appdynamics::agent::database::account_name,
  String $account_access_key = $appdynamics::agent::database::account_access_key,
) {

  file { "${agent_home}/conf/controller-info.xml":
    content => template("appdynamics/agent/${agent_name}/controller-info_xml.erb"),
    require => Class['appdynamics::agent::database::install'],
  }

}
