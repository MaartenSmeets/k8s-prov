#!/bin/bash

#   create-vm - Use .iso and kickstart files to auto-generate a VM.

#   Copyright 2018 Earl C. Ruby III
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

HOSTNAME=

#e.g. for Ubuntu 20.04 'http://archive.ubuntu.com/ubuntu/dists/focal/main/installer-amd64/'
ISO_FQN=
KS_FQN=
RAM=1024
VCPUS=2
STORAGE=20
BRIDGE=virbr0
MAC="RANDOM"
VERBOSE=
DEBUG=
#VM_IMAGE_DIR=/var/lib/libvirt
VM_IMAGE_DIR=/home/maarten/k8s/k8s-prov/machines

usage()
{
cat << EOF
usage: $0 options
This script will take an .iso file created by revisor and generate a VM from it.
OPTIONS:
   -h      Show this message
   -n      Host name (required)
   -i      Full path and name of the .iso file to use (required)
   -k      Full path and name of the Kickstart file to use (required)
   -r      RAM in MB (defaults to ${RAM})
   -c      Number of VCPUs (defaults to ${VCPUS})
   -s      Amount of storage to allocate in GB (defaults to ${STORAGE})
   -b      Bridge interface to use (defaults to ${BRIDGE})
   -m      MAC address to use (default is to use a randomly-generated MAC)
   -v      Verbose
   -d      Debug mode
EOF
}

while getopts "h:n:i:k:r:c:s:b:m:v:d" option; do
    case "${option}"
    in
        h) 
            usage
            exit 0
            ;;
        n) HOSTNAME=${OPTARG};;
        i) ISO_FQN=${OPTARG};;
        k) KS_FQN=${OPTARG};;
        r) RAM=${OPTARG};;
        c) VCPUS=${OPTARG};;
        s) STORAGE=${OPTARG};;
        b) BRIDGE=${OPTARG};;
        m) MAC=${OPTARG};;
        v) VERBOSE=1;;
        d) DEBUG=1;;
    esac
done

if [[ -z $HOSTNAME ]]; then
    echo "ERROR: Host name is required"
    usage
    exit 1
fi

if [[ -z $ISO_FQN ]]; then
    echo "ERROR: ISO file name or http url is required"
    usage
    exit 1
fi

if [[ -z $KS_FQN ]]; then
    echo "ERROR: Kickstart file name or http url is required"
    usage
    exit 1
fi

if ! [[ -f $KS_FQN ]]; then
    echo "ERROR: $KS_FQN file not found"
    usage
    exit 1
fi
KS_FILE=$(basename "$KS_FQN")

if [[ ! -z $VERBOSE ]]; then
    echo "Building ${HOSTNAME} using MAC ${MAC} on ${BRIDGE}"
    echo "======================= $KS_FQN ======================="
    cat "$KS_FQN"
    echo "=============================================="
    set -xv
fi

mkdir -p $VM_IMAGE_DIR/{images,xml}

virt-install \
    --connect=qemu:///system \
    --name="${HOSTNAME}" \
    --bridge="${BRIDGE}" \
    --mac="${MAC}" \
    --disk="${VM_IMAGE_DIR}/images/${HOSTNAME}.img,bus=virtio,size=${STORAGE}" \
    --ram="${RAM}" \
    --vcpus="${VCPUS}" \
    --autostart \
    --hvm \
    --arch x86_64 \
    --accelerate \
    --check-cpu \
    --os-type=linux \
    --os-variant=ubuntu20.04 \
    --force \
    --watchdog=default \
    --extra-args="ks=file:/${KS_FILE} console=tty0 console=ttyS0,115200n8 serial" \
    --initrd-inject="${KS_FQN}" \
    --graphics=none \
    --noautoconsole \
    --debug \
    --location="${ISO_FQN}"

if [[ ! -z $DEBUG ]]; then
    # Connect to the console and watch the install
    virsh console "${HOSTNAME}"
    virsh start "${HOSTNAME}"
fi

# Make a backup of the VM's XML definition file
virsh dumpxml "${HOSTNAME}" > "${VM_IMAGE_DIR}/xml/${HOSTNAME}.xml"

if [ ! -z $VERBOSE ]; then
    set +xv
fi
