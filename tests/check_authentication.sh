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

response_code_with_authn=$(curl -k -s -o /dev/null -w "%{http_code}" -X GET -H "Authorization: Bearer $access_token" "$api_url")

response_code_without_authn=$(curl -k -s -o /dev/null -w "%{http_code}" -X GET "$api_url")

echo -e "Testing API with and without OAuth authentication token header\n"

message_for_with_authn="API returned response code $response_code_with_authn for request with the OAuth token"
message_for_without_authn="API returned response code $response_code_without_authn for request without the OAuth token"

if [ $response_code_with_authn == 200 ] && [ $response_code_without_authn == 401 ]; then
	echo -e "\e[92m\x1B[1m  ✓ Success:\e[0m $message_for_with_authn"
	echo -e "\e[92m\x1B[1m  ✓ Success:\e[0m $message_for_without_authn"
	exit 0
elif [ $response_code_with_authn == 200 ] && [ $response_code_without_authn != 401 ]; then
	echo -e "\e[92m\x1B[1m  ✓ Success:\e[0m $message_for_with_authn"
	echo -e "\e[91m\x1B[1m  ✗ Failure:\e[0m $message_for_without_authn"
	exit 1
elif [ $response_code_with_authn != 200 ] && [ $response_code_without_authn == 401 ]; then
	echo -e "\e[91m\x1B[1m  ✗ Failure:\e[0m $message_for_with_authn"
	echo -e "\e[92m\x1B[1m  ✓ Success:\e[0m $message_for_without_authn"
	exit 1
else
	echo -e "\e[91m\x1B[1m  ✗ Failure:\e[0m $message_for_with_authn"
	echo -e "\e[91m\x1B[1m  ✗ Failure:\e[0m $message_for_without_authn"
	exit 1
fi

