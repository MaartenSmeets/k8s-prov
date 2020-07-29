#!/bin/bash

#   delete-vm - Delete a virtual machine created with create-vm

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

VM=$1
VM_IMAGE_DIR=/home/maarten/k8s/k8s-prov/machines
IMAGE="${VM_IMAGE_DIR}/images/$VM.img"

usage()
{
cat << EOF
usage: $0 vmname
EOF
}

if [[ -z $VM ]]; then
    usage
    exit 1
fi

if [[ -e $IMAGE ]]; then
    # VM exists
    virsh destroy "$VM"
    virsh undefine "$VM"
    rm -fv "$IMAGE"
else
    echo "Cannot find an VM image file named '$IMAGE'. Attempting undefine..."
    virsh undefine "$VM" --remove-all-storage
fi
