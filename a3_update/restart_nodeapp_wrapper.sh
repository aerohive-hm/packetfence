#!/usr/bin/sh
update_log_file=/usr/local/pf/logs/a3_cluster_update.log
sleep 1
systemctl restart a3-nodeapp
echo "restart a3 nodeapp done" >> $update_log_file
