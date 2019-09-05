import os
import subprocess
import shlex
from jinja2 import Environment, FileSystemLoader
import botocore.vendored.requests as requests
import logging
import zipfile


logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info('## ENVIRONMENT VARIABLES')
    logger.info(os.environ)
    logger.info('## EVENT')
    logger.info(event)
    logger.info('## CONTEXT')
    logger.info(context)

    try:
        # TODO just testing
        logger.info('Downloading terraform')
        requests.get('https://releases.hashicorp.com/terraform/0.12.6/terraform_0.12.6_linux_amd64.zip')
        with zipfile.ZipFile('terraform_0.12.6_linux_amd64.zip', 'r') as zip_ref:
            zip_ref.extractall('.')

        logger.info('Downloading whitelist')
        whitelist_url = r'https://download.solidwallet.io/conf/prep_iplist.json'
        logger.info('## URL')
        logger.info(whitelist_url)
        json_whitelist = requests.get(whitelist_url)
        logger.info('## JSON')
        logger.info(json_whitelist.json())
        templates_dir = os.path.join(os.path.curdir, 'templates')
        env = Environment(loader=FileSystemLoader(templates_dir))
        render_dict = {'ip_list': json_whitelist.json()}

        rendered_tpl = env.get_template('main.tf').render(render_dict)
        logger.info('## RENDERED TF TEMPLATE')
        logger.info(rendered_tpl)
        # file = open('testfile.txt)
        with open('rendered_security_groups.tf', 'w') as f:
            f.write(rendered_tpl)

        subprocess.call(shlex.split('terraform init'))
        subprocess.call(shlex.split('terraform apply'))

    except Exception as e:
        logger.info(e)
        raise e
