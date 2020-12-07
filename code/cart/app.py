from flask import Flask
import requests
import sys
import logging
import simplejson as json
import urllib
import jwt
import time
from flask import request
from flask import Response
from flask import Blueprint
from flask import session
from datetime import date
from flask import jsonify
from flask import make_response

app = Flask(__name__)
with open('secret-key.config', 'r') as file:
    key = str(file.read())
app.config["SECRET_KEY"] = key
bp = Blueprint('app', __name__)
customer = {
    "name": "http://t3customer:30000/api/v1/customer",
    "endpoint": [
        "update"
]
}
warehouse = {
    "name": "http://t3warehouse:30001/api/v1/warehouse",
    "endpoint": [
        "update"
    ]
}


@bp.route('/health')
def health():
    return Response("", status=200, mimetype="application/json")


@bp.route('/readiness')
def readiness():
    return Response("", status=200, mimetype="application/json")


@bp.route('/', methods=['PUT'])
def add_to_cart():
    if session.get("customer_id") is None:
        return Response(json.dumps({"error": "missing auth"}), status=401, mimetype='application/json')
    try:
        content = request.get_json()
        quantity = content['quantity']
        product_id = content['product_id']
    except:
        return json.dumps({"message": "error reading params"})
    warehouse_url = warehouse["name"] + "/" + product_id
    product_response = requests.get(warehouse_url, cookies=request.cookies)
    product = product_response.json()
    if product['Count'] > 0 and product["Items"][0]['quantity'] >= quantity:
        product = product["Items"][0]
        stock = product['quantity']
        warehouse_url = warehouse["name"] + "/" + product_id
        requests.put(warehouse_url,
                     json={'attr': 'quantity', 'value': stock - quantity})
        cart = json.dumps([{"product_id": product_id,
                           "product": product['product'],
                           "price": product['price'],
                           "quantity": quantity}])
        payload = {"column": "cart", "value": cart}
        customer_url = customer["name"] + "/append"
        response = requests.put(customer_url, json=payload, cookies=request.cookies)
        return response.text
    else:
        return json.dumps({"message": "error not enough inventory"})


@bp.route('/', methods=['GET'])
def get_cart():
    if session.get("customer_id") is None:
        return Response(json.dumps({"error": "missing auth"}), status=401, mimetype='application/json')
    url = customer['name'] + '/'
    response = requests.get(url, cookies=request.cookies)
    if response.json()["Count"] != 1:
        return make_response(jsonify("error", "invalid customer id"), 404)
    cart = response.json()
    cart["Items"][0] = {"cart":cart["Items"][0]["cart"]}
    return cart


app.register_blueprint(bp, url_prefix='/api/v1/cart/')
if __name__ == '__main__':
    if len(sys.argv) < 2:
        logging.error("Usage: app.py <service-port>")
        sys.exit(-1)

    p = int(sys.argv[1])
    app.run(host='0.0.0.0', port=p, debug=True, threaded=True)