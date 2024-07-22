#-------------------------
# renovate rebuild trigger
# https://go.dev/doc/devel/release
#-------------------------

# makes lint happy
FROM scratch

# renovate: datasource=docker depName=golang
ENV GO_VERSION=1.21.12

# renovate: datasource=docker depName=golang
ENV GO_VERSION=1.22.5
