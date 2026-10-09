# syntax=docker/dockerfile:1.7
#
# PCOM - DS - Minio (AGPL-3.0)
# ----------------------------
# MinIO server and the mc client built from source. Server tag RELEASE.2025-04-22T22-12-26Z is the last community
# release whose embedded Console still has the full admin screens (users, groups, policies, buckets, service accounts).
# The recipe in this repository is Apache-2.0; the resulting binaries are AGPL v3 (licenses are copied into /licenses).
#
# Build:
#   docker build -t pcom-ds-minio-agpl:RELEASE.2025-04-22-v1 .

ARG go_image=docker.io/library/golang
ARG go_version=1.24-bookworm
ARG base_image=docker.io/nubonativesolution/pcom-brc-ubuntu
ARG base_version=22.04-v1

FROM ${go_image}:${go_version} AS build
ARG MINIO_TAG=RELEASE.2025-04-22T22-12-26Z
ARG MC_TAG=RELEASE.2025-04-16T18-13-26Z
ENV CGO_ENABLED=0 GOFLAGS=-trimpath
WORKDIR /src/minio
RUN git clone --depth 1 --branch "${MINIO_TAG}" https://github.com/minio/minio.git .
RUN go build -tags kqueue -ldflags "$(go run buildscripts/gen-ldflags.go)" -o /out/minio . \
 && /out/minio --version
WORKDIR /src/mc
RUN git clone --depth 1 --branch "${MC_TAG}" https://github.com/minio/mc.git .
RUN go build -ldflags "$(go run buildscripts/gen-ldflags.go)" -o /out/mc . \
 && /out/mc --version

FROM ${base_image}:${base_version}

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION="RELEASE.2025-04-22-v1"

LABEL org.opencontainers.image.title="pcom-ds-minio-agpl" \
      org.opencontainers.image.description="MinIO RELEASE.2025-04-22 (AGPL-3.0) with the mc client, built from source on the PCOM Ubuntu base." \
      org.opencontainers.image.vendor="Nubo Native Platform" \
      org.opencontainers.image.licenses="AGPL-3.0-only" \
      org.opencontainers.image.source="https://github.com/NNP-Platform-Components-PCOM/PCOM-DS-Minio-Agpl" \
      org.opencontainers.image.url="https://github.com/NNP-Platform-Components-PCOM/PCOM-DS-Minio-Agpl" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.created="${BUILD_DATE}"

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl; \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /out/minio /usr/bin/minio
COPY --from=build /out/mc /usr/bin/mc
COPY --from=build /src/minio/LICENSE /licenses/MINIO-LICENSE
COPY --from=build /src/minio/CREDITS /licenses/MINIO-CREDITS
COPY --from=build /src/mc/LICENSE /licenses/MC-LICENSE
COPY --from=build /src/mc/CREDITS /licenses/MC-CREDITS

EXPOSE 9000 9001
VOLUME ["/data"]
ENTRYPOINT ["/usr/bin/minio"]
CMD ["server", "/data", "--console-address", ":9001"]
