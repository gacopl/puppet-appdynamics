# == Class::appdynamics::agent::machine::install
#
class appdynamics::agent::machine::install
(
  String $agent_name = $appdynamics::agent::machine::agent_name,
  String $agent_base = $appdynamics::agent::machine::agent_base,
  String $agent_installer = $appdynamics::agent::machine::agent_installer,
  String $s3_bucket_name = $appdynamics::agent::machine::s3_bucket_name,
  String $s3_bucket_folder = $appdynamics::agent::machine::s3_bucket_folder,
  String $agent_home = $appdynamics::agent::machine::agent_home,
  String $service_name = $appdynamics::agent::machine::service_name,
) {
  if $appdynamics::agent::machine::agent_present {
    file { "Appdynamics ${agent_home} home":
      ensure  => directory,
      path    => $agent_home,
      recurse => true,
    }
    -> exec { "Download ${agent_name} agent":
      command  => "Copy-S3Object -BucketName ${s3_bucket_name} -Key ${s3_bucket_folder}/${agent_installer} -LocalFile ${agent_base}\\${agent_installer}",
      creates  => "${agent_base}/${agent_installer}",
      provider => powershell,
    }
    ~> exec { "Unzip ${agent_name} agent":
      command     => "Get-Service \"${service_name}\" -ErrorAction SilentlyContinue | Stop-Service -ErrorAction SilentlyContinue;Expand-Archive -Path ${agent_base}\\${agent_installer} -DestinationPath ${agent_home} -Force",
      provider    => powershell,
      logoutput   => true,
      refreshonly => true,
    }
    ~> exec { "Register ${agent_name} agent as Windows service" :
      command     => "cscript.exe ${agent_home}\\InstallService.vbs",
      provider    => powershell,
      logoutput   => true,
      refreshonly => true,
    }
  }
  else {
    exec { "UnRegister ${agent_name} agent as Windows service":
      command  => "cscript.exe ${agent_home}\\UnInstallService.vbs",
      onlyif   => "\$service = Get-Service -Name \"${service_name}\";
                  if (\$service.Status -eq \"Running\") { Exit 0 } else { Exit 1 }",
      provider => powershell,
    }
    ~> tidy { $agent_home:
      recurse => true,
      rmdirs  => true,
    }
    ~> tidy { "${agent_base}/${agent_installer}": }
  }
}

