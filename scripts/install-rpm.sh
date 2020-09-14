#!/bin/bash
dpkg --configure -a
apt -y update
apt -y install docker
