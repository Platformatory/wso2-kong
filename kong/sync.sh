#!/bin/sh

until nc -zv kong-control-plane 8001
do
    echo "Waiting for kong to be ready"
    sleep 5
done

deck sync --kong-addr http://kong-control-plane:8001
