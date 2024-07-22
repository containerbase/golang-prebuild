#!/bin/bash

set -e

mkdir -p /usr/local/golang /cache

curl -sSLf "https://go.dev/dl/?mode=json&include=all" -o /usr/local/golang/versions.json

