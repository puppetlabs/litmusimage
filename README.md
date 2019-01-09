# waffle_image
Repository for docker image files, for testing nix services

# How-to

To build an image.

```
docker build --rm --no-cache -t centos7:systemd . -f centos_7dockerfile
```
