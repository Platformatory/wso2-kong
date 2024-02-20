#!/bin/bash
  
if [ "$#" -ne 1 ]; then
    printf "Usage: $0 <gateway>\n\nExamples:\n./check_response_header.sh wso2\n./check_response_header.sh kong"
    exit 1
fi

client_id="jIAgvdTbbZr5VSRSk3kwb3L51_wa"
client_secret="sVUDpi77hrcWGCwlZAfE9tDo5Ysa"

gateway="$1"

access_token=""
api_base_url=""

if [ $gateway == "wso2" ]; then
        api_base_url="localhost:8243"
        access_token=`curl -s -k -X POST https://localhost:9443/oauth2/token -d "grant_type=client_credentials" -H "Authorization: Basic $(echo -n "$client_id:$client_secret" | base64)" | jq -r .access_token`
elif [ $gateway == "kong" ]; then
        api_base_url="localhost:8443"
        access_token=`curl -s -X POST --url "https://localhost:8443/anything/oauth2/token"   --data "grant_type=client_credentials"   --data "scope=default"   --data "client_id=$client_id"   --data "client_secret=$client_secret"   --insecure | jq -r .access_token`
else
        echo "Gateway needs to be either wso2 or kong"
        exit 1
fi

api_url="https://$api_base_url/anything"

echo -e "Running a benchmark for the API\n" 

echo -e "GET $api_url\nAuthorization:Bearer $access_token" | vegeta attack -insecure -keepalive=false -duration=5s | tee results.bin | vegeta report

rm results.bin
