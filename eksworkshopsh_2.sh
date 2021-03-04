rm -vf ${HOME}/.aws/credentials
sudo curl --silent --location -o /usr/local/bin/kubectl \
   https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.11/2020-09-18/bin/linux/amd64/kubectl
sudo chmod +x /usr/local/bin/kubectl
echo 'yq() {
  docker run --rm -i -v "${PWD}":/workdir mikefarah/yq "$@"
}' | tee -a ~/.bashrc && source ~/.bashrc
kubectl completion bash >>  ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion
echo 'export LBC_VERSION="v2.0.0"' >>  ~/.bash_profile
.  ~/.bash_profile
cd ~/environment
echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bash_profile
echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bash_profile
aws configure set default.region ${AWS_REGION}
aws configure get default.region
aws sts get-caller-identity --query Arn | grep eksworkshop-admin -q && echo "IAM role valid" || echo "IAM role NOT valid"

ssh-keygen -b 2048 -t rsa -f /home/ec2-user/.ssh/id_rsa -q -N ""
aws ec2 import-key-pair --key-name "eksworkshop" --public-key-material file://~/.ssh/id_rsa.pub
aws kms create-alias --alias-name alias/eksworkshop --target-key-id $(aws kms create-key --query KeyMetadata.Arn --output text)
export MASTER_ARN=$(aws kms describe-key --key-id alias/eksworkshop --query KeyMetadata.Arn --output text)
echo "export MASTER_ARN=${MASTER_ARN}" | tee -a ~/.bash_profile
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv -v /tmp/eksctl /usr/local/bin
eksctl completion bash >> ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion


cat << EOF > eksworkshop.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eksworkshop-eksctl
  region: ap-southeast-1
  version: "1.17"

availabilityZones: ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]

managedNodeGroups:
- name: nodegroup
  desiredCapacity: 3
  ssh:
    allow: true
    publicKeyName: eksworkshop

# To enable all of the control plane logs, uncomment below:
# cloudWatch:
#  clusterLogging:
#    enableTypes: ["*"]

secretsEncryption:
  keyARN: ${MASTER_ARN}
EOF


eksctl create cluster -f eksworkshop.yaml
kubectl get nodes
echo "if we see our 3 nodes, we know we have authenticated correctly"
echo "Please continue to https://www.eksworkshop.com/030_eksctl/test/ to export parameters"
