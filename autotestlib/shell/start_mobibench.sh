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

BENCHMARK="./autotestlib/mobibench"
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

OUTDIR="$(pwd)/data/mobibench/${VERSION}"
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

for THREAD in 32 24 16 8 4 1
do
for  j_mode in 2 3
do

	pre_bench $1
	delete_dmesg

	for  db_mode in 0 1 2
	do

	
                echo ======== device : $1, CLIENTS : $THREAD j_mode : $j_mode db_mode : $db_mode ========

		#./autotestlib/shell/change_commit_time $2
		#echo ./autotestlib/shell/change_commit_time $2


		## Define OUTFILE
		OUTFILE=${OUTDIR}/$1process${THREAD}dbMode${db_mode}jMode${j_mode};
		# optane 1000000 sdd1 50000
		${BENCHMARK} -p mnt -t $THREAD -d $db_mode -n 1000000 -s 2 -j ${j_mode} -q  >> ${OUTFILE}.txt;

		cp /var/log/kern.log ${OUTFILE}.log;
		sudo chown $USER:$USER ${OUTFILE}.log;
		chmod 755 ${OUTFILE}.log;
		delete_dmesg
	done
done
done

}

# Disable Hyper Threading
echo d | ./autotestlib/shell/toggle_ht.sh

#for STORAGE in nvme0n1 sdd1 sdc1 sdb1
for STORAGE in nvme0n1
do
  run_bench $STORAGE
done
delete_dmesg
