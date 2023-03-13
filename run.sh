#!/bin/bash
docker build -t distcc . && docker run -t -d distcc:latest
