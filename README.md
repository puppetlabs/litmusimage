# litmusimage

This repository creates docker image files, for testing puppet modules with
services with [Puppet Litmus][1].

The images have initd, systemd or upstart, along with SSH.

Images get uploaded to [Docker Hub][2] automatically and are rebuilt [nightly if
necessary][3].

## Buildable images

| IMAGE | TAG | DOCKERFILE | BASE_IMAGE | BASE_IMAGE_TAG |
| ------| ----| -----------| -----------| ---------------|
| ubuntu | 14.04 | apt_initd_dockerfile | ubuntu | 14.04 |
| ubuntu | 16.04 | apt_systemd_dockerfile | ubuntu | 16.04 |
| ubuntu | 18.04 | apt_sysvinit-utils_dockerfile | ubuntu | 18.04 |
| ubuntu | 20.04 | apt_sysvinit-utils_dockerfile | ubuntu | 20.04 |
| centos | 6 | yum_initd_dockerfile | centos | 6 |
| centos | 7 | yum_systemd_dockerfile | centos | 7 |
| centos | 8 | yum_systemd_dockerfile | centos | 8 |
| scientificlinux | 6 | yum_initd_dockerfile | scientificlinux/sl | 6 |
| scientificlinux | 7 | yum_systemd_dockerfile | scientificlinux/sl | 7 |
| oraclelinux | 6 | yum_initd_dockerfile | oraclelinux | 6 |
| oraclelinux | 7 | yum_systemd_dockerfile | oraclelinux | 7 |
| debian | 8 | apt_systemd_dockerfile | debian | 8 |
| debian | 9 | apt_systemd_dockerfile | debian | 9 |
| debian | 10 | apt_sysvinit-utils_dockerfile | debian | 10 |

## Manual Building

```
docker build --rm --no-cache -t litmusimage/$IMAGE:$TAG . -f $DOCKERFILE --build-arg BASE_IMAGE_TAG=$BASE_IMAGE_TAG --build-arg OS_TYPE=$BASE_IMAGE
```

For example with `BASE_IMAGE=ubuntu`, `DOCKERFILE=apt_initd_dockerfile`,
`IMAGE=ubuntu` and `TAG=14.04`:

```
docker build --rm --no-cache -t litmusimage/ubuntu:14.04 . -f apt_initd_dockerfile --build-arg BASE_IMAGE_TAG=14.04 --build-arg OS_TYPE=ubuntu
```

## Push said image

```
# docker login
docker image push litmusimage/centos:7
```

## Tips and tricks for docker wrangling

```
# List running and stopped containers
docker container ls -a
# remove a container
docker rm -f ubuntu_14.04-2224
# remove all containers
docker rm -f $(docker ps -a -q)
# jump into a container, force a shell
docker exec -it litmusimage_debian9_-2223 /bin/bash
# attach to a container ( limited by what pid 0 is)
docker attach litmusimage_ubuntu16.04_-2222
# safely exit a container, leaving it running
<ctrl> + p then <ctrl> + q
# get the latest version of the image
docker pull debian:8
# show the history of the image
docker image history litmusimage/ubuntu16.04
# remove all docker images that are on your local machine
docker rmi $(docker images -q)
```

## Add new images

* Add/change dockerfile for the new image
* Every dockerfile needs a `base_image` label where the base image id will be
  stored. This will be used in the nightly build to identify if the base image
  has been updated.
* Change [workflows][4] to build the new images
* New images will be pushed to dockerhub only on pushes to the master branch,
  and will be updated nightly in case the base image has changed

## Future improvements

* Use a centralized file (possibly CSV, JSON or YAML) with the images and
  corresponding `docker build` parameters rather than having it duplicated in
  every workflow.
* Optimize building by using fewer layers or using multi-stage builds (needs to
  take care of correctly basing on base image)
* Introduce variants with puppet agent pre-installed for `litmus:install_agent`

[1]: https://github.com/puppetlabs/puppet_litmus/wiki
[2]: https://hub.docker.com/u/litmusimage
[3]: https://github.com/puppetlabs/litmus_image/blob/master/.github/workflows/nightly.yml
[4]: https://github.com/puppetlabs/litmus_image/tree/master/.github/workflows
