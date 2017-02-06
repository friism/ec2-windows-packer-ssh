$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Start-Transcript -path ("C:\{0}.log" -f $MyInvocation.MyCommand.Name) -append

Stop-Service -Force docker
dockerd --unregister-service

Remove-Item -Force -Recurse $Env:ProgramFiles\docker
Invoke-WebRequest https://test.docker.com/builds/Windows/x86_64/docker-1.13.1-rc1.zip -UseBasicParsing -OutFile docker.zip
Expand-Archive docker.zip -DestinationPath $Env:ProgramFiles
Remove-Item -Force docker.zip
Remove-Item -Force -Recurse $Env:ProgramFiles\docker\completion

Invoke-WebRequest https://github.com/docker/compose/releases/download/1.10.1/docker-compose-Windows-x86_64.exe -UseBasicParsing -OutFile $Env:ProgramFiles\docker\docker-compose.exe

# REMARK: http://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/windows-ami-version-history.html#win2k16-amis
dockerd -H npipe:////./pipe/docker_engine -H 0.0.0.0:2375 --experimental --register-service

Start-Service docker

docker pull microsoft/nanoserver
docker pull microsoft/windowsservercore

Stop-Service -ErrorAction Ignore docker

Stop-Transcript
