$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Invoke-Webrequest "https://github.com/git-for-windows/git/releases/download/v2.7.2.windows.1/Git-2.7.2-64-bit.exe" -OutFile git.exe -UseBasicParsing
Start-Process git.exe -ArgumentList '/VERYSILENT /SUPPRESSMSGBOXES /CLOSEAPPLICATIONS /DIR=c:\git\' -Wait
Remove-Item -Force git.exe
[Environment]::SetEnvironmentVariable("PATH", $Env:PATH + ';C:\git\cmd', [EnvironmentVariableTarget]::Machine)
