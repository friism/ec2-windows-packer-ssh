$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Start-Transcript -path ("C:\{0}.log" -f $MyInvocation.MyCommand.Name) -append

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
	"XblGameSave",
	"wuauserv"
)
foreach ($service in $services) {
	Get-Service -Name $service | Set-Service -StartupType Disabled
}

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v AUOptions /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f

schtasks /End /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /DISABLE

$ErrorActionPreference = 'SilentlyContinue'
Uninstall-WindowsFeature Windows-Defender, Windows-Defender-Features, FS-SMB1, WoW64-Support, PowerShell-ISE, NET-WCF-Services45
$ErrorActionPreference = 'Stop'

Stop-Service -Force sshd, ssh-agent
Restart-Computer -Force

Stop-Transcript