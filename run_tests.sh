for instance in {1..10}; do
	echo "[+] Running instance_$instance"
	ruby ../../tsp_new_new.rb "instance_$instance.txt"
done