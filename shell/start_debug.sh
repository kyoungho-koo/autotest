#echo > /var/log/syslog
#echo > /var/log/kern.log
#echo 0 > /sys/module/jbd2/parameters/jbd2_debug
#cat /sys/module/jbd2/parameters/jbd2_debug

#
STORAGE='nvme0n1'

echo 0 > /proc/sys/kernel/randomize_va_space
cat /proc/sys/kernel/randomize_va_space

#for i in 10
# do
#  for j in 1 2 3 4 5
#  do

  i=4
  umount mnt

  echo y | mkfs.ext4 -E lazy_itable_init=0,lazy_journal_init=0 /dev/$STORAGE

  # data journaling mode
  ## mount -o data=journal /dev/nvme0n1p1 /home/dertflag/mnt
  ## mount -o data=journal /dev/sdb1 /home/dertflag/mnt

  mount /dev/$STORAGE mnt
  #mount /dev/sdc1 mnt
  #mount /dev/sdd1 mnt
  #mount /dev/nvme0n1 mnt


  #free all data in memory
  free -h && sync && sh -c 'echo 3 > /proc/sys/vm/drop_caches' && free -h



  filebench -f workload/varmail$i.f >> output/${STORAGE}thread$i.txt 
# done
# echo output/${STORAGE}thread$i.txt 

#done

