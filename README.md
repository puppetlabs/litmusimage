# waffle_image
Repository for docker image files, for testing nix services

# How-to

To build an image.

```
docker build --rm --no-cache -t waffleimage/centos7 . -f centos_7dockerfile
```

Push said image

```
# docker login
docker image push waffleimage/centos7
```
