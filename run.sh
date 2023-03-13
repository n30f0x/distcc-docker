#!/bin/bash
docker build -t distcc . && docker run -t -d -p 3632:3632 -p 3633:3633 -p 5353:5353 distcc:latest
