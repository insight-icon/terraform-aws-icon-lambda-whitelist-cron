import os
import sys
from jinja2 import Environment, FileSystemLoader
import botocore.vendored.requests as requests

def lambda_handler(event, context):
    try:
        json_whitelist = requests.get("https://download.solidwallet.io/conf/prep_iplist.json")
        print(json_whitelist.json())
        templates_dir = os.path.join(os.path.curdir, 'templates')
        os.listdir(templates_dir)
        env = Environment(loader=FileSystemLoader(templates_dir))
        render_dict = {'ip_list': json_whitelist.json(), 'group': 'p-rep'}

        rendered_tpl = env.get_template('main.tf').render(render_dict)
        print(rendered_tpl)

    except Exception as e:
        print(e)
        raise e
