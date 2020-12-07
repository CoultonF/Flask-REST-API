from flask import Flask
import requests
import sys
import logging
import simplejson as json
from datetime import date
from flask import request
from flask import session
from flask import Response
from flask import Blueprint
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
        "append",
        "remove"
    ]
}
history = {
    "name": "http://t3history:30005/api/v1/history"
}


@bp.route('/health')
def health():
    return Response("", status=200, mimetype="application/json")


@bp.route('/readiness')
def readiness():
    return Response("", status=200, mimetype="application/json")


@bp.route('/', methods=['PUT'])
def create_return():
    if session.get("customer_id") is None:
        return Response(json.dumps({"error": "missing auth"}), status=401, mimetype='application/json')
    try:
        content = request.get_json()
        index = content['index']
        today = date.today().strftime('%Y/%m/%d')
        history_url = history['name'] + '/'
        history_data = requests.get(history_url, cookies=request.cookies).json()[index]
        product_id = history_data['product_id']
        product = history_data['product']
        price = history_data['price']
        quantity = history_data['quantity']
    except:
        return make_response(jsonify({"error:""returns request not in history"}),404)
    returns = json.dumps([{"product_id":product_id,"product":product,"price":price,"quantity":quantity,"date":today}])
    payload = {"column":"returns","value":returns}
    customer_append_url = customer["name"] + "/" + customer["endpoint"][0]
    customer_remove_url = customer["name"] + "/" + customer["endpoint"][1]
    response = requests.put(customer_append_url, json=payload, cookies=request.cookies)
    requests.put(customer_remove_url, json={"column":"history", "index":int(index)}, cookies=request.cookies)
    return response.json()


@bp.route('/', methods=['GET'])
def get_returns():
    if session.get("customer_id") is None:
        return Response(json.dumps({"error": "missing auth"}), status=401, mimetype='application/json')
    url = customer['name'] + '/'
    response = requests.get(url, cookies=request.cookies)
    if response.json()["Count"] != 1:
        return make_response(jsonify("error", "invalid customer id"), 404)
    returns = response.json()["Items"][0]["returns"]
    return make_response(jsonify(returns), 200)

app.register_blueprint(bp, url_prefix='/api/v1/returns/')
if __name__ == '__main__':
    if len(sys.argv) < 2:
        logging.error("Usage: app.py <service-port>")
        sys.exit(-1)

    p = int(sys.argv[1])
    app.run(host='0.0.0.0', port=p, debug=True, threaded=True)