# syntax=docker/dockerfile:1

# Build the elementary-xfce icon themes in an isolated environment.
#
# Export the built themes to ./dist:
#   docker build --output type=local,dest=dist .
#
# The resulting image contains only the themes under /usr/share/icons, so it
# can also be used as a source in other images:
#   COPY --from=elementary-xfce /usr/share/icons/ /usr/share/icons/

ARG UBUNTU_VERSION=24.04

FROM ubuntu:${UBUNTU_VERSION} AS builder

ARG PREFIX=/usr

# Build dependencies (see README.md)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gcc \
        gtk-update-icon-cache \
        libc6-dev \
        libgdk-pixbuf-2.0-dev \
        librsvg2-common \
        make \
        optipng \
        pkgconf \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

COPY . .

RUN ./configure --prefix="${PREFIX}" \
    && make \
    && make install DESTDIR=/out \
    && make icon-caches DESTDIR=/out

# Minimal final stage containing only the installed themes
FROM scratch

COPY --from=builder /out/ /
