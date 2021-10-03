import json
import re

def test_handler_1(event,conext):
    response = {
        "statusCode": 200,
        "body": json.dumps({"message": "Test Handler One(1) Called"}),
        "headers": {
            "Access-Control-Allow-Origin": "*"
        }
    }
    return response

def test_handler_2(event, conext):
    response = {
        "statusCode": 200,
        "body": json.dumps({"message": "Test handler two(2) called"}),
        "headers": {
            "Access-Control-Allow-Origin": "*"
        }
    }
    return response

def test_handler_3(event, conext):
    response = {
        "statusCode": 200,
        "body": json.dumps({"message": "Test handler three(3) called"}),
        "headers": {
            "Access-Control-Allow-Origin": "*"
        }
    }
    return response

PATHS_MAP = {
    "GET": [{
        "path": "/public/assets",
        "handler": test_handler_1
    },{
        "path": "/public/assets/:config",
        "handler": test_handler_2
    },{
        "path": "/public/assets/:config/:newId",
        "handler": test_handler_3
    }],
    "PUT": [],
    "POST": [],
    "DELETE": []
}

event = {
    'requestContext': {
        'path': '/back-office/assets/hello/',
        'httpMethod': 'POST'
    }
}

def event_handler(event, context):
    req_path = event['path']
    req_method = event['httpMethod']
    paths_list = PATHS_MAP[req_method]
    matched_handler = None
    # dynamic_path_pattern = r'<(.*?)>'
    for config in paths_list:
        if config['path'] == req_path:
            matched_handler = config['handler']
            break #main loop

        if ':' in config['path']: #dynamic path logic
            split_config_path = config['path'].split('/')
            split_req_path = req_path.split('/')
            
            if len(split_config_path) != len(split_req_path):
                continue #main loop

            is_temporary_path_matched = True
            for index, req_sub_path in enumerate(split_req_path):
                config_sub_path = split_config_path[index]
                req_sub_path_is_empty = req_sub_path == ''
                if config_sub_path.startswith(':') and  not req_sub_path_is_empty: 
                    continue #nested loop
                if config_sub_path != req_sub_path:
                    is_temporary_path_matched = False
                    break #nested loop
            if is_temporary_path_matched:
                matched_handler = config['handler']
                break #main loop

    if(matched_handler):
        return matched_handler(event, context)
    
    return {
        "statusCode": 500,
        "body": json.dumps({
            "message": "Unable find handlers :(", 
            "httpPath": req_path,
            "httpMethod": req_method
        }),
        "headers": {
            "Access-Control-Allow-Origin": "*"
        }
    }

# d = event_handler(event, {})
# print(d)