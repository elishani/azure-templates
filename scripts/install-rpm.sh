#!/bin/bash
apt update
sleep 60
install docker.io
systemctl start docker
systemctl enable docker
