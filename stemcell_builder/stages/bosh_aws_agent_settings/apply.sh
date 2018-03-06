#!/usr/bin/env bash

base_dir=$(readlink -nf $(dirname $0)/../..)
source $base_dir/lib/prelude_apply.bash
source $base_dir/lib/prelude_agent.bash

if [ "$(get_os_type)" == "opensuse" -o "$(get_os_type)" == "sles" ]; then
  partitioner_type="\"PartitionerType\": \"parted\","
fi

cat > $chroot/var/vcap/bosh/agent.json <<JSON
{
  "Platform": {
    "Linux": {
      $(get_partitioner_type_mapping)
      "DevicePathResolutionType": "virtio"
    }
  },
  "Infrastructure": {
    "Settings": {
      "Sources": [
        {
          "Type": "HTTP",
          "URI": "http://169.254.169.254",
          "UserDataPath": "/latest/user-data",
          "InstanceIDPath": "/latest/meta-data/instance-id",
          "SSHKeysPath": "/latest/meta-data/public-keys/0/openssh-key"
        }
      ],
      "UseRegistry": true
    }
  }
}
JSON
