#!/usr/bin/env bash

pkg="unzip curl jq net-tools dnsutils curl wget vim mc screen lsof htop iotop dstat telnet tcpdump jq gnupg git psmisc lynx"

for p in ${pkg} ; do echo "describe package('${p}') do
  it { should be_installed }
end
"
done
