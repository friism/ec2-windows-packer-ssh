# Packer temlate for building Windows with SSH public key authentication

This Packer template builds AWS AMIs that support login with SSH public key auth. The public key is provisioned using the AWS EC2 key infrastructure.

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

```
ssh -i <key-path> Administrator@<ip-address>
```

## Building Windows AMIs with OpenSSH

The chief concern when using these templates and building on AMIs generated with them, is making sure that the public key from the AWS metadata service is writte to the Administrator user's `~\.ssh\authorized_keys` directory on booth. There are two general ways to achieve this:

 * Do `sysprep` and make sure the key is written when an instance is launched from the sysprepped AMI. The key will only be re-written if another sysprep is done.
 * Pass in `userdata` script that writes the key from metadata. This has to be passed on every boot.

# TODO

 * Clean up the Packer builder to better support Windows
 * Don't restart at the end of builder-userdata.ps1 if possible
 * Figure out startup script that fetches public key from metadata API (perhaps using local group policy)

# Resources

 * http://jen20.com/2015/04/02/windows-amis-without-the-tears.html
 * http://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/ec2launch.html
 * https://github.com/jhowardmsft/docker-w2wCIScripts (Jenkins setup)
