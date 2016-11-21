<powershell>
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

$keyPath = "~\.ssh\authorized_keys"
$keyUrl = "http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key"

New-Item -ErrorAction Ignore -Type Directory ~\.ssh
Remove-Item -ErrorAction Ignore $keyPath

$ErrorActionPreference = 'SilentlyContinue'
Do { Start-Sleep 1 ; Invoke-WebRequest $keyUrl -UseBasicParsing -OutFile $keyPath } While ( -Not (Test-Path $keyPath) )
$ErrorActionPreference = 'Stop'

Restart-Service sshd
</powershell>