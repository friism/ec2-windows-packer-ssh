$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Set-MpPreference -DisableRealtimeMonitoring $true

$services = @(
	"diagnosticshub.standardcollector.service"
	"DiagTrack"
	"dmwappushservice"
	"lfsvc"
	"MapsBroker"
	"NetTcpPortSharing"
	"RemoteAccess"
	"RemoteRegistry"
	"SharedAccess"
	"TrkWks"
	"WbioSrvc"
	"XblAuthManager"
	"XblGameSave"
)
foreach ($service in $services) {
	Get-Service -Name $service | Set-Service -StartupType Disabled
}

Disable-PSRemoting
Get-Service -Name "WinRM" | Set-Service -StartupType Disabled

Invoke-Webrequest "https://github.com/git-for-windows/git/releases/download/v2.7.2.windows.1/Git-2.7.2-64-bit.exe" -OutFile git.exe -UseBasicParsing
Start-Process git.exe -ArgumentList '/VERYSILENT /SUPPRESSMSGBOXES /CLOSEAPPLICATIONS /DIR=c:\git\' -Wait
Remove-Item -Force git.exe
setx /M PATH "$Env:Path;c:\git\cmd"

Add-Type -AssemblyName System.Web
$lc = Get-Content C:\ProgramData\Amazon\EC2-Windows\Launch\Config\LaunchConfig.json -raw | ConvertFrom-Json
$lc.AdminPasswordType = "Specify"
$lc.AdminPassword = [System.Web.Security.Membership]::GeneratePassword(15,6)
$lc | ConvertTo-Json | set-content C:\ProgramData\Amazon\EC2-Windows\Launch\Config\LaunchConfig.json

Add-Content $Env:ProgramData\Amazon\EC2-Windows\Launch\Sysprep\BeforeSysprep.cmd '`r`n'
Add-Content $Env:ProgramData\Amazon\EC2-Windows\Launch\Sysprep\BeforeSysprep.cmd 'del "C:\Program Files\OpenSSH-Win64\*_key*"'
Add-Content $Env:ProgramData\Amazon\EC2-Windows\Launch\Sysprep\BeforeSysprep.cmd 'del C:\Users\Administrator\.ssh\authorized_keys'
Add-Content $Env:ProgramData\Amazon\EC2-Windows\Launch\Sysprep\BeforeSysprep.cmd 'del C:\provision.ps1'

Add-Content $Env:ProgramData\Amazon\EC2-Windows\Launch\Sysprep\BeforeSysprep.cmd '`r`n'
$logincmd = 'powershell -c ''Start-Process -FilePath cmd.exe /c -Credential (New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList "Administrator", (ConvertTo-SecureString -String "{0}" -AsPlainText -Force)''' -f $lc.AdminPassword
Add-Content $Env:ProgramData\Amazon\EC2-Windows\Launch\Sysprep\SysprepSpecialize.cmd $logincmd
Add-Content $Env:ProgramData\Amazon\EC2-Windows\Launch\Sysprep\SysprepSpecialize.cmd 'pushd "C:\Program Files\OpenSSH-Win64" & .\ssh-keygen.exe -A & popd'
Add-Content $Env:ProgramData\Amazon\EC2-Windows\Launch\Sysprep\SysprepSpecialize.cmd 'powershell -c "New-Item -ErrorAction Ignore -Type Directory ~\.ssh ; Invoke-WebRequest http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key -UseBasicParsing -OutFile ~\.ssh\authorized_keys"'

& $Env:ProgramData\Amazon\EC2-Windows\Launch\Scripts\InitializeInstance.ps1 -Schedule
& $Env:ProgramData\Amazon\EC2-Windows\Launch\Scripts\SysprepInstance.ps1
