#!/bin/bash

ssh $1 "sudo apt-get update"
ssh $1 "sudo apt-get -y upgrade"
ssh $1 "git -C devops pull"
