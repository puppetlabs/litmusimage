# litmus_image
Repository for docker image files, for testing nix services.

It will install systemd or upstart, along with SSH

# NB The repository still needs to be moved and the images renamed.

Look here for the latest images https://hub.docker.com/u/waffleimage

# Buildable images
| Script | Supported OSes | Example Build Command |
| ------------- | ------------- | ------------- |
|  yum_initd_dockerfile | centos 6, oraclelinux 6, scientificlinux/sl 6 | 'docker build --rm --no-cache -t waffleimage/oraclelinux6 . -f yum_initd_dockerfile --build-arg BASE_IMAGE_TAG=6 --build-arg OS_TYPE=oraclelinux' 'docker build --rm --no-cache -t waffleimage/scientificlinux6 . -f yum_initd_dockerfile --build-arg BASE_IMAGE_TAG=6 --build-arg OS_TYPE=scientificlinux/sl' |
|  yum_systemd_dockerfile | centos 7, oraclelinux 7, scientificlinux/sl 7 | 'docker build --rm --no-cache -t waffleimage/oraclelinux7 . -f yum_systemd_dockerfile --build-arg BASE_IMAGE_TAG=7 --build-arg OS_TYPE=oraclelinux' 'docker build --rm --no-cache -t waffleimage/scientificlinux7 . -f yum_systemd_dockerfile --build-arg BASE_IMAGE_TAG=7 --build-arg OS_TYPE=scientificlinux/sl' |
|  apt_systemd_dockerfile | debian 8/9, ubuntu 14.04/16.04| docker build --rm --no-cache -t waffleimage/debian9 . -f apt_systemd_dockerfile --build-arg BASE_IMAGE_TAG=9 --build-arg OS_TYPE=debian |
|  apt_sysvinit-utils_dockerfile | ubuntu 18.04 | docker build --rm --no-cache -t waffleimage/ubuntu18.04 . -f apt_sysvinit-utils_dockerfile --build-arg BASE_IMAGE_TAG=18.04 --build-arg OS_TYPE=ubuntu |

# Push said image

```
# docker login
docker image push waffleimage/centos7
```
