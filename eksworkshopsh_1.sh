sudo pip install --upgrade awscli && hash -r
sudo yum -y install jq gettext bash-completion moreutils
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
export InstanceID=$(aws ec2 describe-instances --filters Name=instance-type,Values=t3.small --query Reservations[*].Instances[*].[InstanceId] --output text)
aws ec2 associate-iam-instance-profile --iam-instance-profile Name=eksworkshop-admin --instance-id $InstanceID
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
echo "Please do uncheck AWS Managed Security from AWS Setting in Preferences before execute 2nd part of the Script"

