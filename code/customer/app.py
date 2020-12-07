from flask import Flask
import requests
import sys
import logging
import simplejson as json
import urllib
import jwt
import uuid
import time
from flask import request
from flask import jsonify
from flask import session
from flask import Response
from flask import Blueprint

app = Flask(__name__)
with open('secret-key.config', 'r') as file:
    key = str(file.read())
app.config["SECRET_KEY"] = key
bp = Blueprint('app', __name__)
db = {
    "name": "http://t3db:30002/api/v1/datastore",
    "endpoint": [
        "read",
        "write",
        "delete",
        "update",
        "remove",
        "append",
        "modify"
    ]
}


@bp.route('/health')
def health():
    return Response("", status=200, mimetype="application/json")


@bp.route('/readiness')
def readiness():
    return Response("", status=200, mimetype="application/json")


@bp.route('/logoff', methods=['PUT'])
def logoff():
    try:
        session.clear()
    except:
        return json.dumps({"message": "error clearing session"})
    return {}


@bp.route('/authenticate', methods=['GET'])
def authenticate():
    try:
        customer = session.get("customer_id")
    except:
        return json.dumps({"result":False, "customer_id": None})
    if customer is None:
        return json.dumps({"result":False, "customer_id": None})
    return json.dumps({"result": True, "customer_id": customer})



@bp.route('/login', methods=['PUT'])
def login():
    try:
        content = request.get_json()
        cid = content['cid']
    except:
        return json.dumps({"message": "error reading parameters"})
    url = db['name'] + '/' + db['endpoint'][0]
    response = requests.get(url, params={"objtype": "customer", "objkey": cid})
    data = response.json()
    if len(data['Items']) > 0:
        session["customer_id"] = cid
        return "Login Successful"
    return "Login Unsuccessful"


@bp.route('/', methods=['GET'])
def get_customer():
    if session.get("customer_id") is None:
        return Response(json.dumps({"error": "missing auth"}), status=401, mimetype='application/json')
    payload = {"objtype": "customer", "objkey": session.get("customer_id")}
    url = db['name'] + '/' + db['endpoint'][0]
    response = requests.get(url, params=payload)
    return response.json()


@bp.route('/', methods=['POST'])
def create_customer():
    try:
        content = request.get_json()
        lname = content['lname']
        email = content['email']
        fname = content['fname']
        returns = []
        cart = []
        history = []
    except:
        return json.dumps({"message": "error reading arguments"})
    url = db['name'] + '/' + db['endpoint'][1]
    response = requests.post(url,
                             json={"objtype": "customer", "lname": lname, "email": email,
                                   "fname": fname, "returns": returns, "cart": cart, "history": history})
    return response.json()


@bp.route('/', methods=['DELETE'])
def delete_customer():
    if session.get("customer_id") is None:
        return Response(json.dumps({"error": "missing auth"}), status=401, mimetype='application/json')
    url = db['name'] + '/' + db['endpoint'][2]

    response = requests.delete(url, params={"objtype": "customer", "objkey": session.get("customer_id")})
    return response.json()


@bp.route('/', methods=['PUT'])
def update_customer():
    if session.get("customer_id") is None:
        return Response(json.dumps({"error": "missing auth"}), status=401, mimetype='application/json')
    payload = {}
    try:
        content = request.get_json()
        for k, v in content.items():
            payload[k] = v
    except:
        return json.dumps({"message": "error reading arguments", "payload": request.get_json()})
    url = db['name'] + '/' + db['endpoint'][3]
    response = requests.put(url, params={"objtype": "customer", "objkey": session.get("customer_id")},
                            json=payload)
    return response.text


@bp.route('/remove', methods=['PUT'])
def remove():
    if session.get("customer_id") is None:
        return Response(json.dumps({"error": "missing auth"}), status=401, mimetype='application/json')
    try:
        content = request.get_json()
        column = content['column']
        index = content['index']
    except:
        return json.dumps({"message": "error reading arguments", "payload": request.get_json()})
    url = db['name'] + '/' + db['endpoint'][4]
    response = requests.put(url, params={"objtype": "customer", "objkey": session.get("customer_id")},
                               json={"col": column, "idx": index})
    return response.json()


@bp.route('/append', methods=['PUT'])
def append():
    if session.get("customer_id") is None:
        return Response(json.dumps({"error": "missing auth"}), status=401, mimetype='application/json')
    try:
        content = request.get_json()
        column = content["column"]
        value = content["value"]
    except:
        return json.dumps({"message": "error reading arguments", "payload": request.get_json()})
    url = db['name'] + '/' + db['endpoint'][5]
    response = requests.put(url, params={"objtype": "customer", "objkey": session.get("customer_id")},
                            json={"col": column, "val": value})
    return response.json()


@bp.route('/modify', methods=['PUT'])
def modify():
    if session.get("customer_id") is None:
        return Response(json.dumps({"error": "missing auth"}), status=401, mimetype='application/json')
    try:
        content = request.get_json()
        column = content['column']
        index = content['index']
        field = content['field']
        value = content['value']
    except:
        return json.dumps({"message": "error reading arguments", "payload": request.get_json()})
    url = db['name'] + '/' + db['endpoint'][6]
    response = requests.put(url, params={"objtype": "customer", "objkey": session.get("customer_id")},
                               json={"col": column, "val": value, "idx": index, 'fld': field})
    return response.json()


app.register_blueprint(bp, url_prefix='/api/v1/customer/')
if __name__ == '__main__':
    if len(sys.argv) < 2:
        logging.error("Usage: app.py <service-port>")
        sys.exit(-1)

    p = int(sys.argv[1])
    app.run(host='0.0.0.0', port=p, debug=True, threaded=True)
