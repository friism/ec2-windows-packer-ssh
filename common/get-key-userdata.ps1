<powershell>
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

$keyPath = "C:\Users\Administrator\.ssh\authorized_keys"
$keyUrl = "http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key"

New-Item -ErrorAction Ignore -Type Directory C:\Users\Administrator\.ssh
Remove-Item -ErrorAction Ignore $keyPath
Remove-Item -ErrorAction Ignore ~\.ssh\authorized_keys

$ErrorActionPreference = 'SilentlyContinue'
Do { Start-Sleep 1 ; Invoke-WebRequest $keyUrl -UseBasicParsing -OutFile $keyPath } While ( -Not (Test-Path $keyPath) )
$ErrorActionPreference = 'Stop'

Copy-Item -ErrorAction Ignore $keyPath ~\.ssh\authorized_keys

Restart-Service ssh-agent
Restart-Service sshd
</powershell>