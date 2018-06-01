#!/usr/bin/env bash

set -e

base_dir=$(readlink -nf $(dirname $0)/../..)
source $base_dir/lib/prelude_apply.bash
source $base_dir/lib/prelude_bosh.bash

# Set up users/groups
vcap_user_groups='admin,adm,audio,cdrom,dialout,floppy,video,bosh_sshers'

if [ "${stemcell_operating_system}" != "centos" ] && [ "${stemcell_operating_system}" != "rhel" ] ; then
  vcap_user_groups="${vcap_user_groups},dip"
fi

if [ -f $chroot/etc/debian_version ] # Ubuntu
then
  vcap_user_groups+=",plugdev"
fi

run_in_chroot $chroot "
groupadd --system -f admin
groupadd -f vcap
groupadd audio
groupadd cdrom
groupadd floppy
groupadd video
useradd -m --comment 'BOSH System User' vcap --uid 1000 -g vcap
chmod 700 ~vcap
echo \"vcap:${bosh_users_password}\" | chpasswd
echo \"root:${bosh_users_password}\" | chpasswd
groupadd bosh_sshers
usermod -G ${vcap_user_groups} vcap
usermod -s /bin/bash vcap
groupadd bosh_sudoers
sed -i 's/:::/:*::/g' /etc/gshadow  # Disable users from acting as any default system group
"

# Setup SUDO
cp $assets_dir/sudoers $chroot/etc/sudoers

# Add $bosh_dir/bin to $PATH
echo "export PATH=$bosh_dir/bin:\$PATH" >> $chroot/root/.bashrc
echo "export PATH=$bosh_dir/bin:\$PATH" >> $chroot/home/vcap/.bashrc

if [ "${stemcell_operating_system}" == "opensuse" ] ; then
  echo "export PATH=\$PATH:/sbin" >> $chroot/home/vcap/.bashrc
fi

if [ "${stemcell_operating_system}" == "centos" ] || [ "${stemcell_operating_system}" == "photonos" ] || [ "${stemcell_operating_system}" == "opensuse" ] ; then
  cat > $chroot/root/.profile <<EOS
if [ "\$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi
EOS
fi

# install custom command prompt
# due to differences in ordering between OSes, explicitly source it last
cp $assets_dir/ps1.sh $chroot/etc/profile.d/00-bosh-ps1
echo "source /etc/profile.d/00-bosh-ps1" >> $chroot/root/.bashrc
echo "source /etc/profile.d/00-bosh-ps1" >> $chroot/home/vcap/.bashrc
echo "source /etc/profile.d/00-bosh-ps1" >> $chroot/etc/skel/.bashrc
