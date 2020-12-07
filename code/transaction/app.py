from flask import Flask
import requests
import sys
import logging
import simplejson as json
import urllib
from flask import request
from flask import Response
from flask import Blueprint
from flask import session
from flask import jsonify
from flask import make_response
from datetime import date
app = Flask(__name__)

with open('secret-key.config', 'r') as file:
    key = str(file.read())
app.config["SECRET_KEY"] = key

customer = {
    "name": "http://t3customer:30000/api/v1/customer"
}

cart = {
    "name": "http://t3cart:30003/api/v1/cart"
}

bp = Blueprint('app', __name__)


@bp.route('/health')
def health():
    return Response("", status=200, mimetype="application/json")


@bp.route('/readiness')
def readiness():
    return Response("", status=200, mimetype="application/json")

@bp.route('/', methods=['PUT'])
def check_balance():
    if session.get("customer_id") is None:
        return Response(json.dumps({"error": "missing auth"}), status=401, mimetype='application/json')
    transaction_url = transaction[".."] + "/"
    transaction_response = requests.get(transaction_url, cookies=request.cookies)
    transaction_balance = cart_response.json
    ##check balance
    
    payload = {"column":"transaction","value":transaction}
    response = requests.put(transaction_url, json=payload, cookies=request.cookies)
    return response.json()


@bp.route('/', methods=['POST'])
def add_transaction():
    if session.get("customer_id") is None:
        return Response(json.dumps({"error": "missing auth"}), status=401, mimetype='application/json')
    transcation_url = cart["name"] + "/"
    transaction_response = requests.get(transaction_url, cookies=request.cookies)
    trasaction = trasaction_response.json
    
    payload = {"column":"transaction","value":transaction}
    customer_url = customer["name"] + "/append"
    response = requests.put(customer_url, json=payload, cookies=request.cookies)
    return response.json()


@bp.route('/', methods=['delete'])
def delete_transaction():
    if session.get("customer_id") is None:
        return Response(json.dumps({"error": "missing auth"}), status=401, mimetype='application/json')
    payload = {"objtype": "customer", "objkey": session.get("customer_id")}
    url = transaction['transaction'] + '/'
    response = requests.get(url, cookies=request.cookies)
    
    if response.json()["Count"] != 1:
        return make_response(jsonify("error", "invalid customer id"), 404)
    transaction = response.json()["transaction"][0]
    return jsonify(transaction)


app.register_blueprint(bp, url_prefix='/api/v1/history/')

if __name__ == '__main__':
    if len(sys.argv) < 2:
        logging.error("missing port arg 1")
        sys.exit(-1)

    p = int(sys.argv[1])
    app.run(host='0.0.0.0', port=p, threaded=True)