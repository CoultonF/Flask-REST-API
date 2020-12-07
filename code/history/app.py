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
app = Flask(__name__)

with open('secret-key.config', 'r') as file:
    key = str(file.read())
app.config["SECRET_KEY"] = key

customer = {
    "name": "http://t3customer:30000/api/v1/customer",
    "endpoint": [
        "append",
        "update"
    ]
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
def create_history():
    if session.get("customer_id") is None:
        return Response(json.dumps({"error": "missing auth"}), status=401, mimetype='application/json')
    cart_url = cart["name"] + "/"
    cart_response = requests.get(cart_url, cookies=request.cookies)
    cart_json = cart_response.json()
    try:
        if cart_json["Count"] > 0:
            cart_items = json.dumps(cart_json["Items"][0]["cart"])
            payload = {"column":"history","value":cart_items}
            customer_append_url = customer["name"] + "/" + customer["endpoint"][0]
            customer_url = customer["name"] + "/"
            response = requests.put(customer_append_url, json=payload, cookies=request.cookies)
            requests.put(customer_url, json={"cart": []}, cookies=request.cookies)
            return response.json()
        else:
            return make_response(jsonify("error", "Cart is empty"), 404)
    except:
        return make_response(jsonify("error", "Invalid cart"), 500)


@bp.route('/', methods=['GET'])
def get_history():
    if session.get("customer_id") is None:
        return Response(json.dumps({"error": "missing auth"}), status=401, mimetype='application/json')
    url = customer['name'] + '/'
    response = requests.get(url, cookies=request.cookies)
    if response.json()["Count"] != 1:
        return make_response(jsonify("error", "invalid customer id"), 404)
    returns = response.json()["Items"][0]["history"]
    return make_response(jsonify(returns), 200)


app.register_blueprint(bp, url_prefix='/api/v1/history/')

if __name__ == '__main__':
    if len(sys.argv) < 2:
        logging.error("missing port arg 1")
        sys.exit(-1)

    p = int(sys.argv[1])
    app.run(host='0.0.0.0', port=p, threaded=True)