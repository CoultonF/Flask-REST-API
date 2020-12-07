from flask import Flask
import requests
import sys
import logging
import simplejson as json
import urllib
import time
from flask import request
from flask import Response
from flask import Blueprint

app = Flask(__name__)
bp = Blueprint('app', __name__)
db = {
    "name": "http://t3db:30002/api/v1/datastore",
    "endpoint": [
        "read",
        "write",
        "delete",
        "update"
    ]
}

@bp.route('/', methods=['GET'])
def hello_world():
    return 'This is the default route for the warehouse service. It is supposed to return a list of all the products in the warehouse (maybe implement via table cursor)'

@bp.route('/health')
def health():
    return Response("", status=200, mimetype="application/json")

@bp.route('/readiness')
def readiness():
    return Response("", status=200, mimetype="application/json")


@bp.route('/<product_id>', methods=['GET'])
def get_product(product_id):
    # if session.get("product_id") is None:
    #     return Response(json.dumps({"error": "missing auth"}), status=401, mimetype='application/json')
    payload = {"objtype": "product", "objkey": product_id}
    url = db['name'] + '/' + db['endpoint'][0]
    response = requests.get(url, params=payload)
    return response.json()

@bp.route('/', methods=['POST'])
def create_product():
    try:
        content = request.get_json()
        product_name = content['product']
        product_quantity = content['quantity']
        product_price = content['price']
    except: 
        return json.dumps({"message": "error reading arguments"})
    url = db['name'] + '/' + db['endpoint'][1]
    response = requests.post(url, json = {"objtype":"product", "product": product_name, "quantity": product_quantity, "price": product_price})
    return response.json()


@bp.route('/<product_id>', methods=['PUT'])
def update_product(product_id):
    try:
        content = request.get_json()
        attr = content['attr']
        value = content['value']
    except:
        return json.dumps({"message": "error reading arguments", "payload": request.get_json()})
    url = db['name'] + '/' + db['endpoint'][3]
    response = requests.put(url, params={"objtype": "product", "objkey": product_id},
                            json={attr: value})
    return response.json()


app.register_blueprint(bp, url_prefix='/api/v1/warehouse/')
if __name__ == '__main__':
    if len(sys.argv) < 2:
        logging.error("missing port arg 1")
        sys.exit(-1)

    p = int(sys.argv[1])
    app.run(host='0.0.0.0', port=p, debug=True, threaded=True)

