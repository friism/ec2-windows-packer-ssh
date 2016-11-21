$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Invoke-Webrequest "https://github.com/git-for-windows/git/releases/download/v2.10.2.windows.1/Git-2.10.2-64-bit.exe" -OutFile git.exe -UseBasicParsing
Start-Process git.exe -ArgumentList '/VERYSILENT /SUPPRESSMSGBOXES /CLOSEAPPLICATIONS /DIR=C:\git' -Wait
Remove-Item -Force git.exe

# $Env:PATH = 'C:\git\cmd;' + $Env:PATH
# [Environment]::SetEnvironmentVariable("PATH", $Env:PATH, [EnvironmentVariableTarget]::Machine)
