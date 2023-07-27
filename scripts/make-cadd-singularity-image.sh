#!/bin/bash

set -e

# This script requires both singularity and docker to be installed.
# To use different hosts for singularity and docker, export the image with
# docker save, and use docker-archive://file.tar for singularity build.

docker build -t cadd:1.6 - < cadd_Dockerfile
singularity build ../singularity/local-cadd-v1.6.sif docker-daemon://cadd:1.6

