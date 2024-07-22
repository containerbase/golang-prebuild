#!/bin/bash

set -e

# shellcheck source=/dev/null
. /usr/local/containerbase/util.sh
# shellcheck source=/dev/null
. /usr/local/containerbase/utils/v2/overrides.sh


setup_directories

create_tool_path > /dev/null

mkdir /cache

curl -sSLf "https://go.dev/dl/?mode=json&include=all" -o /tmp/go-versions.json

