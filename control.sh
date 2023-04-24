#!/bin/sh
echo "Control Node Preparation ..."i
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

dnf update -y
dnf install -y epel-release wget
dnf makecache 
dnf install -y python39 python39-pip git bind-utils vim bash-completion
wget http://mirror.centos.org/centos/8-stream/AppStream/x86_64/os/Packages/sshpass-1.09-4.el8.x86_64.rpm
rpm -i sshpass-1.09-4.el8.x86_64.rpm

sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd

export PATH="/usr/local/bin:$PATH"
locale > /etc/locale.conf
echo 'LC_ALL="en_US.UTF-8"' >> /etc/locale.conf
python3 -m pip install ansible
PASS=$(echo "ansible" | openssl passwd -1 -stdin)
useradd -p "$PASS" ansible
cat <<EOF > /etc/sudoers.d/ansible
ansible	ALL=NOPASSWD: ALL
EOF

cat <<EOF >> /etc/hosts
192.168.4.200 control.example.com
192.168.4.201 ansible1.example.com
192.168.4.202 ansible2.example.com
EOF

su - ansible -c "ssh-keygen -b 2048 -t rsa -f /home/ansible/.ssh/id_rsa -q -P \"\""
su - ansible -c "ssh-keyscan ansible1.example.com 2>/dev/null >> home/ansible/.ssh/known_hosts"
su - ansible -c "ssh-keyscan ansible2.example.com 2>/dev/null >> home/ansible/.ssh/known_hosts"
su - ansible -c "echo 'ansible' | sshpass ssh-copy-id -f -i /home/ansible/.ssh/id_rsa.pub -o StrictHostKeyChecking=no ansible@ansible1.example.com"
su - ansible -c "echo 'ansible' | sshpass ssh-copy-id -f -i /home/ansible/.ssh/id_rsa.pub -o StrictHostKeyChecking=no ansible@ansible2.example.com"

su - ansible -c "git clone https://github.com/sandervanvugt/rhce8-live.git"
