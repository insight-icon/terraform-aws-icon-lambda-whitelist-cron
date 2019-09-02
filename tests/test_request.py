# import botocore.vendored.requests as requests
# import boto3

import pytest
import os

from lambda_function import lambda_handler

def test_stack_parser():

    lambda_handler(None, None)
