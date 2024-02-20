# Objective

This repository showcases a parity of capabilities between WSO2 and Kong, across 3 typical use-case archetypes, involving:

- Security (OAuth)
- Traffic Management (Rate Limiting)
- Mediation (Header addition)

The larger goal here is to demonstrate migration capabilities from WSO2 to the latter, particularly in legacy environments using a simple templating oriented methodology. An advanced goal that can also be achieved is using a policy translation layer that compiles to equivalent Kong plugin configuration.  We also intend to demonstrate a set of E2E integration tests that assert desired gateway functionality and help assure functional aspects of migration. These are particularly relevant for performance comparisons as well as large-scale migrations involving hundreds of API proxies.

# Comparison details 

- OAuth2 for authentication for all requests(globally) with the respective gateways as the IDP.
- Add response header of `x-custom-header: hello-world` to the GET requests
- Add a rate limit of 5 requests per minute for the demo consumer/application

## Setup

- Download version 4.2.0 of WSO2 API-M from the [official website](https://wso2.com/api-manager/) and place it in the [wso2](./wso2) directory. The file should be named `wso2am-4.2.0.zip`

```bash
docker-compose up -d

# Wait for a few seconds for the wso2 to start
```

## Test

### Scripted

```bash
# Authentication
./tests/check_authentication.sh wso2
./tests/check_authentication.sh kong

# Mediation
./tests/check_response_header.sh wso2
./tests/check_response_header.sh kong

# Rate limit
./tests/check_rate_limiting.sh wso2
./tests/check_rate_limiting.sh kong

# Benchmark (Note: you will need vegeta installed from https://github.com/tsenart/vegeta)
./tests/benchmark.sh wso2
./tests/benchmark.sh kong
```

### Manual

#### WSO2

```bash
# Get access token
export WSO2_ACCESS_TOKEN=`curl -k -X POST https://localhost:9443/oauth2/token -d "grant_type=client_credentials" -H "Authorization: Basic ekJmSm5DQ2ZZZlBrWDhwNnFRZmVvcmVyMXlNYTpaVTJUQVZLbWREVUVfZVpoVWZIRWpRb3hMaGth" | jq -r .access_token`

# Make requests and print response headers
for i in {1..10}; do curl -k -i -X 'GET'   'https://localhost:8243/anything/1.0.0'   -H 'accept: */*'   -H "Authorization: Bearer $WSO2_ACCESS_TOKEN"; done
```

#### Kong

```bash
# Get access token
export KONG_ACCESS_TOKEN=`curl -X POST   --url "https://localhost:8443/anything/oauth2/token"   --data "grant_type=client_credentials"   --data "scope=default"   --data "client_id=zBfJnCCfYfPkX8p6qQfeorer1yMa"   --data "client_secret=ZU2TAVKmdDUE_eZhUfHEjQoxLhka"   --insecure | jq -r .access_token`

# Make requests and print response headers
for i in {1..10}; do curl -i -H "Authorization: Bearer $KONG_ACCESS_TOKEN" http://localhost:8000/anything; done
```
