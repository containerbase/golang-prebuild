FROM ghcr.io/containerbase/base:13.0.7@sha256:a5dff667bb43c80408b4ca70800642511a491c219485e3207fc04811763f542e

ENTRYPOINT [ "dumb-init", "--", "builder.sh" ]

COPY bin /usr/local/bin

ENV TOOL_NAME=golang

RUN install-builder.sh
