from flask import Flask
import requests
import sys
import logging
import boto3
import simplejson as json
import urllib.parse
import uuid
import os
from boto3.dynamodb.conditions import Key, Attr
from flask import request
from flask import Response
from flask import Blueprint
from decimal import Decimal

app = Flask(__name__)
bp = Blueprint('app', __name__)

# default to us-east-1 if no region is specified
# (us-east-1 is the default/only supported region for a starter account)
region = os.environ.get('AWS_REGION', 'us-east-1')

# these must be present; if they are missing, we should probably bail now
access_key = os.environ.get('AWS_ACCESS_KEY_ID')
secret_access_key = os.environ.get('AWS_SECRET_ACCESS_KEY')

# this is only needed for starter accounts
session_token = os.environ.get('AWS_SESSION_TOKEN')

# if session_token is not present in the environment, assume it is a
# standard acct which doesn't need one; otherwise, add it on.
if not session_token:
    dynamodb = boto3.resource('dynamodb',
                              region_name=region,
                              aws_access_key_id=access_key,
                              aws_secret_access_key=secret_access_key)
else:
    dynamodb = boto3.resource('dynamodb',
                              region_name=region,
                              aws_access_key_id=access_key,
                              aws_secret_access_key=secret_access_key,
                              aws_session_token=session_token)


@bp.route('/update', methods=['PUT'])
def update():
    content = request.get_json()
    objtype = urllib.parse.unquote_plus(request.args.get('objtype'))
    objkey = urllib.parse.unquote_plus(request.args.get('objkey'))
    table_name = objtype.capitalize()
    table_id = objtype + "_id"
    expression = 'SET '
    x = 1
    attrvals = {}
    for k in content.keys():
        expression += k + ' = :val' + str(x) + ', '
        attrvals[':val' + str(x)] = content[k]
        x += 1
    expression = expression[:-2]
    table = dynamodb.Table(table_name)
    response = table.update_item(Key={table_id: objkey},
                                 UpdateExpression=expression,
                                 ExpressionAttributeValues=attrvals)
    return response


@bp.route('/read', methods=['GET'])
def read():
    objtype = urllib.parse.unquote_plus(request.args.get('objtype'))
    objkey = urllib.parse.unquote_plus(request.args.get('objkey'))
    table_name = objtype.capitalize()
    table_id = objtype + "_id"
    table = dynamodb.Table(table_name)
    response = table.query(Select='ALL_ATTRIBUTES', KeyConditionExpression=Key(table_id).eq(objkey))
    return response


@bp.route('/write', methods=['POST'])
def write():
    content = request.get_json()
    table_name = content['objtype'].capitalize()
    objtype = content['objtype']
    table_id = objtype + "_id"
    payload = {table_id: str(uuid.uuid4())}
    del content['objtype']
    for k in content.keys():
        payload[k] = content[k]
    table = dynamodb.Table(table_name)
    response = table.put_item(Item=payload)
    returnval = ''
    if response['ResponseMetadata']['HTTPStatusCode'] != 200:
        returnval = {"message": "fail"}
    return json.dumps(({table_id: payload[table_id]}, returnval)['returnval' in globals()])


@bp.route('/delete', methods=['DELETE'])
def delete():
    content = request.get_json()
    objtype = urllib.parse.unquote_plus(request.args.get('objtype'))
    objkey = urllib.parse.unquote_plus(request.args.get('objkey'))
    table_name = objtype.capitalize()
    table_id = objtype + "_id"
    expression = 'SET '
    x = 1
    attrvals = {}
    for k in content.keys():
        expression += k + ' = :val' + str(x) + ', '
        attrvals[':val' + str(x)] = content[k]
        x += 1
    expression = expression[:-2]
    table = dynamodb.Table(table_name)
    response = table.update_item(Key={table_id: objkey},
                                 UpdateExpression=expression,
                                 ExpressionAttributeValues=attrvals)
    return response


@bp.route('/remove', methods=['PUT'])
def remove():
    content = request.get_json()
    try:
        col = content['col']
        idx = content['idx']
    except:
        return "Error reading db remove params."
    objtype = urllib.parse.unquote_plus(request.args.get('objtype'))
    objkey = urllib.parse.unquote_plus(request.args.get('objkey'))
    table_name = objtype.capitalize()
    table_id = objtype + "_id"
    table = dynamodb.Table(table_name)
    response = table.update_item(Key={table_id: objkey},
                                 UpdateExpression="REMOVE #col[" + str(idx) + "]",
                                 ExpressionAttributeNames={"#col": col},
                                 ReturnValues="UPDATED_NEW")
    return response


@bp.route('/append', methods=['PUT'])
def append():
    content = request.get_json()
    try:
        col = content['col'] #returns
        val = content['val'] # {"product":"word", "q":1, "price":100}
    except:
        return "Error reading db append params."
    objtype = urllib.parse.unquote_plus(request.args.get('objtype'))
    objkey = urllib.parse.unquote_plus(request.args.get('objkey'))
    table_name = objtype.capitalize()
    table_id = objtype + "_id"
    table = dynamodb.Table(table_name)
    response = table.update_item(Key={table_id: objkey},
                                 UpdateExpression="SET #col = list_append(#col, :val)",
                                 ExpressionAttributeNames={"#col": col},
                                 ExpressionAttributeValues={':val': json.loads(val, parse_float=Decimal)},
                                 ReturnValues="UPDATED_NEW")
    return response


@bp.route('/modify', methods=['PUT'])
def modify():
    content = request.get_json()
    try:
        col = content['col']
        idx = content['idx']
        fld = content["fld"]
        val = content['val']
    except:
        return "Error reading db modify params."
    objtype = urllib.parse.unquote_plus(request.args.get('objtype'))
    objkey = urllib.parse.unquote_plus(request.args.get('objkey'))
    table_name = objtype.capitalize()
    table_id = objtype + "_id"
    table = dynamodb.Table(table_name)
    response = table.update_item(Key={table_id: objkey},
                                 UpdateExpression="SET #col[" + str(idx) + "].#fld = :val",
                                 ExpressionAttributeNames={"#col": col, "#fld": fld},
                                 ExpressionAttributeValues={':val': json.loads(json.dumps({"v":val}), parse_float=Decimal)['v']},
                                 ReturnValues="UPDATED_NEW")
    return response


@bp.route('/health')
def health():
    return Response("", status=200, mimetype="application/json")


@bp.route('/readiness')
def readiness():
    return Response("", status=200, mimetype="application/json")


app.register_blueprint(bp, url_prefix='/api/v1/datastore/')

if __name__ == '__main__':
    if len(sys.argv) < 2:
        logging.error("missing port arg 1")
        sys.exit(-1)

    p = int(sys.argv[1])
    app.run(host='0.0.0.0', port=p, debug=True, threaded=True)