# waffle_image
Repository for docker image files, for testing nix services

# Buildable images
| Script | Supported OSes | Example Build Command |
| ------------- | ------------- | ------------- |
|  yum_systemd_dockerfile | centos 7, oraclelinux  7 | docker build --rm --no-cache -t waffleimage/oraclelinux7 . -f yum_systemd_dockerfile --build-arg BASE_IMAGE_TAG=7 --build-arg OS_TYPE=oraclelinux |
|  apt_systemd_dockerfile | debian 8/9, ubuntu 14.04/16.04| docker build --rm --no-cache -t waffleimage/debian9 . -f apt_systemd_dockerfile --build-arg BASE_IMAGE_TAG=9 --build-arg OS_TYPE=debian |

# Push said image

```
# docker login
docker image push waffleimage/centos7
```
