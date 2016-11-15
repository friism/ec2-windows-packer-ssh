<powershell>
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Write-Output "Disabling anti-virus monitoring"
Set-MpPreference -DisableRealtimeMonitoring $true

Write-Output "Downloading OpenSSH"
Invoke-WebRequest "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v0.0.3.0/OpenSSH-Win64.zip" -OutFile OpenSSH-Win64.zip -UseBasicParsing

Write-Output "Expanding OpenSSH"
Expand-Archive OpenSSH-Win64.zip $Env:ProgramFiles
Remove-Item -Force OpenSSH-Win64.zip

Write-Output "TODO!! Disabling password authentication"

Push-Location $Env:ProgramFiles\OpenSSH-Win64

Write-Output "Installing OpenSSH"
& .\install-sshd.ps1

Write-Output "Installing OpenSSH key auth"
& .\install-sshlsa.ps1

Write-Output "Generating host keys"
Push-Location $Env:ProgramFiles\OpenSSH-Win64
.\ssh-keygen.exe -A

Pop-Location

Write-Output "Adding public key from instance metadata to authorized_keys"
New-Item -Type Directory ~\.ssh
Invoke-WebRequest http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key -UseBasicParsing -OutFile ~\.ssh\authorized_keys

Write-Output "Opening firewall port 22"
New-NetFirewallRule -Protocol TCP -LocalPort 22 -Direction Inbound -Action Allow -DisplayName SSH

Write-Output "Setting sshd service startup type to 'Automatic'"
Set-Service sshd -StartupType Automatic

Write-Output "Restarting..."
Restart-Computer
</powershell>