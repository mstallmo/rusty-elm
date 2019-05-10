#!/usr/bin/env bash
docker login --username=_ --password=${HEROKU_AUTH_TOKEN} registry.heroku.com

docker build . -t registry.heroku.com/rusty-elm/web --build-arg DATABASE_URL=${DATABASE_URL} --no-cache

docker push registry.heroku.com/rusty-elm/web
