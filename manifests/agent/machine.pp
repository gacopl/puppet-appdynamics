# == Class appdynamics::agent::machine
#
class appdynamics::agent::machine (
  Boolean $agent_present,
  String $agent_name = 'machine',
  String $agent_base = $appdynamics::agent::agent_base,
  String $agent_installer = $appdynamics::agent::agent_installer,
  String $s3_bucket_name = $appdynamics::agent::s3_bucket_name,
  String $s3_bucket_folder = $appdynamics::agent::s3_bucket_folder,
  String $controller_host = $appdynamics::agent::controller_host,
  Integer $controller_port = $appdynamics::agent::controller_port,
  Boolean $controller_ssl_enabled = $appdynamics::agent::controller_ssl_enabled,
  String $account_name = $appdynamics::agent::account_name,
  String $account_access_key = $appdynamics::agent::account_access_key,
  Optional[String] $agent_home = "${agent_base}/${agent_name.capitalize()}Agent",
  Optional[String] $service_name = "Appdynamics ${appdynamics::agent::machine::agent_name.capitalize()} Agent",
  Optional[Boolean] $sim_enabled = $appdynamics::agent::machine::sim_enabled,
  Optional[String] $app = $appdynamics::agent::machine::app,
  Optional[String] $tier = $appdynamics::agent::machine::tier,
  Optional[String] $node_name = $appdynamics::agent::machine::node_name,
  Optional[Boolean] $enable_orchestration = $appdynamics::agent::machine::enable_orchestration,
  Optional[Boolean] $force_agent_registration = $appdynamics::agent::machine::force_agent_registration,
  Optional[String] $unique_host_id = $appdynamics::agent::machine::unique_host_id,
)
{
  contain appdynamics::agent::machine::install

  if $agent_present {
    contain appdynamics::agent::machine::config
    contain appdynamics::agent::machine::service

    Class['appdynamics::agent::machine::install']
    -> Class['appdynamics::agent::machine::config']
    -> Class['appdynamics::agent::machine::service']
  }
}
