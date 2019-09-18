

#export AWS_ACCOUNT_ID=

export TF_VAR_terraform_state_bucket="terraform-states-$AWS_ACCOUNT_ID"
export TF_VAR_name="lambda-sg"
export TF_VAR_group="p-rep"
export TF_VAR_aws_region="us-east-1"
export TF_VAR_key="us-east-1/p-rep/lambda-sg/sterraform.tfstate"
export TF_VAR_bucket="terraform-states-$AWS_ACCOUNT_ID"
export TF_VAR_region="us-east-1"
export TF_VAR_lock_table="terraform-locks-$AWS_ACCOUNT_ID"

terraform init \
--backend-config bucket=$TF_VAR_terraform_state_bucket \
--backend-config dynamodb_table=$TF_VAR_lock_table  \
--backend-config region=$TF_VAR_aws_region \
--backend-config key=$TF_VAR_key

terraform apply --auto-approve