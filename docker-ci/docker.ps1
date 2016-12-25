$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Start-Transcript -path ("C:\{0}.log" -f $MyInvocation.MyCommand.Name) -append

dockerd --unregister-service
Stop-Service -Force -ErrorAction Ignore docker

Remove-Item -Force -Recurse $Env:ProgramFiles\docker
Invoke-WebRequest https://test.docker.com/builds/Windows/x86_64/docker-1.13.0-rc4.zip -UseBasicParsing -OutFile docker.zip
Expand-Archive docker.zip -DestinationPath $Env:ProgramFiles
Remove-Item -Force docker.zip

dockerd -H npipe:////./pipe/docker_engine -H 0.0.0.0:2375 --register-service

Start-Service docker

docker pull microsoft/nanoserver
docker pull microsoft/windowsservercore

Stop-Transcript
