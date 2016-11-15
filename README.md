# Packer temlate for building Windows with SSH public key authentication

This Packer template builds AWS AMIs that support login with SSH public key auth. The public key is privisioned using the AWS EC2 key infrastructure.

The template doesn't use WinRM at all, SSH is also used by the Packer builder.

# How to use

## Build AMI

```
packer build template.json
...
--> amazon-ebs: AMIs were created:
us-west-2: <ami-id>
```

## Create instance from AMI

### Using AWS CLI

```
$instanceid = aws ec2 run-instances --image-id <ami-id> --count 1 --instance-type c4.xlarge --key-name <key-name> --security-group-ids <security-group-id> --query "Instances[*].InstanceId" --output=text
aws ec2 wait password-data-available --instance-id $instanceid ; `
aws ec2 describe-instances --instance-ids $instanceid --query "Reservations[*].Instances[*].PublicIpAddress" --output=text ; `
aws ec2 get-password-data --instance-id $instanceid --priv-launch-key <key-file-path> --query "PasswordData" --output=text
<ip-address>
<password>
```

### Using Powershell

```
$instanceid = (New-EC2Instance -ImageId <ami-id> -InstanceType c4.xlarge -KeyName <key-name> -SecurityGroupId <security-group-id> -Region us-west-2).Instances[0].InstanceId
Get-EC2PasswordData -InstanceId $instanceid -PemFile <key-file-path> -Region us-west-2
<password>
(Get-EC2Instance -InstanceId $instanceid -Region us-west-2).Instances[0].PublicIpAddress
<ip-address>
```

## Log in

Unfortunately [the first login has to use a password](https://github.com/PowerShell/Win32-OpenSSH/issues/381), to activate the Windows user account. Only then can SSH keys be used for login.

The first login will initialize the `Administrator` account.

```

ssh Administrator@<ip-address> exit
<password>

ssh -i <key-path> Administrator@<ip-address>
```

# TODO

 * Clean up the Packer builder to better support Windows
 * Debloat more
 * SSH only works after logging in with RDP
 	- hardcode password and login during sysprep finalize, then disable that password
	- find another way to init the account
 	-login with password auth first
 * Disable password auth after first login
 * Disable Admin password
 * [Load the keys into agent](https://github.com/PowerShell/Win32-OpenSSH/wiki/Install-Win32-OpenSSH)
 * Consider transitioning from sysprep to just feeding in userdata when provisioning instances (it'd be less generic though)

# Notes

 * The provision script cannot contain comments because line-endings are not preserved
 * [A password login is required before public key login works](https://github.com/PowerShell/Win32-OpenSSH/issues/381)

# Resources

 * http://jen20.com/2015/04/02/windows-amis-without-the-tears.html
 * http://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/ec2launch.html
 * https://github.com/jhowardmsft/docker-w2wCIScripts (Jenkins setup)
