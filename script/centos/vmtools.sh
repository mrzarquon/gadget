#!/bin/bash -eux

if [ $PACKER_BUILDER_TYPE == 'vmware-iso' ]; then
    if grep -q -i "release 6" /etc/redhat-release ; then
        # Uninstall fuse to fake out the vmware install so it won't try to
        # enable the VMware blocking filesystem
        yum erase -y fuse
    fi
    # Assume that we've installed all the prerequisites:
    # kernel-headers-$(uname -r) kernel-devel-$(uname -r) gcc make perl
    # from the install media via ks.cfg

    # On RHEL 5, add /sbin to PATH because vagrant does a probe for
    # vmhgfs with lsmod sans PATH
    if grep -q -i "release 5" /etc/redhat-release ; then
        echo "export PATH=$PATH:/usr/sbin:/sbin" >> /home/vagrant/.bashrc
    fi

    cd /tmp
    mkdir -p /mnt/cdrom
    mount -o loop /home/gadget/linux.iso /mnt/cdrom
    tar zxf /mnt/cdrom/VMwareTools-*.tar.gz -C /tmp/
    /tmp/vmware-tools-distrib/vmware-install.pl --default
    rm /home/gadget/linux.iso
    umount /mnt/cdrom
    rmdir /mnt/cdrom
elif [ $PACKER_BUILDER_TYPE == 'virtualbox-iso' ]; then
    echo "Installing VirtualBox guest additions"

    # Assume that we've installed all the prerequisites:
    # kernel-headers-$(uname -r) kernel-devel-$(uname -r) gcc make perl
    # from the install media via ks.cfg

    VBOX_VERSION=$(cat /home/gadget/.vbox_version)
    mount -o loop /home/gadget/VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
    sh /mnt/VBoxLinuxAdditions.run --nox11
    umount /mnt
    rm -rf /home/gadget/VBoxGuestAdditions_$VBOX_VERSION.iso
fi
