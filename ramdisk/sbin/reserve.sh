#!/system/bin/sh
chown root:root /data/reserve/reserve.img
chmod 600 /data/reserve/reserve.img
restorecon /data/reserve/reserve.img
exit 0
