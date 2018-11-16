$ErrorActionPreference = 'Stop'

function Wait-For-Agent-Installation
{
 $tries = 180
 Write-Host "Waiting $tries seconds for GoAgent service to install"
 do {
  $tries--
  try {
    Get-Service "Go Agent"
    return
    } catch {
      sleep -Milliseconds 1000
    }
  } until ($tries -eq 0)
  throw "Go Agent was not install after 180 seconds"
} 

if ($args.length -lt 5) {
  throw "Must have 5/6 args: server_url server_version autoregister_key plugin_id agent_id environment"
}

$server_url = $args[0]
$server_version = $args[1]
$autoregister_key= $args[2]
$plugin_id = $args[3]
$agent_id = $args[4]
$environment = $args[5]
$install_dir = 'C:\go-agent'
$install_cmd = ".\go-agent-$server_version-jre-64bit-setup.exe /S /SERVERURL=```"$server_url```" /START_AGENT=NO /D=$install_dir"

Write-Host "Disabling User Access Control"
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value "0"

Write-Host "Installing go-agent using command: $install_cmd"
Invoke-expression $install_cmd 

Wait-For-Agent-Installation

Write-Host "Adding autoregister.properties file"
$file_content = "agent.auto.register.key=$autoregister_key
agent.auto.register.environments=$environment
agent.auto.register.elasticAgent.pluginId=$plugin_id
agent.auto.register.elasticAgent.agentId=$agent_id"

$file_content | Out-File "$install_dir\config\autoregister.properties"

Write-Host "Starting go-agent..."
Start-service "Go Agent"