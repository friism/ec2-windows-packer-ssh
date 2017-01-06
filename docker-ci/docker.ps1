$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Start-Transcript -path ("C:\{0}.log" -f $MyInvocation.MyCommand.Name) -append

Stop-Service -Force docker
dockerd --unregister-service

Remove-Item -Force -Recurse $Env:ProgramFiles\docker
Invoke-WebRequest https://test.docker.com/builds/Windows/x86_64/docker-1.13.0-rc5.zip -UseBasicParsing -OutFile docker.zip
Expand-Archive docker.zip -DestinationPath $Env:ProgramFiles
Remove-Item -Force docker.zip

# REMARK: http://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/windows-ami-version-history.html#win2k16-amis
dockerd -H npipe:////./pipe/docker_engine -H 0.0.0.0:2375 --fixed-cidr "172.17.0.0/16" --register-service
sc.exe config docker start= delayed-auto

Start-Service docker

docker pull microsoft/nanoserver
docker pull microsoft/windowsservercore

Stop-Service -ErrorAction Ignore docker

Stop-Transcript
