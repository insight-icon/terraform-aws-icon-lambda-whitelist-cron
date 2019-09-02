import os
import sys
from jinja2 import Environment, FileSystemLoader
import botocore.vendored.requests as requests

def lambda_handler(event, context):
    try:
        json_whitelist = requests.get("https://download.solidwallet.io/conf/prep_iplist.json")
        print(json_whitelist.json())
        templates_dir = os.path.join(os.path.curdir, 'templates')
        Environment(loader=FileSystemLoader(templates_dir))

    except Exception as e:
        print(e)
        raise e
