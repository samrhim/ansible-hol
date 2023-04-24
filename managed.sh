#!/bin/sh
echo "Managed Node Preparation ..."
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
dnf makecache
dnf update -y
dnf install -y python39 bind-utils

sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd

PASS=$(echo "ansible" | openssl passwd -1 -stdin)
useradd -p "$PASS" ansible
cat <<EOF > /etc/sudoers.d/ansible
ansible ALL=NOPASSWD: ALL
EOF

cat <<EOF >> /etc/hosts
192.168.4.200 control.example.com
192.168.4.201 ansible1.example.com
192.168.4.202 ansible2.example.com
EOF
