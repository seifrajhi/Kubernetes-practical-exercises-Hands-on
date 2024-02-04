from flask import Flask, jsonify
from socket import gethostname
from random import choice
from uuid import uuid4

names = ['james', 'john', 'frank', 'william', 'samantha', 'michelle']

app = Flask(__name__)

@app.route('/api/names')
def get_names():
    name = choice(names)
    return jsonify({"id": uuid4().hex[1:12], "hostname": gethostname(), "name": name})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
    
