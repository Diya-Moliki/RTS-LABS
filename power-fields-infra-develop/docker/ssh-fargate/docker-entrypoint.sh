#!/bin/bash

# download Add user script
# IMPORTANT: the sync_users_with_rcsv.sh will add a cron job. We are intentionally doing this after bastion_bootstrap.sh which overwrites crontba
#run file from rts script store
cd /var/run
function run_rts {
	local filename=`mktemp`
	curl -s -f -o "$filename" -u "rtslabs:rtslabs" "https://keys.rtsdev.co/devopscripts/scripts/$1"
	chmod +x $filename
	shift
	$filename "$@"
	rm -f $filename
}

# install user access
cat << 'EOFU' > /var/run/sync_users.conf
rts-labs dev-ops sudo
rts-labs powerfields-developer sudo
EOFU

echo "adding users"
run_rts "utilities/sync_users_with_rcsv.sh" -i --rcomment="PowerFields Bastion" --file=/var/run/sync_users.conf

echo "starting SSH daemon"
/usr/sbin/sshd -D

