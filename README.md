# Docker image with Android SDK and Flutter

Based on [`openjdk:8-slim`](https://hub.docker.com/_/openjdk/) and the work of
[Álvaro S.](https://github.com/alvr/alpine-android) on installing the android
sdk.

## Building and running

```
docker build -t [image-name] .
docker run -it --entrypoint=/bin/bash [image-name]
```
