$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Start-Transcript -path ("C:\{0}.log" -f $MyInvocation.MyCommand.Name) -append

$jdkVersion = "zulu8.19.0.1-jdk8.0.112-win_x64"

Invoke-Webrequest "http://cdn.azul.com/zulu/bin/$jdkVersion.zip" -OutFile jdk.zip -UseBasicParsing

New-Item -Type Directory C:\jdk-temp
Expand-Archive jdk.zip -DestinationPath C:\jdk-temp
Remove-Item -Force jdk.zip

New-Item -Type Directory C:\jdk
mv C:\jdk-temp\$jdkVersion\* C:\jdk\.
Remove-Item -Force -Recurse C:\jdk-temp

$newPath = 'C:\jdk\bin;' + [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("PATH", $newPath, [EnvironmentVariableTarget]::Machine)

C:\jdk\bin\java.exe -version

Stop-Transcript
