# System language
lang en_US
# Language modules to install
langsupport en_US
# System keyboard
keyboard us
# System mouse
mouse
# System timezone
timezone --utc Etc/UTC
# Root password
rootpw --disabled
# Initial user
#Welcome01 is the encrypted password. use encrypt-pw.py to generate a new one
user ansible --fullname "ansible" --iscrypted --password $6$0bRr2ZWuNfglt0CD$1SuEknf5YDdJJypEpQXLDxuPC2OOOHtkAJloRgVx.OSgSvMfqme59Pf94pZQfLyRK2oPAuo2jk/nHSc7KOnBH.
# Reboot after installation
reboot
# Use text mode install
text
# Install OS instead of upgrade
install
# Use CDROM installation media
cdrom
# System bootloader configuration
bootloader --location=mbr 
# Clear the Master Boot Record
zerombr yes
# Partition clearing information
clearpart --all 
# Disk partitioning information
part / --fstype ext4 --size 3700 --grow
part swap --size 200 
# System authorization infomation
auth  --useshadow  --enablemd5 
# Firewall configuration
firewall --enabled --ssh 
# Do not configure the X Window System
skipx
%post --interpreter=/bin/bash
echo ### Redirect output to console
exec < /dev/tty6 > /dev/tty6
chvt 6
echo ### Update all packages
apt-get update
apt-get -y upgrade
# Install packages
apt-get install -y openssh-server vim python
echo ### Enable serial console so virsh can connect to the console
systemctl enable serial-getty@ttyS0.service
systemctl start serial-getty@ttyS0.service
echo ### Add public ssh key for Ansible
mkdir -m0700 -p /home/ansible/.ssh
#use the folowing to generate a new public and private keypair: ssh-keygen -C 'ansible@host' -f id_rsa -N ''
cat <<EOF >/home/ansible/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCsb48BefT3ePWsO3CFHS3AGvBz1ONJDJ0VZ/0OPmiwoiNsf3XS8ugNaN3sXmr/ls3fcVA2nLHf6pQiAqm4ZnNpX4Lc3WGDqjDRK/bs3Xp5RrizYbCXYfzirYYP1qFOlTa3c6lzyFEjLzdk/ZYr31kEeteqaD5lTH9XxXMQ25DtCAIkEtD3h0lbMVQaY4bPKKe/cF0JTQmWvYYQu3n2YuQ+s5rJt2PHvQuLP6F3WGJW2mbLcgNtP0e8TRiYPJWgVnQvaUxQ0RmRjGp75PG6esCdnAdpfEp6FuFBK30jH1FVAuWsTFZ4EkGSt496o96QGO5F01NOD/smXA2Ras/4VZnZQ+jAT9Vt82s53OkircOTRTUKvvx1r3V9CmXk+wvO4Me50PeUAIIe5lAWha2k7xwRgjE5MUqK+/3FKmNFtcicokbcRo/70SrIW3NhKt/vIOWqdQrwQK292ppMhjyPnf4//CWzeOMT4ERfiLqc0Yv6PzjbJseb0dDFmA4M9ThbKTk= ansible@host
EOF
echo ### Set permissions for Ansible directory and key. Since the "Initial user"
echo ### is added *after* %post commands are executed, I use the UID:GID
echo ### as a hack since I know that the first user added will be 1000:1000.
chown -R 1000:1000 /home/ansible
chmod 0600 /home/ansible/.ssh/authorized_keys
# Allow Ansible to sudo w/o a password
echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible
echo ### Change back to terminal 1
chvt 1

