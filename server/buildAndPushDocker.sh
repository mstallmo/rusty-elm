#!/usr/bin/env bash
$(aws ecr get-login --no-include-email --region us-east-1)

docker build . -t rusty-elm-server --build-arg DATABASE_URL=postgres://postgres:docker@localhost/rusty_elm

docker tag rusty-elm-server:latest 222747461323.dkr.ecr.us-east-1.amazonaws.com/rusty-elm-server:latest

docker push 222747461323.dkr.ecr.us-east-1.amazonaws.com/rusty-elm-server:latest
