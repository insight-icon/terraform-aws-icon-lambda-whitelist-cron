import sys
import jinja2
from botocore.vendored import requests


def lambda_handler(event, context):
    try:
        json_whitelist = requests("https://download.solidwallet.io/conf/prep_iplist.json")
    except Exception as e:
        print(e)
        raise e
