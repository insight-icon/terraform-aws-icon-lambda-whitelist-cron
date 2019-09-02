# terraform-aws-icon-lambda-whitelist


IP List: https://download.solidwallet.io/conf/prep_iplist.json

ICON foundation will maintain the IP list of P-Reps. The JSON file will contain the list of IPs. You should configure your firewalls to allow in/outbound traffic from/to the IP addresses. Following TCP ports should be open.
Port 7100: Used by gRPC for peer to peer communication between nodes.
Port 9000: Used by JSON-RPC API server.
The IP whitelist will be automatically updated on a daily basis from the endpoint of the seed node inside the P-Rep Node Docker.