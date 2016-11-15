# How to use

## Build AMI

```
packer build template.json
...
--> amazon-ebs: AMIs were created:
us-west-2: <ami-id>
```

## Create and log into instance created from AMI

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

**Not complete**

```
Get-EC2PasswordData -InstanceId <instance-id> -PemFile <key-file-path> -Region us-west-2
<password>
(Get-EC2Instance -InstanceId <instance-id> -Region us-west-2).Instances[0].PublicIpAddress
<ip-address>
```

# TODO

 * Debloat more
 * SSH only works after logging in with RDP
 	- hardcode password and login during sysprep finalize, then disable that password
	- find another way to init the account
 	-login with password auth first
 * Disable password auth after first login
 * Disable Admin password
 * Disable remote RDP
 * Load the keys into agent

# Notes

 * The provision script cannot contain comments because line-endings are not preserved
 * A password login is required before passwordless login works

# Resources

 * http://jen20.com/2015/04/02/windows-amis-without-the-tears.html
 * http://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/ec2launch.html
 * https://github.com/jhowardmsft/docker-w2wCIScripts (Jenkins setup)