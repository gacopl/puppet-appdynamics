# == Class: appdynamics::agent::machine::service
#
class appdynamics::agent::machine::service() {
  if $appdynamics::agent::machine::agent_present {
    service { $appdynamics::agent::machine::service_name:
      ensure    => running,
      hasstatus => true,
      enable    => true,
      subscribe => File["${appdynamics::agent::machine::agent_home}/conf/controller-info.xml"],
    }
  }
}
