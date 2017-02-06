$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Start-Transcript -path ("C:\{0}.log" -f $MyInvocation.MyCommand.Name) -append

New-NetFirewallRule -Protocol TCP -LocalPort 2377 -Direction Inbound -Action Allow -DisplayName Docker
New-NetFirewallRule -Protocol TCP -LocalPort 7946 -Direction Inbound -Action Allow -DisplayName Docker
New-NetFirewallRule -Protocol UDP -LocalPort 7946 -Direction Inbound -Action Allow -DisplayName Docker
New-NetFirewallRule -Protocol TCP -LocalPort 4789 -Direction Inbound -Action Allow -DisplayName Docker
New-NetFirewallRule -Protocol UDP -LocalPort 4789 -Direction Inbound -Action Allow -DisplayName Docker

bcdedit -set testsigning on
# REMARK: This causes the computer to restart
Start-Process -FilePath 'C:\Windows10.0-KB123456-x64-InstallForTestingPurposesOnly.exe' -ArgumentList '/q' -Wait

Stop-Transcript
