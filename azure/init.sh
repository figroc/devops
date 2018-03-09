#!/bin/bash -e
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 52E16F86FEE04B979B07E28DB02C46DF417A0893
sudo apt-get update && sudo apt-get install -y apt-transport-https
sudo apt-get update && sudo apt-get install -y azure-cli

az cloud set -n AzureChinaCloud
az configure -d location=chinaeast
az login
