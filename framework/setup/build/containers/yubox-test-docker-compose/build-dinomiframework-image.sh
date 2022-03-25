#!/bin/bash

pushd docker-images/dinomiframework/ && docker build -t dinomiframework -f Dockerfile . && popd
