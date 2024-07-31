FROM ghcr.io/containerbase/base:11.6.1@sha256:39e66e7419e16a73c790e253dbf564eb44a9e0c7972be4bc0d16fb383f63fd4d

ENTRYPOINT [ "dumb-init", "--", "builder.sh" ]

COPY bin /usr/local/bin

ENV TOOL_NAME=golang

RUN install-builder.sh
