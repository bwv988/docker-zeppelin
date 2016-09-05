#!/usr/bin/python3
# RS05092016
# This is a dirty script to change Hive-related JDBC interpreter settings at runtime.
# Based on: https://community.hortonworks.com/articles/36031/sample-code-to-automate-interacting-with-zeppelin.html

ZEPPELIN_PORT = '9090'
ZEPPELIN_INTEPRETER_URL = 'http://localhost:' + ZEPPELIN_PORT + '/api/interpreter/setting/'
HIVE_URL = 'jdbc:hive2://hive:10000'
HIVE_USER = 'hiveuser'
HIVE_PASSWORD = 'hiveuser'
HIVE_JDBC1 = 'org.apache.hive:hive-jdbc:0.14.0'
HIVE_JDBC2 = 'org.apache.hadoop:hadoop-common:2.6.0'

# Use PUT HTTP method to send changed settings to Zeppelin.
def put_request(url, body):
    import json
    import urllib.request as ur

    print('POSTing request to: ' + url)

    params = json.dumps(body).encode('utf-8')
    req = ur.Request(url, data=params,
                             headers={'content-type': 'application/json;charset=UTF-8'})
    req.get_method = lambda: 'PUT'
    r = ur.urlopen(req)

    # This error handling is messy af.
    if r.getcode() == 200:
        print('Successfully updated Zeppelin JDBC interpreter config.')
    else:
        print("Error posting changes.")

# FIXME: Haven't done Python in a while, why do I have to import this twice? Namespace?
import json
import urllib.request as ur

# Read current configuration settings via Zeppelin API.
raw_data = ur.urlopen(ZEPPELIN_INTEPRETER_URL).read().decode('utf-8')
current_settings = json.loads(raw_data)

# Locate JDBC settings JSON.
for body in current_settings['body']:
    if body['group'] == 'jdbc':
        jdbcbody = body

#print('\nBefore modification:\n')
#print(jdbcbody)

# Set properties related to Hive.
jdbcbody['properties']['hive.url'] = HIVE_URL
jdbcbody['properties']['hive.user'] = HIVE_USER
jdbcbody['properties']['hive.password'] = HIVE_PASSWORD

# Add dependency for Hive JDBC connector.
def add_dependency(body, dep):
    dependency = dict()
    dependency['groupArtifactVersion'] = dep
    body['dependencies'].append(dependency)

add_dependency(jdbcbody, HIVE_JDBC1)
add_dependency(jdbcbody, HIVE_JDBC2)


print('\n\nAfter modification:\n')
print(jdbcbody)

put_request(ZEPPELIN_INTEPRETER_URL + jdbcbody['id'], jdbcbody)
