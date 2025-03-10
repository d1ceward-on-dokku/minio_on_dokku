![](.github/images/repo_header.png)

[![Minio](https://img.shields.io/badge/Minio-28/02/2025-blue.svg)](https://github.com/minio/minio/releases/tag/RELEASE.2025-02-28T09-55-16Z)
[![Dokku](https://img.shields.io/badge/Dokku-Repo-blue.svg)](https://github.com/dokku/dokku)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/d1ceward-on-dokku/minio_on_dokku/graphs/commit-activity)
# Run Minio on Dokku

## Perquisites

### What is Minio?

Minio is an object storage server that is API compatible with the Amazon S3 cloud storage service. You can find more information about Minio on the [minio.io](https://www.minio.io/) website.

### What is Dokku?

[Dokku](http://dokku.viewdocs.io/dokku/) is a lightweight implementation of a Platform as a Service (PaaS) that is powered by Docker. It can be thought of as a mini-Heroku.

### Requirements
* A working [Dokku host](http://dokku.viewdocs.io/dokku/getting-started/installation/)
* [Letsencrypt](https://github.com/dokku/dokku-letsencrypt) plugin for SSL (optionnal)

# Setup

**Note:** Throughout this guide, we will use the domain `minio.example.com` for demonstration purposes. Make sure to replace it with your actual domain name.

## Create the app

Log into your Dokku host and create the Minio app:

```bash
dokku apps:create minio
```

## Configuration

### Setting root user

Minio uses a username/password combination (`MINIO_ROOT_USER` and `MINIO_ROOT_PASSWORD`) for authentication and object management. Set these environment variables using the following commands:

```bash
dokku config:set minio MINIO_ROOT_USER=<username>
dokku config:set minio MINIO_ROOT_PASSWORD=<password>
```

### Increase the upload size limit

To modify the upload limit, you need to adjust the `CLIENT_MAX_BODY_SIZE` environment variable used by Dokku. In this example, we set it to a maximum value of 10MB:

```bash
dokku config:set minio CLIENT_MAX_BODY_SIZE=10M
```

## Persistent storage

To ensure that uploaded data persists between restarts, we create a folder on the host machine, grant write permissions to the user defined in the Dockerfile, and instruct Dokku to mount it to the app container. Follow these steps:

```bash
dokku storage:ensure-directory minio --chown false
dokku storage:mount minio /var/lib/dokku/data/storage/minio:/data
```

## Domain setup

To enable routing for the Minio app, we need to configure the domain. Execute the following command:

```bash
dokku domains:set minio minio.example.com
```

## Push Minio to Dokku

### Grabbing the repository

Begin by cloning this repository onto your local machine.

#### Via SSH

```bash
git clone git@github.com:d1ceward-on-dokku/minio_on_dokku.git
```

#### Via HTTPS

```bash
git clone https://github.com/d1ceward-on-dokku/minio_on_dokku.git
```

### Set up git remote

Now, set up your Dokku server as a remote repository.

```bash
git remote add dokku dokku@example.com:minio
```

### Push Minio

Now, you can push the Minio app to Dokku. Ensure you have completed this step before moving on to the [next section](#ssl-certificate).

```bash
git push dokku master
```

## SSL certificate

Lastly, let's obtain an SSL certificate from [Let's Encrypt](https://letsencrypt.org/).

```bash
# Install letsencrypt plugin
dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git

# Set certificate contact email
dokku letsencrypt:set minio email you@example.com

# Generate certificate
dokku letsencrypt:enable minio
```

## Wrapping up

Congratulations! Your Minio instance is now up and running, and you can access it at [https://minio.example.com](https://minio.example.com).

### Minio web console

To access the Minio web console and manage your files, you need to configure the necessary proxy settings. The following commands will help you set it up:

```bash
# If ssl enabled
dokku proxy:ports-add minio https:<desired_port>:9001

# If ssl disabled (note scheme change)
dokku proxy:ports-add minio http:<desired_port>:9001
```

Replace `<desired_port>` with the port number you prefer. By default, Minio uses port `9001`.

After setting up the proxy, you can access the Minio web console by visiting [https://minio.example.com:9001](https://minio.example.com:9001) in your web browser.

### Web console share links issue

To resolve an issue with share links generated by the console pointing to the Docker container IP instead of your Minio instance, you can use the following command:

```bash
dokku config:set minio \
  MINIO_SERVER_URL=https://minio.example.com \
  MINIO_BROWSER_REDIRECT_URL=https://minio.example.com:9001
```

This command sets the appropriate environment variables to ensure that share links correctly point to your Minio instance at https://minio.example.com and utilize the configured port.

Now you're all set to use Minio and leverage its powerful features for your storage needs. Happy file management!
