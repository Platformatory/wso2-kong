#!/bin/bash

if [ "$#" -ne 1 ]; then
    printf "Usage: $0 <gateway>\n\nExamples:\n./check_response_header.sh wso2\n./check_response_header.sh kong"
    exit 1
fi

gateway="$1"

access_token=""
api_base_url=""

if [ $gateway == "wso2" ]; then
	api_base_url="localhost:8243"
	access_token=`curl -s -k -X POST https://localhost:9443/oauth2/token -d "grant_type=client_credentials" -H "Authorization: Basic ekJmSm5DQ2ZZZlBrWDhwNnFRZmVvcmVyMXlNYTpaVTJUQVZLbWREVUVfZVpoVWZIRWpRb3hMaGth" | jq -r .access_token`
elif [ $gateway == "kong" ]; then
	api_base_url="localhost:8443"
        access_token=`curl -s -X POST --url "https://localhost:8443/anything/oauth2/token"   --data "grant_type=client_credentials"   --data "scope=default"   --data "client_id=zBfJnCCfYfPkX8p6qQfeorer1yMa"   --data "client_secret=ZU2TAVKmdDUE_eZhUfHEjQoxLhka"   --insecure | jq -r .access_token`
else
	echo "Gateway needs to be either wso2 or kong"
	exit 1
fi

api_url="https://$api_base_url/anything"

rate_limit=5

echo -e "Testing if API is rate limited after $rate_limit requests in a minute\n"

message=""

for requests in {1..6}; do

echo -en "Calling the API ... Request count - $requests \r"
response_code=$(curl -k -s -o /dev/null -w "%{http_code}" -X GET -H "Authorization: Bearer $access_token" "$api_url")

message="API returned response code $response_code after $(($requests-1)) requests"

sleep 1

done

if  [ $response_code == 429 ]; then
	echo -e "\e[92m\x1B[1m  ✓ Success:\e[0m $message"
	exit 0
elif [ $response_code != 429 ]; then
	echo -e "\e[91m\x1B[1m  ✗ Failure:\e[0m $message"
       exit 1	
fi


