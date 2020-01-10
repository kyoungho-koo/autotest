#!/bin/bash

#
#STORAGE='nvme0n1'

#echo 0 > /proc/sys/kernel/randomize_va_space
#cat /proc/sys/kernel/randomize_va_space
ITERATION=1

KERNEL_VERSION="$(uname -r| awk -F '-' '{print $1}')"
KER_EXTRAVER1="$(uname -r| awk -F '-' '{print $2}')"
KER_EXTRAVER2="$(uname -r| awk -F '-' '{print $3}')"

if [[ $KERNEL_VERSION != "5.3.13"* ]]
then
        echo KERNEL VERSION ERROR
	exit 0
fi

echo $KERNEL_VERSION
echo $KERNEL_EXTRAVERSION

BENCHMARK="./autotestlib/db_bench"
VERSION=${KER_EXTRAVER1}_${KER_EXTRAVER2}
if [ "$KER_EXTRAVER2" = "" ];
then
	if [  "$KER_EXTRAVER1" = "" ];
	then
		VERSION="ext4"
	else
		VERSION=${KER_EXTRAVER1}
	fi
fi

OUTDIR="$(pwd)/data/leveldb/${VERSION}"
echo $OUTDIR
mkdir -p -- $OUTDIR


#for STORAGE in nvme0n1 sdd1 sdc1 sdb1
for STORAGE in nvme0n1 sdd1
do
  echo ======== $STORAGE ========
  for i in 1 10 20 30 40 50 60 70
  do
    for  j in `seq 1 ${ITERATION}`
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

	    ## data journaling mode
	    mount /dev/$STORAGE mnt;

	    ## free all data in memory
	    free -h && sync && sh -c 'echo 3 > /proc/sys/vm/drop_caches' && free -h;

            ## Delete Kernel Log
            echo > /dev/null | sudo tee /var/log/kern.log
            sudo sync
	    
            ## Define OUTFILE
	    OUTFILE=${OUTDIR}/${STORAGE}thread$i;

	    ${BENCHMARK} --db=mnt/ --threads=$i >> ${OUTFILE};

            cp /var/log/kern.log ${OUTFILE}.log;
            sudo chown $USER:$USER ${OUTFILE}.log;
            chmod 755 ${OUTFILE}.log;
	done
  done
done

