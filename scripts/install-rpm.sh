#!/bin/bash
apt update

apt -y install docker.io
systemctl start docker
systemctl enable docker
