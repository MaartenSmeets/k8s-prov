export LIBVIRT_DEFAULT_URI="qemu:///system"
for n in $(seq 1 4); do
    ./delete-vm.sh node$n
done
