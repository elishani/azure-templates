#!/bin/bash
apt update

install docker.io
systemctl start docker
systemctl enable docker
