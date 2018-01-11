#!/bin/bash -e

git -C ~/devops checkout master && git -C ~/devops pull && \
sudo apt-get -y update && \
sudo apt-get -y upgrade && \
sudo apt-get -y dist-upgrade && \
sudo apt-get -y autoremove
