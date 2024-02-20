#!/bin/sh

until curl -k -s https://wso2:9443
do
    echo "Waiting for wso2 to be ready"
    sleep 5
done

apictl add env production         --apim https://wso2:9443         --token https://wso2:9443/oauth2/token

apictl login production -u admin -p admin -k

apictl import policy rate-limiting  -f /production/Application-5PerMin.yaml -e production -k

apictl import api -f /production/httpbin_1.0.0.zip -e production -k

apictl import app -f /production/admin_DemoApplication.zip -e production -o admin -k

apictl import app -f /production/admin_UnlimitedApp.zip -e production -o admin -k

