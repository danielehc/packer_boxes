#!/bin/bash
#%Y Year, %V Week 
DATE="`date +%Y%V`"

#delete <none> images
NONE="`docker images -q --filter "dangling=true"`"
[ "${NONE}" ] && docker rmi -f ${NONE} || true

BASE="`docker images -q stretch:${DATE}`"

if [ $BASE ]; then
  echo "skipping: found image ${BASE} for this week ${DATE}"
else
  # update stretch if exists
  # install if doesnt
  if [ -d /mnt/ssd/packer/stretch ]; then
    cp /etc/resolv.conf /mnt/ssd/packer/stretch/etc/resolv.conf
    chroot /mnt/ssd/packer/stretch apt-get update
    chroot /mnt/ssd/packer/stretch apt-get dist-upgrade -y
  else
    mkdir -p /mnt/ssd/packer/stretch/etc/dpkg/dpkg.cfg.d
    cp /etc/resolv.conf /mnt/ssd/packer/stretch/etc/resolv.conf
    cat > /mnt/ssd/packer/stretch/etc/dpkg/dpkg.cfg.d/01_nodoc <<EOF
path-exclude /usr/share/doc/*
path-include /usr/share/doc/*/copyright
path-exclude /usr/share/man/*
path-exclude /usr/share/groff/*
path-exclude /usr/share/info/*
path-exclude /usr/share/lintian/*
path-exclude /usr/share/linda/*
EOF
    which debootstrap &>/dev/null || {
      apt-get update
      apt-get install -y --force-yes debootstrap
    }
    debootstrap stretch /mnt/ssd/packer/stretch
    chroot /mnt/ssd/packer/stretch apt-get install -y --force-yes curl software-properties-common
  fi

  #clean chroot
  chroot /mnt/ssd/packer/stretch apt-get clean
  > /mnt/ssd/packer/stretch/etc/resolv.conf

  #create docker image
  pushd /mnt/ssd/packer/stretch
  tar -c . --numeric-owner -f /mnt/ssd/packer/stretch.chroot.tar 
  cat /mnt/ssd/packer/stretch.chroot.tar | docker import - stretch
  docker tag stretch:latest stretch:${DATE}
  docker save stretch:latest > /mnt/ssd/packer/stretch.docker.tar
  popd
fi

true
