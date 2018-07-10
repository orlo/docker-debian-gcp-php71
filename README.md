# Public Docker image

See also: https://hub.docker.com/r/socialsigninapp/docker-debian-gcp-php71/

## Building

```bash
docker build --build-arg http_proxy=http://192.168.0.66:3128 --build-arg https_proxy=http://192.168.0.66:3128 .
```

## Todo

 * Add checksum checking on the downloaded pecl tgz files.
 * Link better to Debian/Debsury.org so we rebuild on change of those files
