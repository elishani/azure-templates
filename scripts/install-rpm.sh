#!/bin/bash
apt update

apt install docker.io
systemctl start docker
systemctl enable docker
