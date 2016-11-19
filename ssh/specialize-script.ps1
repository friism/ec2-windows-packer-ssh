$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Start-Transcript -path ("C:\{0}.log" -f $MyInvocation.MyCommand.Name) -append

Push-Location $Env:ProgramFiles\OpenSSH-Win64
.\ssh-keygen -A
.\ssh-add ssh_host_dsa_key
.\ssh-add ssh_host_rsa_key
.\ssh-add ssh_host_ecdsa_key
.\ssh-add ssh_host_ed25519_key
del *_key
Pop-Location

$keyPath = "C:\Users\Administrator\.ssh\authorized_keys"
$keyUrl = "http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key"

New-Item -ErrorAction Ignore -Type Directory C:\Users\Administrator\.ssh

$ErrorActionPreference = 'SilentlyContinue'
Do { Start-Sleep 1 ; Invoke-WebRequest $keyUrl -UseBasicParsing -OutFile $keyPath } While ( -Not (Test-Path $keyPath) )
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Web
$password = [System.Web.Security.Membership]::GeneratePassword(19,7)
$administrator = get-wmiobject win32_useraccount | Where { $_.Name -eq 'Administrator'} | Select -First 1
$administratorAD = [adsi] ("WinNT://{0}/{1}" -f $administrator.PSComputerName, $administrator.Name )
$administratorAD.SetPassword($password)
$administratorAD.SetInfo()

Stop-Transcript
