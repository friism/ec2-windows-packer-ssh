param([String]$password)

$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Start-Transcript -path C:\specialize-script-output.log -append

Push-Location $Env:ProgramFiles\OpenSSH-Win64
.\ssh-keygen -A
.\ssh-add ssh_host_dsa_key
.\ssh-add ssh_host_rsa_key
.\ssh-add ssh_host_ecdsa_key
.\ssh-add ssh_host_ed25519_key
del *_key
Pop-Location

New-Item -ErrorAction Ignore -Type Directory C:\Users\Administrator\.ssh
Invoke-WebRequest http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key -UseBasicParsing -OutFile C:\Users\Administrator\.ssh\authorized_keys

$command = "powershell.exe -c Start-Process -FilePath cmd.exe /c -Credential (New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList 'Administrator', (ConvertTo-SecureString -String '{0}' -AsPlainText -Force))" -f $password
schtasks /create /ru SYSTEM /sc onstart /tn InitAdministrator /tr $command

Stop-Transcript
