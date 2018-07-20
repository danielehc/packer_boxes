# Adjust root filesystem

export DEBIAN_FRONTEND=noninteractive

# Update the box
apt-get -qqy update
apt-get -qqy dist-upgrade
apt-get -qqy install linux-headers-$(uname -r) build-essential

# Install development tools
apt-get install -qqy unzip curl jq net-tools dnsutils curl wget vim \
  mc screen lsof htop iotop dstat telnet tcpdump jq gnupg git psmisc lynx

# Remove unneeded items
apt-get -qy purge exim4 exim4-base

# Set up sudo
echo 'vagrant ALL=NOPASSWD:ALL' > /etc/sudoers.d/vagrant

# Disable barriers on root filesystem
sed -i 's/noatime,errors/nobarrier,noatime,nodiratime,errors/' /etc/fstab

# Tweak sshd to prevent DNS resolution (speed up logins)
echo 'UseDNS no' >> /etc/ssh/sshd_config

# Remove 5s grub timeout to speed up booting
cat <<EOF > /etc/default/grub
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.

GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX="debian-installer=en_US"
EOF

update-grub

reboot
