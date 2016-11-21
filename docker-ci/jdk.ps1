$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$cookie = New-Object System.Net.Cookie("oraclelicense", "accept-securebackup-cookie", "/", ".oracle.com")
$session.Cookies.Add($cookie)
Invoke-Webrequest "http://download.oracle.com/otn-pub/java/jdk/8u111-b14/jdk-8u111-windows-x64.exe" -OutFile jdkinstaller.exe -UseBasicParsing -WebSession $session

Start-Process -Wait jdkinstaller.exe -ArgumentList "/s /INSTALLDIRPUBJRE=C:\jdk"
Remove-Item -Force jdkinstaller.exe

# $Env:PATH = 'C:\jdk\bin;' + $Env:Path
# [Environment]::SetEnvironmentVariable("Path", $Env:PATH, [EnvironmentVariableTarget]::Machine)
