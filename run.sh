#!/bin/bash
docker build -t distcc . && docker run --network host --rm -t -d distcc:latest
