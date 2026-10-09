# PCOM-DS-Minio-Agpl

NNP Data Store (DS) component. MinIO server `RELEASE.2025-04-22T22-12-26Z` and the `mc` client
`RELEASE.2025-04-16T18-13-26Z`, built from source. This is the last community release whose embedded
Console has the full admin screens (users, groups, policies, buckets, service accounts).

Published to Docker Hub on every push to `main`:

```
docker.io/nubonativesolution/pcom-ds-minio-agpl:RELEASE.2025-04-22-v1
docker.io/nubonativesolution/pcom-ds-minio-agpl:latest
```

Architecture: `linux/amd64`. CI/CD via the shared [PCOM-CICD](https://github.com/NNP-Platform-Components-PCOM/PCOM-CICD) reusable pipeline.

Ports: `9000` S3 API, `9001` web Console.

Run: `docker run -e MINIO_ROOT_USER=... -e MINIO_ROOT_PASSWORD=... -p 9000:9000 -p 9001:9001 -v data:/data <image>`

## License
The build recipe in this repository is Apache-2.0 (see `LICENSE`). The MinIO and mc binaries it produces are
**GNU AGPL v3**; their licenses and credits are copied into `/licenses`. Unmodified use as an internal service
does not trigger AGPL source-offer duties; if you modify MinIO and offer it over a network you must publish your changes.
