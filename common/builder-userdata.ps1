<powershell>
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Write-Host "Disabling anti-virus monitoring"
Set-MpPreference -DisableRealtimeMonitoring $true

Write-Host "Downloading OpenSSH"
Invoke-WebRequest "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v0.0.3.0/OpenSSH-Win64.zip" -OutFile OpenSSH-Win64.zip -UseBasicParsing

Write-Host "Expanding OpenSSH"
Expand-Archive OpenSSH-Win64.zip $Env:ProgramFiles
Remove-Item -Force OpenSSH-Win64.zip

Write-Host "Disabling password authentication"
Add-Content $Env:ProgramFiles\OpenSSH-Win64\sshd_config "`nPasswordAuthentication no"

Push-Location $Env:ProgramFiles\OpenSSH-Win64

Write-Host "Installing OpenSSH"
& .\install-sshd.ps1

Write-Host "Installing OpenSSH key auth"
& .\install-sshlsa.ps1

Write-Host "Generating host keys"
Push-Location $Env:ProgramFiles\OpenSSH-Win64
.\ssh-keygen.exe -A

Pop-Location

Write-Host "Adding public key from instance metadata to authorized_keys"
New-Item -Type Directory ~\.ssh
Invoke-WebRequest http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key -UseBasicParsing -OutFile ~\.ssh\authorized_keys

Write-Host "Opening firewall port 22"
New-NetFirewallRule -Protocol TCP -LocalPort 22 -Direction Inbound -Action Allow -DisplayName SSH

Write-Host "Setting sshd service startup type to 'Automatic'"
Set-Service sshd -StartupType Automatic
Write-Host "Setting sshd service restart behavior"
sc.exe failure sshd reset= 86400 actions= restart/500
Start-Service sshd
</powershell>