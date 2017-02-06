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

# REMARK: http://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/windows-ami-version-history.html#win2k16-amis
dockerd -H npipe:////./pipe/docker_engine -H 0.0.0.0:2375 --experimental --register-service

Start-Service docker

docker pull microsoft/nanoserver
docker pull microsoft/windowsservercore

Stop-Service -ErrorAction Ignore docker

Stop-Transcript
