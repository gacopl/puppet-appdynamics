# == Class: appdynamics::agent::database::service
#
class appdynamics::agent::database::service() {
  if $appdynamics::agent::database::agent_present {
    service { $appdynamics::agent::database::service_name:
      ensure    => running,
      hasstatus => true,
      enable    => true,
      subscribe => File["${appdynamics::agent::database::agent_home}/conf/controller-info.xml"],
    }
  }
}
