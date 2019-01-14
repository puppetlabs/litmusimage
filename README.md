# waffle_image
Repository for docker image files, for testing nix services 

Look here for the latest images https://cloud.docker.com/u/waffleimage/repository/list

# Buildable images
| Script | Supported OSes | Example Build Command |
| ------------- | ------------- | ------------- |
|  yum_systemd_dockerfile | centos 7, oraclelinux  7 | docker build --rm --no-cache -t waffleimage/oraclelinux7 . -f yum_systemd_dockerfile --build-arg BASE_IMAGE_TAG=7 --build-arg OS_TYPE=oraclelinux |
|  apt_systemd_dockerfile | debian 8/9, ubuntu 14.04/16.04| docker build --rm --no-cache -t waffleimage/debian9 . -f apt_systemd_dockerfile --build-arg BASE_IMAGE_TAG=9 --build-arg OS_TYPE=debian |
|  apt_sysvinit-utils_dockerfile | ubuntu 18.04 | docker build --rm --no-cache -t waffleimage/ubuntu18.04 . -f apt_sysvinit-utils_dockerfile --build-arg BASE_IMAGE_TAG=18.04 --build-arg OS_TYPE=ubuntu |

# Push said image

```
# docker login
docker image push waffleimage/centos7
```
