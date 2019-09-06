#!/usr/bin/env bash
OUPTUT_DIR=$1
zip -r -q $OUPTUT_DIR/lambda_function.zip jinja2 Jinja2-2.10.1.dist-info lambda_function.py templates MarkupSafe-1.1.1.dist-info markupsafe