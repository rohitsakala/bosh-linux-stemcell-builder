#!/usr/bin/env bash

set -e

base_dir=$(readlink -nf $(dirname $0)/../..)
source $base_dir/lib/prelude_apply.bash

# If xenial, create symlink to gutsy
if [ ${base_debootstrap_suite} == 'xenial' ]; then
  pushd /usr/share/debootstrap/scripts
  sudo ln -sf gutsy xenial
  popd
fi

# Bootstrap the base system
echo "Running debootstrap"
debootstrap --arch=$base_debootstrap_arch $base_debootstrap_suite $chroot ""

# See https://bugs.launchpad.net/ubuntu/+source/update-manager/+bug/24061
rm -f $chroot/var/lib/apt/lists/{archive,security,lock}*

# Copy over some other system assets
# Networking...
cp $assets_dir/etc/hosts $chroot/etc/hosts

# Timezone
cp $assets_dir/etc/timezone $chroot/etc/timezone

run_in_chroot $chroot "dpkg-reconfigure -fnoninteractive -pcritical tzdata"

# Locale
cp $assets_dir/etc/default/locale $chroot/etc/default/locale
run_in_chroot $chroot "locale-gen en_US.UTF-8"
run_in_chroot $chroot "dpkg-reconfigure -fnoninteractive locales"
