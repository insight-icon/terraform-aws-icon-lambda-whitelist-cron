# terraform-aws-icon-lambda-whitelist

**WIP**

Lambda function to update the security groups on a cron job. This will allow security groups to be kept reasonably up 
to date by updating the security groups on a timer. 

The function is deployed via terraform and uses terraform within the function itself to change the security groups. 
It does this by pulling the ip whitelist, renders a jinja template to come up with a new list of security group rules, 
and the applies those changes to the security groups.

IP List: https://download.solidwallet.io/conf/prep_iplist.json

## How this code works

1. Write the lambda function and zip it locally manually
    - The terraform binary is causing issues with zipping it with terraform functions - commented out 
    - Could DL it within script
2. Terraform deploys lambda that runs on cron 
3. Script reads the ip whitelist from endpoint using botocore requests package 
    - **There is an error here** 
    - cloudwatch error
```
Starting new HTTPS connection (1): download.solidwallet.io
```
   - Assuming we can download this endpoint, we can then do further debugging.  When we have that, we need to then 
   download the terraform binary as that is what is screwing up the packaging of the zip file with rendering the the 
   template from within terraform - see commented out archive in `main.tf`.
    - That is important as the function itself needs input variables supplied by terraform 
    - Otherwise I need to render a `tfvars` file to import the data from the terraform deployment. 
    
4. Jinja needs to be installed this way due to lambda restrictions - check docs 
5. Jinja then renders template 
    - **There is an error here** - will address in next couple days but has to do with downloading the 
6. Run terraform 
    - We still need to give it a policy to change the security groups 

## Future Work 

- This is just the cron version of this and in the future we will be moving the trigger to a respond to an SQS que that 
is fed events off of alarms.  This is going to need some planning and testing as it all breaks down to how often the 
network needs to be adjusted / reconfigured.  
- Comments welcome at the [ICON Forum](https://forum.icon.community/t/ip-whitelisting-lambda-function/120)


## Issues 

- Need NAT to access both VPC resources (ie the security groups we're updating) and the public internet. 
    - [Source](https://stackoverflow.com/questions/36508974/python-request-in-aws-lambda-timing-out)
    - Will need to run NAT 
    
```
zip -r9 ${OLDPWD}/function.zip .
```    
