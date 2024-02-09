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
	access_token=`curl -k -X POST https://localhost:9443/oauth2/token -d "grant_type=client_credentials" -H "Authorization: Basic ekJmSm5DQ2ZZZlBrWDhwNnFRZmVvcmVyMXlNYTpaVTJUQVZLbWREVUVfZVpoVWZIRWpRb3hMaGth" | jq -r .access_token`
elif [ $gateway == "kong" ]; then
	api_base_url="localhost:8443"
        access_token=`curl -X POST --url "https://localhost:8443/anything/oauth2/token"   --data "grant_type=client_credentials"   --data "scope=default"   --data "client_id=zBfJnCCfYfPkX8p6qQfeorer1yMa"   --data "client_secret=ZU2TAVKmdDUE_eZhUfHEjQoxLhka"   --insecure | jq -r .access_token`
else
	echo "Gateway needs to be either wso2 or kong"
	exit 1
fi

api_url="https://$api_base_url/anything"
header_name="x-custom-header"
header_value="hello-world"

response_headers=$(curl -s -k -i -X GET -H "Authorization: Bearer $access_token" "$api_url" 2>/dev/null)


if echo "$response_headers" | grep -q "$header_name: $header_value"; then
    echo "Header '$header_name: $header_value' found in the response from $api_url."
    exit 0
else
    echo "Header '$header_name: $header_value' not found in the response from $api_url."
    exit 1
fi
