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

BENCHMARK="dbench"
TIME=60
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

OUTDIR="$(pwd)/data/${BENCHMARK}/${VERSION}/threadtest"
echo $OUTDIR
mkdir -p -- $OUTDIR


pre_bench()
{
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
	echo y | mkfs.ext4 -E lazy_itable_init=0,lazy_journal_init=0 /dev/$1;

    	## metadata journaling mode
        mount /dev/$1 mnt;
        echo mount /dev/$1 mnt;

	## free all data in memory
	free -h && sync && sh -c 'echo 3 > /proc/sys/vm/drop_caches' && free -h;


}

delete_dmesg()
{
	## Delete Kernel Log
        echo > /dev/null | sudo tee /var/log/kern.log
        echo > /dev/null | sudo tee /var/log/syslog
        sudo sync
	
}

run_bench()
{

for CLIENTS in 1 10 20 30 40
do
for PROCESS in 2 4 8
do
	
	for  j in `seq 1 ${ITERATION}`
	do
		pre_bench $1
		delete_dmesg

		./autotestlib/shell/change_commit_time $2
		echo ./autotestlib/shell/change_commit_time $2


		## Define OUTFILE
		OUTFILE=${OUTDIR}/$1clients${CLIENTS}process${PROCESS}delay$2;
		${BENCHMARK} -c workload/${BENCHMARK}/client.txt -D $(pwd)/mnt -t ${TIME}  -F --clients-per-process=${PROCESS} ${CLIENTS} >> ${OUTFILE};

		cp /var/log/kern.log ${OUTFILE}.log;
		sudo chown $USER:$USER ${OUTFILE}.log;
		chmod 755 ${OUTFILE}.log;
	done
done
done



}

#for STORAGE in nvme0n1 sdd1 sdc1 sdb1
for STORAGE in nvme0n1
do
  echo ======== $STORAGE ========
  if [ "$STORAGE" = "nvme0n1" ]; then 
    for delay in 0 50 100 200 400
    do
     echo !! delay $delay !!
     run_bench $STORAGE $delay
    done 
  else
    for delay in 0 500 1000 2000 4000
    do
     echo !! delay $delay !!
     run_bench $STORAGE $delay
    done 
  fi
done

delete_dmesg
