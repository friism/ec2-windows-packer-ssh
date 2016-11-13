$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Invoke-Webrequest "https://github.com/git-for-windows/git/releases/download/v2.7.2.windows.1/Git-2.7.2-64-bit.exe" -OutFile git.exe -UseBasicParsing
Start-Process git.exe -ArgumentList '/VERYSILENT /SUPPRESSMSGBOXES /CLOSEAPPLICATIONS /DIR=c:\git\' -Wait
Remove-Item -Force git.exe
setx /M PATH "$Env:Path;c:\git\cmd"

Add-Content $Env:ProgramData\Amazon\EC2-Windows\Launch\Sysprep\BeforeSysprep.cmd '`ndel "C:\Program Files\OpenSSH-Win64\*_key*"'
Add-Content $Env:ProgramData\Amazon\EC2-Windows\Launch\Sysprep\BeforeSysprep.cmd '`ndel C:\Users\Administrator\.ssh\authorized_keys'

# TODO: remove once the shell provisioner can clean up after itself
Add-Content $Env:ProgramData\Amazon\EC2-Windows\Launch\Sysprep\BeforeSysprep.cmd '`ndel C:\provision.ps1'

Add-Content $Env:ProgramData\Amazon\EC2-Windows\Launch\Sysprep\SysprepSpecialize.cmd '`npushd "C:\Program Files\OpenSSH-Win64" & .\ssh-keygen.exe -A & popd'
Add-Content $Env:ProgramData\Amazon\EC2-Windows\Launch\Sysprep\SysprepSpecialize.cmd '`npowershell -c "$ProgressPreference = ''SilentlyContinue'' ; New-Item -ErrorAction Ignore -Type Directory ~\.ssh ; Invoke-WebRequest http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key -UseBasicParsing -OutFile ~\.ssh\authorized_keys"'

& $Env:ProgramData\Amazon\EC2-Windows\Launch\Scripts\InitializeInstance.ps1 -Schedule
& $Env:ProgramData\Amazon\EC2-Windows\Launch\Scripts\SysprepInstance.ps1
