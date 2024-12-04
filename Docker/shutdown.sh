#!/bin/bash

# Script Name: shutdown.sh
# Description: Shutdown all running containers.

set -e

docker stop $(docker ps -q)