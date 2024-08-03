
#####  START OF SCRIPT ######


#KERNEL
magiskpolicy --live 'allow kernel oem_device blk_file {read write open}'
magiskpolicy --live 'allow kernel kernel capability {kill}'

#SHELL
magiskpolicy --live 'allow shell rootfs file {getattr}'

#SYSTEM
magiskpolicy --live 'allow system_app system_data_file dir {read write create setattr}'
magiskpolicy --live 'allow system_app system_data_file file {create}'

#MAGISK
magiskpolicy --live 'allow magisk_client vendor_file dir {read}'
magiskpolicy --live 'allow magisk vendor_file dir {read}'

#HAL
magiskpolicy --live 'allow hal_memtrack_default sysfs_kgsl dir {search}'
#magiskpolicy --live 'allow hal_perf_default system_server dir {search}'
#magiskpolicy --live 'allow hal_perf_default system_server file {read open getattr}'
#magiskpolicy --live 'allow hal_sensors_default proc file {getattr}'
#magiskpolicy --live 'allow hal_sensors_default sensors_dbg_prop file {read open getattr map}'
sepolicy-inject -s shell -t rootfs -c file -p read -P /sys/fs/selinux/policy  'allow shell rootfs:file { read }' 2>/dev/null


sepolicy-inject allow adbd vendor_framework_file : file { ioctl read getattr lock map open watch watch_reads } ;
sepolicy-inject -s shell -t rootfs -c file -p read -P /sys/fs/selinux/policy  'allow shell rootfs:file { read }'
echo "selinux ok" > /data/adb/post-fs-data.d/status_selinux.log

####
cp /sys/fs/selinux/policy policy
sepolicy-inject -s shell -t rootfs -c file -p read -P policy  'allow shell rootfs:file { read }'\
cp policy /sys/fs/selinux/policy
/system/bin/load_policy policy
cp /sys/fs/selinux/policy policy
sepolicy-inject -s shell -t rootfs -c file -p read,open -P policy "allow shell rootfs:file { read open }"
cp policy /sys/fs/selinux/policy
/system/bin/load_policy policy

#####  END OF SCRIPT ######