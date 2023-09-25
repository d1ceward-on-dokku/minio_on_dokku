FROM registry.access.redhat.com/ubi8/ubi-minimal:8.8

ARG MINIO_VERSION="RELEASE.2023-09-23T03-47-50Z"
ARG TARGETARCH="amd64"

LABEL name="MinIO" \
      vendor="MinIO Inc <dev@min.io>" \
      maintainer="MinIO Inc <dev@min.io>" \
      version="${RELEASE}" \
      release="${RELEASE}" \
      summary="MinIO is a High Performance Object Storage, API compatible with Amazon S3 cloud storage service." \
      description="MinIO object storage is fundamentally different. Designed for performance and the S3 API, it is 100% open-source. MinIO is ideal for large, private cloud environments with stringent security requirements and delivers mission-critical availability across a diverse range of workloads."

ENV MINIO_ACCESS_KEY_FILE=access_key \
    MINIO_SECRET_KEY_FILE=secret_key \
    MINIO_ROOT_USER_FILE=access_key \
    MINIO_ROOT_PASSWORD_FILE=secret_key \
    MINIO_KMS_SECRET_KEY_FILE=kms_master_key \
    MINIO_UPDATE_MINISIGN_PUBKEY="RWTx5Zr1tiHQLwG9keckT0c45M3AGeHD6IvimQHpyRywVWGbP1aVSGav" \
    MINIO_CONFIG_ENV_FILE=config.env \
    PATH=/opt/bin:$PATH

RUN \
    curl -s -q https://raw.githubusercontent.com/minio/minio/${MINIO_VERSION}/dockerscripts/verify-minio.sh -o /usr/bin/verify-minio.sh && \
    curl -s -q https://raw.githubusercontent.com/minio/minio/${MINIO_VERSION}/dockerscripts/docker-entrypoint.sh -o /usr/bin/docker-entrypoint.sh

RUN \
    mkdir -p /licenses && \
    curl -s -q https://raw.githubusercontent.com/minio/minio/${MINIO_VERSION}/CREDITS -o /licenses/CREDITS && \
    curl -s -q https://raw.githubusercontent.com/minio/minio/${MINIO_VERSION}/LICENSE -o /licenses/LICENSE

RUN \
     microdnf clean all && \
     microdnf update --nodocs && \
     rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
     microdnf install curl ca-certificates shadow-utils util-linux gzip lsof tar net-tools iproute iputils jq minisign --nodocs && \
     mkdir -p /opt/bin && chmod -R 777 /opt/bin && \
     curl -s -q https://dl.min.io/server/minio/release/linux-${TARGETARCH}/archive/minio.${MINIO_VERSION} -o /opt/bin/minio && \
     curl -s -q https://dl.min.io/server/minio/release/linux-${TARGETARCH}/archive/minio.${MINIO_VERSION}.sha256sum -o /opt/bin/minio.sha256sum && \
     curl -s -q https://dl.min.io/server/minio/release/linux-${TARGETARCH}/archive/minio.${MINIO_VERSION}.minisig -o /opt/bin/minio.minisig && \
     curl -s -q https://dl.min.io/client/mc/release/linux-${TARGETARCH}/mc -o /opt/bin/mc && \
     microdnf clean all && \
     chmod +x /opt/bin/minio && \
     chmod +x /opt/bin/mc && \
     chmod +x /usr/bin/docker-entrypoint.sh && \
     chmod +x /usr/bin/verify-minio.sh && \
     /usr/bin/verify-minio.sh && \
     microdnf clean all

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

# Add user/group dokku
RUN groupadd -g 32767 dokku
RUN adduser -u 32767 -g dokku dokku
USER dokku

# Run the server and point to the created directory
CMD ["server", "--address", ":5000", "--console-address", ":9001", "/data"]
