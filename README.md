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

# Buildable images

## systemd and yum
this builds el 7 systems eg oraclelinux 7 and centos 7 
```
docker build --rm --no-cache -t waffleimage/centos7 . -f yum_systemd_dockerfile --build-arg BASE_IMAGE_TAG=7 --build-arg OS_TYPE=centos
# or
docker build --rm --no-cache -t waffleimage/oraclelinux7 . -f yum_systemd_dockerfile --build-arg BASE_IMAGE_TAG=7 --build-arg OS_TYPE=oraclelinux
```
