#!/bin/bash
#%Y Year, %V Week 
DATE="`date +%Y%V`"

#delete <none> images
NONE="`docker images -q --filter "dangling=true"`"
[ "${NONE}" ] && docker rmi -f ${NONE} || true

BASE="`docker images -q jessie:${DATE}`"

if [ $BASE ]; then
  echo "skipping: found image ${BASE} for this week ${DATE}"
else
  # update jessie if exists
  # install if doesnt
  if [ -d /mnt/ssd/packer/jessie ]; then
    cp /etc/resolv.conf /mnt/ssd/packer/jessie/etc/resolv.conf
    chroot /mnt/ssd/packer/jessie apt-get update
    chroot /mnt/ssd/packer/jessie apt-get dist-upgrade -y
  else
    mkdir -p /mnt/ssd/packer/jessie/etc/dpkg/dpkg.cfg.d
    cp /etc/resolv.conf /mnt/ssd/packer/jessie/etc/resolv.conf
    cat > /mnt/ssd/packer/jessie/etc/dpkg/dpkg.cfg.d/01_nodoc <<EOF
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
    debootstrap jessie /mnt/ssd/packer/jessie
    chroot /mnt/ssd/packer/jessie apt-get install -y --force-yes curl software-properties-common
  fi

  #clean chroot
  chroot /mnt/ssd/packer/jessie apt-get clean
  > /mnt/ssd/packer/jessie/etc/resolv.conf

  #create docker image
  pushd /mnt/ssd/packer/jessie
  tar -c . --numeric-owner -f /mnt/ssd/packer/jessie.chroot.tar 
  cat /mnt/ssd/packer/jessie.chroot.tar | docker import - jessie
  docker tag jessie:latest jessie:${DATE}
  docker save jessie:latest > /mnt/ssd/packer/jessie.docker.tar
  popd
fi

true
