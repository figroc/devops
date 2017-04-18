#!/bin/bash

ssh $1 "sudo apt -y upgrade"
ssh $1 "git -C devops pull"
