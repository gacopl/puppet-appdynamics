# == Class appdynamics::agent::database
#
class appdynamics::agent::database (
  Boolean $agent_present,
  String $agent_name = 'database',
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
  Optional[String] $service_name = "Appdynamics ${appdynamics::agent::database::agent_name.capitalize()} Agent",
)
{
  contain appdynamics::agent::database::install

  if $agent_present {
    contain appdynamics::agent::database::config
    contain appdynamics::agent::database::service

    Class['appdynamics::agent::database::install']
    -> Class['appdynamics::agent::database::config']
    -> Class['appdynamics::agent::database::service']
  }
}
