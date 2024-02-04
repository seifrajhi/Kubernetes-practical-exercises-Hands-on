from flask import Flask, jsonify
from socket import gethostname
import requests
import os

app = Flask(__name__)

@app.route('/')
def main():
    print(os.environ['BACKEND_HOSTNAME'])
    response = requests.get('http://{0}:5001/api/names'.format(os.environ['BACKEND_HOSTNAME'])).json()
    return jsonify({"frontend_response": {"hostname": gethostname()}, "backend_response": response })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
    
