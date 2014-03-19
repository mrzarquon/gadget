#!/bin/bash

PE_BUILD="3.2.0"
ER_BUILD="0.2.3"

mkdir -p /opt/pe_kickstart
curl -o /opt/pe_kickstart/puppet-enterprise-${PE_BUILD}-el-6-x86_64.tar.gz https://s3.amazonaws.com/pe-builds/released/${PE_BUILD}/puppet-enterprise-${PE_BUILD}-el-6-x86_64.tar.gz

tar xzvf /opt/pe_kickstart/puppet-enterprise-${PE_BUILD}-el-6-x86_64.tar.gz -C /opt/pe_kickstart/

mkdir -p /opt/puppet/packages/public/${PE_BUILD}

mv /opt/pe_kickstart/puppet-enterprise-${PE_BUILD}-el-6-x86_64/gpg/GPG-KEY-puppetlabs /opt/puppet/packages/public/GPG-KEY-puppetlabs
mv /opt/pe_kickstart/puppet-enterprise-${PE_BUILD}-el-6-x86_64/packages/el-6-x86_64 /opt/puppet/packages/public/${PE_BUILD}/puppet-enterprise-installer

curl -o /opt/pe_kickstart/prosvcs-er-${RE_BUILD}.tar.gz https://s3-us-west-2.amazonaws.com/prosvcs/prosvcs-er/prosvcs-er-${RE_BUILD}.tar.gz

tar xzvf /opt/pe_kickstart/prosvcs-er-${RE_BUILD}.tar.gz -C /opt/pe_kickstart/

mkdir -p /etc/yum.repos.d

cat > /etc/yum.repos.d/puppet-enterprise-installer.repo << PE_REPO
[puppet-enterprise-installer]
name=Puppet Enterprise Installer
baseurl=file:/opt/puppet/packages/public/${PE_BUILD}/puppet-enterprise-installer
gpgcheck=1
gpgkey=file:/opt/puppet/packages/public/GPG-KEY-puppetlabs
PE_REPO

yum install -y pe-agent
/opt/puppet/bin/puppet resource service pe-puppet ensure=stopped enable=false
/opt/puppet/bin/puppet resource service pe-mcollective ensure=stopped enable=false

mv /opt/pe_kickstart/prosvcs-er-${ER_BUILD}/modules/* /opt/puppet/share/puppet/modules/

rm -rf /opt/pe_kickstart
