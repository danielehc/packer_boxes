#!/usr/bin/env bash
set -e

mkdir -p /etc/dpkg/dpkg.cfg.d
cat >/etc/dpkg/dpkg.cfg.d/01_nodoc <<EOF
path-exclude /usr/share/doc/*
path-include /usr/share/doc/*/copyright
path-exclude /usr/share/man/*
path-exclude /usr/share/groff/*
path-exclude /usr/share/info/*
path-exclude /usr/share/lintian/*
path-exclude /usr/share/linda/*
EOF

export DEBIAN_FRONTEND=noninteractive
export APTARGS="-qq -o=Dpkg::Use-Pty=0"

echo 'deb http://http.debian.net/debian jessie-backports main' | tee /etc/apt/sources.list.d/backports.list 

apt-get update ${APTARGS}
apt-get install ${APTARGS} -y -t jessie-backports openjdk-8-jdk

# vim build-essential
apt-get clean
