#!/bin/bash

VERSION=8.1
TAG=ceruleanxyz/php-fpm-mediawiki:$VERSION

docker build ./ --tag $TAG
docker push $TAG