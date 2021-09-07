#!/bin/bash

if [[ `id -u` != 0 ]]; then
    echo "You must run this as root"
    exit 1
fi

# Install packages

yum -y update

yum -y install git

yum -y install vim

yum -y install python3

yum -y install python3-dns

yum -y install python3-netaddr

yum -y install epel-release

yum -y install python3-pyvmomi

yum -y install ansible

yum -y install xrdp

pip install --upgrade pyvmomi pyvim requests

# Install Atom

if ! dnf list installed atom; then
    curl -SLo ~/atom.rpm https://atom.io/download/rpm
    dnf -y localinstall ~/atom.rpm
fi

# Install OVF Tool

read -p 'OVF Tool location: ' OVFTOOL_LOCATION
echo 'export OVFTOOL_LOCATION='$OVFTOOL_LOCATION
curl -SLo ovftool.bundle $OVFTOOL_LOCATION
chmod u+x ovftool.bundle
./ovftool.bundle
rm -rf ovftool.bundle

# Fix Ovftool dependancy error
yum -y install libnsl

# Setup Modules for NSX-T due to VMware not setting up Ansible Galaxy properly :(
git clone https://github.com/vmware/ansible-for-nsxt.git
cp -R ansible-for-nsxt/plugins/modules/ /usr/share/ansible/plugins/
cp -R ansible-for-nsxt/plugins/module_utils/ /usr/share/ansible/plugins/
cp -R ansible-for-nsxt/plugins/doc_fragments/ /usr/share/ansible/plugins/

# Install Ansible roles

#ansible-galaxy install -r requirements.yml

# Configure XRDP

systemctl enable xrdp --now

if ! grep "xrdp8" /etc/xrdp/xrdp.ini; then
    echo '[xrdp8]' >> /etc/xrdp/xrdp.ini
    echo 'name=Reconnect' >> /etc/xrdp/xrdp.ini
    echo 'lib=libvnc.so' >> /etc/xrdp/xrdp.ini
    echo 'username=ask' >> /etc/xrdp/xrdp.ini
    echo 'password=ask' >> /etc/xrdp/xrdp.ini
    echo 'ip=127.0.0.1' >> /etc/xrdp/xrdp.ini
    echo 'port=5901' >> /etc/xrdp/xrdp.ini
fi

if ! firewall-cmd --list-ports | grep "3389"; then
    firewall-cmd --permanent --zone=public --add-port=3389/tcp
    firewall-cmd --reload
fi

# Configure VIM

FILE=/root/.vimrc
if [ ! -f  "$FILE" ]; then
    touch "$FILE"
    chown $LAB_USER:$LAB_USER "$FILE"
    echo 'set shiftwidth=2' >> "$FILE"
    echo 'set expandtab' >> "$FILE"
    echo 'set tabstop=4' >> "$FILE"
    echo 'color desert' >> "$FILE"
fi

if ! grep "color" $FILE; then
    echo 'set shiftwidth=2' >> "$FILE"
    echo 'set expandtab' >> "$FILE"
    echo 'set tabstop=4' >> "$FILE"
    echo 'color desert' >> "$FILE"
fi
