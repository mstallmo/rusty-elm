#!/usr/bin/env bash
docker build . -t rusty-elm-server --build-arg DATABASE_URL=postgres://postgres:docker@localhost/rusty_elm