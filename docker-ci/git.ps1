Param(
	[Parameter(Mandatory=$True)]
	[string]$gitVersion
)

$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Start-Transcript -path ("C:\{0}.log" -f $MyInvocation.MyCommand.Name) -append

$otherGitVersion = $gitVersion -replace "\.windows\.\d*", ""

Invoke-Webrequest "https://github.com/git-for-windows/git/releases/download/v$gitVersion/MinGit-$otherGitVersion-64-bit.zip" -OutFile git.zip -UseBasicParsing
New-Item -Type Directory C:\git > $null
Expand-Archive -Path git.zip -DestinationPath C:\git\.
Remove-Item -Force git.zip

$newPath = 'C:\git\cmd;' + [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("PATH", $newPath, [EnvironmentVariableTarget]::Machine)

C:\git\cmd\git.exe --version

Stop-Transcript
