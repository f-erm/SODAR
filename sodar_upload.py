import requests
import os
import yaml
from time import sleep

### Authorization. Directly from Sodar documentation ###

sodar_url = 'https://sodar.bihealth.org/' 
user_uuid = '' # Your user UUID: See the User Profile in top right corner
api_token = '' # Your API token: Create in SODAR in top right corner settings
category_uuid = '' # Your Lab: On SODAR select you lab category and copy uuid from url

# Headers for requests (Don't touch this):
auth_header = {'Authorization': 'token {}'.format(api_token)}
# Use project_headers for project management API endpoints
project_headers = {**auth_header, 'Accept': 'application/vnd.bihealth.sodar-core.projectroles+json; version=2.0'}
# Use the following headers for sample sheet and landing zone API endpoints
sheet_headers = {**auth_header, 'Accept': 'application/vnd.bihealth.sodar.samplesheets+json; version=1.2'}
zone_headers = {**auth_header, 'Accept': 'application/vnd.bihealth.sodar.landingzones+json; version=1.1'}



### Wrappers

def get_project_uuid_from_fullpath(path):
    return path.strip("/").split("/")[3]

def create_delete_request_from_fullpath(path):
    payload = {"path" : path}
    project_uuid = get_project_uuid(path)
    url = f'{sodar_url}/samplesheets/api/irods/request/create/{project_uuid}'
    response_data = requests.post(url, headers=sheet_headers, json=payload).json()
    return response_data

def show_response(response):
    for key in response.keys():
        print(key)
        print(response_data[key])

def create_project(name):
    url = f'{sodar_url}/project/api/create'
    data = {'title': name, 'type': 'PROJECT', 'parent':
            category_uuid, 'owner': user_uuid, 'public_access': None}
    project_data = requests.post(url, json=data, headers=project_headers).json()
    project_uuid = project_data['sodar_uuid']
    return(project_uuid)

'''
#This does not work as of now!
def update_project(project_uuid,data):
    url = f'{sodar_url}/project/api/settings/set/{project_uuid}'
    response = requests.post(url, json=data, headers=project_headers).json()
    return(response)
data = {'plugin_name' : 'projectroles', 'setting_name'
        : 'notify_email_project', 'value': False }
print(update_project(project_uuid,data))
'''

def upload_samplesheet(sheet_path,project_uuid):
    url = f'{sodar_url}/samplesheets/api/import/{project_uuid}'
    file_name = path.split("/")[-1]
    files = {'file': (file_name, open(sheet_path, 'rb'), 'application/zip')}
    response = requests.post(url, files=files, headers=sheet_headers)
    return(response.json())

def get_assay_uuid(project_uuid):
    url = f'{sodar_url}/samplesheets/api/investigation/retrieve/{project_uuid}'
    project_data = requests.get(url, headers=sheet_headers).json()
    assay_uuid = project_data['studies']
    assay_uuid = assay_uuid[next(iter(assay_uuid))]
    assay_uuid = assay_uuid['assays']
    assay_uuid = next(iter(assay_uuid))
    return (assay_uuid)

def create_IRODS_collection(project_uuid):
    url = f'{sodar_url}/samplesheets/api/irods/collections/create/{project_uuid}'
    response = requests.post(url, headers=sheet_headers)

def create_landing_zone(project_uuid, assay_uuid):
    url = f'{sodar_url}/landingzones/api/create/{project_uuid}'
    data = {'assay': assay_uuid}
    response = requests.post(url, json=data, headers=zone_headers)
    zone_uuid = response.json().get('sodar_uuid')
    return(zone_uuid)

def get_landing_zone_info(zone_uuid,attribute):
    url = f'{sodar_url}/landingzones/api/retrieve/{zone_uuid}'
    response = requests.get(url, headers=zone_headers)
    return(response.json().get(attribute))


### Create new project and start upload

with open("config.yaml", "r") as f:
    config = yaml.safe_load(f)
out = config["out"]
NAME = config["sample_id"]
INPUT = os.path.join(out, "landing", "input")
SHEET_PATH = os.path.join(out, f'{NAME}.zip')

project_uuid = create_project(NAME)
print(f'Created project "{NAME}". Make sure to visit\nhttps://sodar.bihealth.org/project/update/{project_uuid}\nand uncheck "Notify members of landing zone uploads"' )
upload_samplesheet(sheet_path,project_uuid):
assay_uuid = get_assay_uuid(project_uuid)
create_IRODS_collection(project_uuid)
zone_uuid = create_landing_zone(project_uuid,assay_uuid)
while (get_landing_zone_info(zone_uuid,'status') != 'ACTIVE'):
    sleep(1)
IRODS_PATH = get_landing_zone_info(zone_uuid,'irods_path')
print('Landing zone created. To start uploading type the following command (Make sure you have authenticated via iinit before):')
print(f'irsync -r -a -K {INPUT} {IRODS_PATH}')



