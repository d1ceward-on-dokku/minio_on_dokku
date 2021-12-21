FROM minio/minio:RELEASE.2021-12-20T22-07-16Z

# Add user/group dokku
RUN groupadd -g 32767 dokku
RUN adduser -u 32767 -g dokku dokku
USER dokku

# Run the server and point to the created directory
CMD ["server", "--address", ":9000", "--console-address", ":5000", "/data"]
