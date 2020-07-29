export LIBVIRT_DEFAULT_URI="qemu:///system"
for n in $(seq 1 4); do
    ./create-vm.sh -n node$n \
      -i 'http://archive.ubuntu.com/ubuntu/dists/focal/main/installer-amd64/' \
      -k ./ubuntu.ks \
      -r 4096 \
      -c 2 \
      -s 40
done
