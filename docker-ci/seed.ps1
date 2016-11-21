$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Start-Transcript -path ("C:\{0}.log" -f $MyInvocation.MyCommand.Name) -append

Stop-Service docker

Remove-Item $Env:ProgramFiles\docker\*.exe
Invoke-WebRequest https://master.dockerproject.org/windows/amd64/dockerd.exe -UseBasicParsing -OutFile $Env:ProgramFiles\docker\dockerd.exe
Invoke-WebRequest https://master.dockerproject.org/windows/amd64/docker.exe -UseBasicParsing -OutFile $Env:ProgramFiles\docker\docker.exe

Stop-Transcript
