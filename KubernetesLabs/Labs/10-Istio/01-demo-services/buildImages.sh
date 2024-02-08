#!/bin/bash

# Login to docker hub in order to push the images
docker login -u nirgeier

# Build and push the images
docker-compose build && docker-compose push