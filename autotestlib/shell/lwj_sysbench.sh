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

BENCHMARK="sysbench"
OPERATION="rndwr"
FILESIZE="16G"
TIME="60"
#FILENUM="64"
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

OUTDIR="$(pwd)/data/${BENCHMARK}/${VERSION}/lwj_test"
echo $OUTDIR
mkdir -p -- $OUTDIR
mkdir -p -- $OUTDIR/result
mkdir -p -- $OUTDIR/log



#for STORAGE in nvme0n1 sdd1 sdc1 sdb1
for STORAGE in nvme0n1 
do
  echo ======== $STORAGE ========
  for filenum in 8 16 32 64 128
  do
  for i in 48 16
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
	    #mount -o data=journal /dev/nvme0n1p1 /home/dertflag/mnt

	    mount /dev/$STORAGE mnt;
	    cd mnt;

	    ## free all data in memory
	    free -h && sync && sh -c 'echo 3 > /proc/sys/vm/drop_caches' && free -h;

	    ## prepare benchmark 
	    ${BENCHMARK} --file-num=${filenum} --file-total-size=${FILESIZE} fileio prepare

            ## Delete Kernel Log
            echo > /dev/null | sudo tee /var/log/kern.log
            sudo sync
	    
            ## Define OUTFILE
	    OUTFILE1=${OUTDIR}/result/${STORAGE}thread$i;
	    OUTFILE2=${OUTDIR}/log/${STORAGE}size${FILESIZE}thread$i;

	    ${BENCHMARK} --file-total-size=${FILESIZE} \
			 --file-num=${filenum} \
			 --file-test-mode=$OPERATION --file-fsync-all=on \
			 --threads=$i --time=${TIME} \
			 --max-requests=0 fileio run >> ${OUTFILE1};
	    cd ..;

	    # sysbench --test=fileio --file-total-size=20G cleanup

            cp /var/log/kern.log ${OUTFILE2}.log;
            sudo chown $USER:$USER ${OUTFILE2}.log;
            chmod 755 ${OUTFILE2}.log;
            
	    echo > /dev/null | sudo tee /var/log/syslog

	done
  done
  done
done

