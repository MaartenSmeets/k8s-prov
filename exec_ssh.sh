declare -a IPS=($(for n in $(seq 1 6); do ./get-vm-ip.sh node$n; done))
for i in "${IPS[@]}"
do
	ssh -i id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" ansible@$i "$@"
done

