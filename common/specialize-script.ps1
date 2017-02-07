$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Start-Transcript -path ("C:\{0}.log" -f $MyInvocation.MyCommand.Name) -append

Push-Location C:\OpenSSH-Win64
.\ssh-keygen -A
.\ssh-add ssh_host_dsa_key
.\ssh-add ssh_host_rsa_key
.\ssh-add ssh_host_ecdsa_key
.\ssh-add ssh_host_ed25519_key
del *_key
Pop-Location

$keyPath = "C:\Users\Administrator\.ssh\authorized_keys"
$keyUrl = "http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key"

New-Item -ErrorAction Ignore -Type Directory C:\Users\Administrator\.ssh > $null

$ErrorActionPreference = 'SilentlyContinue'
Do {
	Start-Sleep 1
	Write-Output ("{0:u}: Trying to fetch key from metadata service" -f (Get-Date))
	Invoke-WebRequest $keyUrl -UseBasicParsing -OutFile $keyPath
	Write-Output $Error[0]
} While ( -Not (Test-Path $keyPath) )
$ErrorActionPreference = 'Stop'
Write-Output ("{0:u}: Key successfully retrieved" -f (Get-Date))

Stop-Transcript
