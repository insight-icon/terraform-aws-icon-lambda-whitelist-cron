# terraform-aws-icon-lambda-whitelist

**WIP**

Lambda function to update the security groups on a cron job. This will allow security groups to be kept reasonably up 
to date by updating the security groups on a timer. 

The function is deployed via terraform and uses terraform within the function itself to change the security groups. 
It does this by pulling the ip whitelist, renders a jinja template to come up with a new list of security group rules, 
and the applies those changes to the security groups.

IP List: https://download.solidwallet.io/conf/prep_iplist.json

The JSON file will contain the list of IPs. You should configure your firewalls to allow in/outbound traffic from/to 
the IP addresses. Following TCP ports should be open.

- Port 7100: Used by gRPC for peer to peer communication between nodes.
- Port 9000: Used by JSON-RPC API server.

The IP whitelist will be automatically updated on a daily basis from the endpoint of the seed node inside the 
P-Rep Node Docker.

## Future Work 

- This is just the cron version of this and in the future we will be moving the trigger to a respond to an SQS que that 
is fed events off of alarms.  This is going to need some planning and testing as it all breaks down to how often the 
network needs to be adjusted / reconfigured.  
- Comments welcome at the [ICON Forum](https://forum.icon.community/t/ip-whitelisting-lambda-function/120)


## Issues 

- Need NAT to access both VPC resources (ie the security groups we're updating) and the public internet. 
    - [Source](https://stackoverflow.com/questions/36508974/python-request-in-aws-lambda-timing-out)
    - Will need to run NAT 