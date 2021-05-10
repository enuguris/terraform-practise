#cloud-config
write_files:
  - path: /tmp/hostname-setup.sh
    permissions: 0755
    owner: root
    content: |
      #!/usr/bin/env bash
      set -e
      hostnamectl --static set-hostname ${host_name}
      echo "PEERDNS=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0
      echo "IPV6INIT=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0
      echo "NM_CONTROLLED=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0
      echo "NISDOMAIN=NIX_Dev" >> /etc/sysconfig/network
      echo "nameserver 8.8.4.4" >> /etc/resolv.conf
      echo "127.0.0.1 localhost.localdomain localhost" > /etc/hosts
      echo "${private_ip} ${host_name} ${host_name}.acml.com" >> /etc/hosts
      systemctl stop NetworkManager.service
      systemctl disable NetworkManager.service
      systemctl stop cloud-init.service
      systemctl disable cloud-init.service
      touch /etc/cloud/cloud-init.disabled
runcmd:
  - [sudo, /tmp/hostname-setup.sh]
  - echo test > /tmp/test.txt
