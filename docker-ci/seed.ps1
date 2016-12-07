$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Start-Transcript -path ("C:\{0}.log" -f $MyInvocation.MyCommand.Name) -append

Stop-Service docker

Remove-Item -Force -Recurse $Env:ProgramFiles\docker
Invoke-WebRequest https://test.docker.com/builds/Windows/x86_64/docker-1.13.0-rc3.zip -UseBasicParsing -OutFile docker.zip
Expand-Archive docker.zip -DestinationPath $Env:ProgramFiles
Remove-Item -Force docker.zip

Stop-Transcript
