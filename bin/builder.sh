#!/bin/bash

set -e

# shellcheck source=/dev/null
. /usr/local/containerbase/util.sh
# shellcheck source=/dev/null
. /usr/local/containerbase/utils/v2/overrides.sh

# trim leading v
TOOL_VERSION=${1#v}

farch=amd64

if [[ "${ARCHITECTURE}" = "aarch64" ]]; then
  farch=arm64
fi

if [[ "${DEBUG}" == "true" ]]; then
  set -x
fi

check_semver "${TOOL_VERSION}" all

echo "Building ${TOOL_NAME} ${TOOL_VERSION} for ${ARCHITECTURE}"

# fix version, only for go 1.20 and below
fversion=${TOOL_VERSION}
if [[ ($MAJOR -lt 1 || ($MAJOR -eq 1 && $MINOR -lt 21)) && "${PATCH}" == "0" ]]; then
  fversion="${MAJOR}.${MINOR}"
fi


expected_checksum=$(jq -r ".[] | select(.version == \"go${fversion}\") | .files[] | select(.os == \"linux\" and .arch == \"${farch}\") | .sha256" < /tmp/go-versions.json)
file=$(get_from_url \
    "https://dl.google.com/go/go${fversion}.linux-${farch}.tar.gz" \
    "golang-v${TOOL_VERSION}-linux-${farch}.tar.xz" \
    "${expected_checksum}" \
    "sha256sum" )

if [[ "$file" == "" ]]; then
  echo "Download error"
  exit 1
fi

versioned_tool_path=$(create_versioned_tool_path)

tar -C "${versioned_tool_path}" --strip 1 -xf "${file}"

echo "------------------------"
echo "Testing ${TOOL_NAME} ${TOOL_VERSION} for ${ARCHITECTURE}"
"${versioned_tool_path}/bin/go" version
"${versioned_tool_path}/bin/go" env

echo "------------------------"
echo "Compressing ${TOOL_NAME} ${TOOL_VERSION} for ${ARCHITECTURE}"
tar -cJf "/cache/${TOOL_NAME}-${TOOL_VERSION}-${ARCHITECTURE}.tar.xz" -C "$(find_tool_path)" "${TOOL_VERSION}"
