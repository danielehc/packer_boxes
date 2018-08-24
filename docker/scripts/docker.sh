#!/usr/bin/env bash
set -e

# The script only works on Debian and Ubuntu and automatically retrieves the right key and repository
DISTRO=`lsb_release -is | awk '{print tolower($0)}'`

case $DISTRO in

  debian|ubuntu)
    echo "Installing Docker for ${DISTRO} $(lsb_release -cs)"
    ;;
  *)
    echo "Distro not supported...Docker is not going to be installed"
    exit 1
    ;;
  esac


apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/${DISTRO}/gpg | apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository \
   "deb https://download.docker.com/linux/${DISTRO} \
   $(lsb_release -cs) \
   stable"
apt-get update
mkdir -p /etc/docker
#echo -e '{\n\t"storage-driver": "btrfs"\n}' > /etc/docker/daemon.json
apt-get install -y docker-ce
docker run --rm hello-world

#configure docker port
[ -f /etc/systemd/system/docker.service.d/docker.conf ] || {
  mkdir -p /etc/systemd/system/docker.service.d
  cat > /etc/systemd/system/docker.service.d/docker.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix://var/run/docker.sock
EOF
  systemctl daemon-reload
  systemctl restart docker
}
