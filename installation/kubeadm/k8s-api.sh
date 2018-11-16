#!/bin/sh

docker rm -f k8s-api &> /dev/null

docker run -d --name k8s-api -it -v $(pwd):/usr/local/etc/haproxy:ro -p 9000:9000 -p 0.0.0.0:443:443 haproxy:1.8.14
