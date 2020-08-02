#!/bin/bash

BUILD_DATE=`printf '%(%Y-%m-%d)T' -1`
BUILD_REPO=`git config --get remote.origin.url`
BUILD_REPO_REF=`git log -1 --format="%H"`

docker build --no-cache \
 --build-arg BASE_IMAGE=ecpe4s/centos7-base-x86_64:2020-08-01 \
 --build-arg COMPILER_FROM_SYSTEM="gcc@4.8.5" \
 --build-arg COMPILER_FROM_SPACK="gcc@8.1.0" \
 --build-arg SPACK_REPO=https://github.com/spack/spack.git \
 --build-arg SPACK_REPO_REF=f3cb3a2eb8991cdfa131abcb429f13903911db1f \
 --build-arg SPACK_ROOT=/opt/spack \
 --build-arg BUILD_DATE=${BUILD_DATE} \
 --build-arg BUILD_REPO=${BUILD_REPO} \
 --build-arg BUILD_REPO_REF=${BUILD_REPO_REF} \
 -t ecpe4s/centos7-runner-x86_64:${BUILD_DATE} .
