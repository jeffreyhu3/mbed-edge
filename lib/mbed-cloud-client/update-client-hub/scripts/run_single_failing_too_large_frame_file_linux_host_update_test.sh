#!/bin/bash
set +x
set -e

if [[ $# -eq 0 ]] ; then
    echo 'Please give device id as parametter'
    exit 0
fi

case "$1" in
    1) echo 'Running update tests to Device ID $1' ;;
    *) echo 'Wrong number of parametters only needs device ID' ;;
esac

DEVICE_ID=$1

touch deltaU.bs
DELTAFILE="$(readlink -f deltaU.bs)"

NEWFILE="mbed-cloud-client/update-client-hub/delta-tool-internal/bsdiff/test_data/driver_add_new.bin"
OLDFILE="mbed-cloud-client/update-client-hub/delta-tool-internal/bsdiff/test_data/driver_add_old.bin"

#compile bs diff
pushd .
cd mbed-cloud-client/update-client-hub/delta-tool-internal/bsdiff
make bsdiff
popd

#lets now make delta content with too large framesize, with default build this should fail to out of memory
./mbed-cloud-client/update-client-hub/delta-tool-internal/bsdiff/bsdiff $OLDFILE $NEWFILE $DELTAFILE 2048

python3 mbed-cloud-client/update-client-hub/delta-tool-internal/tools/delta-tool.py $OLDFILE $NEWFILE -d $DELTAFILE -f -i .manifest_tool.json -o delta-tool-generated-manifest.json

manifest-tool update device -D $DEVICE_ID -i delta-tool-generated-manifest.json --no-cleanup
