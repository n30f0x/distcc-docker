#!/bin/bash
docker build -t distcc . && docker run --rm -t -d distcc:latest
