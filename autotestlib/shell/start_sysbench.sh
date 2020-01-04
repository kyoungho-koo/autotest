

#
#STORAGE='nvme0n1'

#echo 0 > /proc/sys/kernel/randomize_va_space
#cat /proc/sys/kernel/randomize_va_space

OUTDIR="$(pwd)/output/sysbench"

for STORAGE in nvme0n1 sdd1 sdc1 sdb1
do
  echo ======== $STORAGE ========
  for i in 1 10 20 30 40 50
  do
    for iter in 1 2 3
	  do
	    CHECK=$(umount mnt 2>&1 | grep busy);
	    echo $CHECK
	    if [ "$CHECK" = "" ]; then 
	      echo -- UMOUNT COMPLETE 
	    else
	      echo !!!!UMOUNT FAIL!!!!
	      fuser -ck mnt
	      CHECK1=$(umount -l mnt 2>&1 | grep busy);
	      if [ "$CHECK1" = "" ]; then 
		echo -- UMOUNT COMPLETE 
	      else
		echo !!!!UMOUNT FAIL!!!!
		exit 0
	      fi
	    fi
	    echo y | mkfs.ext4 -E lazy_itable_init=0,lazy_journal_init=0 /dev/$STORAGE;

	  # data journaling mode
	  ## mount -o data=journal /dev/nvme0n1p1 /home/dertflag/mnt

	    mount /dev/$STORAGE mnt;
	    cd mnt;

	  #free all data in memory
	    free -h && sync && sh -c 'echo 3 > /proc/sys/vm/drop_caches' && free -h;

	    sysbench --test=fileio --file-total-size=150G prepare
	    sysbench --test=fileio --file-total-size=150G --file-test-mode=rndrw --file-fsync-all=on --num-threads=$i --max-time=60 --max-requests=0 run >> ${OUTDIR}/${STORAGE}thread$i;
	   # sysbench --test=fileio --file-total-size=20G cleanup

	    cd ..;
	#filebench -f workload/varmail$i.f >> output/${STORAGE}thread$i.txt 
	# done
	# echo output/${STORAGE}thread$i.txt 

	done
  done
done

