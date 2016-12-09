#!/usr/bin/python
import os
import time
import json
import urllib3
from urllib3.connection import UnverifiedHTTPSConnection
from urllib3.connectionpool import connection_from_url
from urllib3.util import parse_url
urllib3.disable_warnings()

# Work in progress
return 0

# Poll no more than once every 10 seconds
POLL_PERIOD = 10

if ('LAST_GET_BUILD_STATUS_TIME' in os.environ):
  print time.time() - float(os.environ['LAST_GET_BUILD_STATUS_TIME'])
  if (time.time() - float(os.environ['LAST_GET_BUILD_STATUS_TIME']) <= POLL_PERIOD):
    exit(int(os.environ['LAST_GET_BUILD_STATUS']))

http = connection_from_url('https://bucvascsweng.em.health.ge.com:8888', maxsize=2)
http.ConnectionCls = UnverifiedHTTPSConnection
r = http.request('GET', '/job/dgs-sw-coe/job/uxcast/job/sprint_11/api/json')

branch = json.loads(r.data)
branch_url = parse_url(branch['builds'][0]['url'])

r = http.request('GET', branch_url.path + 'api/json')
build = json.loads(r.data)

os.environ['LAST_GET_BUILD_STATUS_TIME'] = str(time.time())
if ('building' in build and build['building']):
  os.environ['LAST_GET_BUILD_STATUS'] = '1'
  exit(1)
elif ('result' in build and build['result'] == 'SUCCESS'):
  os.environ['LAST_GET_BUILD_STATUS'] = '0'
  exit(0)
os.environ['LAST_GET_BUILD_STATUS'] = '2'
exit(2)
