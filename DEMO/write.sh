pid_write=$$
#machine=$1
#utilisateur=$2

while [[ 1 ]]; do
	cat ~/proprescripts/rvsh/write | grep "$2@$1 "| sed -e 's/^'"$2@$1"' /Vous avez une message : /g' 
	sed -i -e '/^'"$2@$1"' /d' ~/proprescripts/rvsh/write
	sleep 1
done
