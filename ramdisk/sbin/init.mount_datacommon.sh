#!/system/bin/sh
mount_dir(){
  case "$1" in
    "Android"|"lost+found") continue;;
  esac
  dest="/mnt/runtime/default/emulated/0/$1"
  [ -d "$dest" ] || mkdir -p "$dest" 2>/dev/null
  mount -t sdcardfs -o rw,nosuid,nodev,noexec,noatime,fsuid=1023,fsgid=1023,gid=9997,mask=7,derive_gid,default_normal "/datacommon/$1" "$dest"
}
mount -t auto -o rw,noatime,nosuid,nodev,discard,fsync_mode=nobarrier /dev/block/by-name/userdata2 /datacommon
touch /datacommon/.nomedia
chown -R 1023:1023 /datacommon
##SHARED DATA PATCH
path_list=$(find /datacommon -maxdepth 1)
for path in $path_list
do
  [ $path == "/datacommon" ] && chcon u:object_r:media_rw_data_file:s0 $path || (
    [ $path != "/datacommon/SharedData" ] && chcon -R u:object_r:media_rw_data_file:s0 $path)
done
##SHARED DATA PATCH END
until [ -d /storage/emulated/0/Android ]; do
  sleep 1
done
# Make one folder that has everything in it - for files not in a folder
mkdir /storage/emulated/0/CommonData 2>/dev/null
if [ -f "/system/etc/init/hw/init.rc" ]; then
  mount -t sdcardfs -o rw,nosuid,nodev,noexec,noatime,fsuid=1023,fsgid=1023,gid=9997,mask=7,derive_gid,default_normal /datacommon /mnt/pass_through/0/emulated/0/CommonData
else
  mount -t sdcardfs -o rw,nosuid,nodev,noexec,noatime,fsuid=1023,fsgid=1023,gid=9997,mask=7,derive_gid,default_normal /datacommon /storage/emulated/0/CommonData
fi
# Mount folders over top - sdcardfs only supports directory mounting
[ -f /datacommon/mounts.txt ] || exit 0
if [ "$(head -n1 /datacommon/mounts.txt | tr '[:upper:]' '[:lower:]')" == "all" ]; then
  for i in $(find /datacommon -mindepth 1 -maxdepth 1 -type d); do
    mount_dir "$(basename "$i")"
  done
else
  while IFS="" read -r i || [ -n "$i" ]; do
    mount_dir "$i"
  done < /datacommon/mounts.txt
fi
#SAHREDAPP SECTION
if [ -d /datacommon/SharedData ]; then
  if [ -f /datacommon/SharedData/datamount.conf ]; then
    setenforce 0
    while IFS="" read -r i || [ -n "$i" ]; do
      mount -o bind $i
      stringarray=($i)
      restorecon -R ${stringarray[1]}
      done < /datacommon/SharedData/datamount.conf
    chmod -R 777 /datacommon/SharedData/*
  fi  
fi
#END SHAREDAPP
exit 0
