$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Web
$password = [System.Web.Security.Membership]::GeneratePassword(19,7)
$encodedPassword = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($password))

$unattendPath = "$Env:ProgramData\Amazon\EC2-Windows\Launch\Sysprep\Unattend.xml"
$xml = [xml](Get-Content $unattendPath)
$targetElememt = $xml.unattend.settings.Where{($_.Pass -eq 'oobeSystem')}.component.Where{($_.name -eq 'Microsoft-Windows-Shell-Setup')}

$autoLogonElement = [xml]('<AutoLogon>
	<Password>
		<Value>{0}</Value>
		<PlainText>false</PlainText>
	</Password>
	<Enabled>true</Enabled>
	<Username>Administrator</Username>
</AutoLogon>' -f $encodedPassword)
$targetElememt.appendchild($xml.ImportNode($autoLogonElement.DocumentElement, $true))

$userAccountElement = [xml]('<UserAccounts xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
	<AdministratorPassword>
		<Value>{0}</Value>
		<PlainText>false</PlainText>
	</AdministratorPassword>
	<LocalAccounts>
		<LocalAccount wcm:action="add">
			<Password>
				<Value>{0}</Value>
				<PlainText>false</PlainText>
			</Password>
			<Group>administrators</Group>
			<DisplayName>Administrator</DisplayName>
			<Name>Administrator</Name>
			<Description>Administrator User</Description>
		</LocalAccount>
	</LocalAccounts>
</UserAccounts>' -f $encodedPassword)
$targetElememt.appendchild($xml.ImportNode($userAccountElement.DocumentElement, $true))

$xml.Save($unattendPath)

Add-Content $Env:ProgramData\Amazon\EC2-Windows\Launch\Sysprep\BeforeSysprep.cmd 'del "C:\Program Files\OpenSSH-Win64\*_key*"'
Add-Content $Env:ProgramData\Amazon\EC2-Windows\Launch\Sysprep\BeforeSysprep.cmd 'del C:\Users\Administrator\.ssh\authorized_keys'
Add-Content $Env:ProgramData\Amazon\EC2-Windows\Launch\Sysprep\BeforeSysprep.cmd 'del C:\provision.ps1'

Add-Content $Env:ProgramData\Amazon\EC2-Windows\Launch\Sysprep\SysprepSpecialize.cmd 'powershell -ExecutionPolicy Bypass -NoProfile -c "& C:\specialize-script.ps1"'

& $Env:ProgramData\Amazon\EC2-Windows\Launch\Scripts\InitializeInstance.ps1 -Schedule
& $Env:ProgramData\Amazon\EC2-Windows\Launch\Scripts\SysprepInstance.ps1
