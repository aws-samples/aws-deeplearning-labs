import requests
import os
import json
import base64
from base64 import b64encode

CLUSTER_IP = os.environ.get("CLUSTER_IP", "localhost:8080")
DASHBOARD_URL = f"http://{CLUSTER_IP}"
NAMESPACE = os.environ.get("NAMESPACE", "kubeflow-user-example-com")
MODEL_NAME = os.environ.get("MODEL_NAME", "cifar")
SERVICE_HOSTNAME = os.environ.get("SERVICE_HOSTNAME", "image-classify.kubeflow-user-example-com.example.com")
URL = f"http://{CLUSTER_IP}/v1/models/{MODEL_NAME}:predict"
HEADERS = {"Host": f"{SERVICE_HOSTNAME}"}
USERNAME = os.environ.get("USERNAME", "user@example.com")
PASSWORD = os.environ.get("PASSWORD", "12341234")

response = None

def session_cookie(host, login, password):
    session = requests.Session()
    response = session.get(host)
    headers = {
        "Content-Type": "application/x-www-form-urlencoded",
    }
    data = {"login": login, "password": password}
    session.post(response.url, headers=headers, data=data)
    #print(session.cookies.get_dict())
    session_cookie = session.cookies.get_dict()["authservice_session"]
    return session_cookie

ENCODING = 'utf-8'
IMAGE_NAME = '0002.png'

# Read the Image binary
# result: bytes
with open(IMAGE_NAME, 'rb') as open_file:
    byte_content = open_file.read()

# base64 encode read data
# result: bytes 
base64_bytes = b64encode(byte_content)

# Decode bytes to text
# result: string (in utf-8)
base64_string = base64_bytes.decode(ENCODING)

# Create json data
raw_data={'instances':[{'data': base64_string}]}

headers = {'Content-type': 'application/json', 'Accept': 'text/plain'}

cookie = {"authservice_session": session_cookie(DASHBOARD_URL, USERNAME, PASSWORD)}

response = requests.post(URL, headers=HEADERS, json=raw_data, cookies=cookie)

print("Sending request to:", URL)

status_code = response.status_code
print("Status Code", status_code)
if status_code == 200:
    print("JSON Response ", json.dumps(response.json(), indent=2)) 
    
labels=['airplane', 'automobile', 'bird', 'cat', 'deer', 'dog', 'frog', 'horse', 'ship', 'truck']
    
response=response.json()
print(labels[response['predictions'][0]])
