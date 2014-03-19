text
install
reboot
lang en_US.UTF-8
keyboard us
skipx
network --device eth0 --bootproto dhcp --hostname=puppetlabs
rootpw puppetlabs

firewall --disabled
selinux --disabled
authconfig --enableshadow --enablemd5
timezone America/Los_Angeles
bootloader --location=mbr
zerombr
clearpart --all --initlabel
part /boot --fstype ext3 --size=250
part pv.2 --size=2048 --grow
volgroup VolGroup00 --pesize=32768 pv.2
logvol swap --fstype swap --name=SwapVol --vgname=VolGroup00 --size=2048 --grow --maxsize=2048
logvol / --fstype ext3 --name=RootVol --vgname=VolGroup00 --size=10240 --grow

repo --name=updates --baseurl=http://mirrors.cat.pdx.edu/centos/6.5/os/x86_64/

%packages --nobase
-atk
-system-config-securitylevel-tui-1.6.29.1-5.el5.i386
-checkpolicy
-hicolor-icon-theme
-cups
-cups-libs
-cronie
-cronie-ancron
-crontabs
-ecryptfs-utils
-trousers
-fontconfig
-freetype
-libXft
-kudzu
-postfix
-sendmail
autofs
bind-utils
curl
man
mlocate
ntp
ntpdate
nfs-utils
openssh
openssh-clients
rsync
screen
selinux-policy
selinux-policy-targeted
setools
strace
tcpdump
telnet
vconfig
vim-enhanced
yum
git-all
kernel-headers
kernel-devel
gcc
make
perl

%post
exec < /dev/tty6 > /dev/tty6
chvt 6

PE_BUILD="3.2.0"

mkdir -p /opt/pe_kickstart
curl -o /opt/pe_kickstart/puppet-enterprise-${PE_BUILD}-el-6-x86_64.tar.gz https://s3.amazonaws.com/pe-builds/released/${PE_BUILD}/puppet-enterprise-${PE_BUILD}-el-6-x86_64.tar.gz

tar xzvf /opt/pe_kickstart/puppet-enterprise-${PE_BUILD}-el-6-x86_64.tar.gz -C /opt/pe_kickstart/

mkdir -p /opt/puppet/packages/public/${PE_BUILD}

mv /opt/pe_kickstart/puppet-enterprise-${PE_BUILD}-el-6-x86_64/gpg/GPG-KEY-puppetlabs /opt/puppet/packages/public/GPG-KEY-puppetlabs
mv /opt/pe_kickstart/puppet-enterprise-${PE_BUILD}-el-6-x86_64/packages/el-6-x86_64 /opt/puppet/packages/public/${PE_BUILD}/puppet-enterprise-installer

rm -rf /opt/pe_kickstart

mkdir -p /etc/yum.repos.d

echo > /etc/yum.repos.d/puppet-enterprise-installer.repo << PE_REPO
[puppet-enterprise-installer]
name=Puppet Enterprise Installer
baseurl=file:/opt/puppet/packages/public/${PE_BUILD}/puppet-enterprise-installer
gpgcheck=1
gpgkey=file:/opt/puppet/packages/public/GPG-KEY-puppetlabs
PE_REPO

yum install -y pe-agent
/opt/puppet/bin/puppet resource service pe-puppet ensure=stopped enable=false
/opt/puppet/bin/puppet resource service pe-puppet ensure=stopped enable=false
