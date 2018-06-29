#!/usr/bin/env bash

set -eux

GOPATH=/home/opensuse/go
GO_ARCHIVE_URL=https://storage.googleapis.com/golang/go1.10.linux-s390x.tar.gz
GO_ARCHIVE_SHA256=34385f64651f82fbc11dc43bdc410c2abda237bdef87f3a430d35a508ec3ce0d
GO_ARCHIVE=/tmp/$(basename $GO_ARCHIVE_URL)

echo "Downloading go..."
mkdir -p $(dirname $GOROOT)
wget -q $GO_ARCHIVE_URL -O $GO_ARCHIVE
echo "${GO_ARCHIVE_SHA256} ${GO_ARCHIVE}" | sha256sum -c -
tar xf $GO_ARCHIVE -C $(dirname $GOROOT)

rm -f $GO_ARCHIVE
