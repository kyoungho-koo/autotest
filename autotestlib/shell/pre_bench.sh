#!/bin/bash
echo 0 > /proc/sys/kernel/randomize_va_space
cat /proc/sys/kernel/randomize_va_space

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


TIME=60
BENCHMARK="$1"
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

OUTDIR="$(pwd)/data/$1/${VERSION}"
echo $OUTDIR
mkdir -p -- $OUTDIR



delete_dmesg()
{
    # Delete Kernel Log
    echo > /dev/null | sudo tee /var/log/kern.log
    echo > /dev/null | sudo tee /var/log/syslog
    sudo sync
	
}

pre_bench()
{
	CHECK=$(umount /dev/$1 2>&1 | grep busy);
	umount mnt;
	echo $CHECK
	if [ "$CHECK" = "" ]; then 
		echo -- UMOUNT COMPLETE 
	else
		echo !!!!UMOUNT FAIL!!!!
		fuser -ck mnt
		CHECK1=$(umount -l /dev/$1 2>&1 | grep busy);
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

	delete_dmesg
}

ht_off()
{
    echo d | sudo ./autotestlib/shell/toggle_ht.sh 
}
select_workload()
{ 
    BENCHMARK="$1"
	WORKLOAD_DIR="../workload/$1"
    case $BENCHMARK in 
	 "filebench")
	  filebench -f $WORKLOAD_DIR/varmail$2.f
	  ;;
	 "sysbench")
	  sysbench --file-total-size=128G --file-test-mode=rndwr --file-fsync-all=on \
	           --threads=$2 --time=${TIME} --max-requests=0 fileio run
	  ;;
	 "dbench")
	  dbench -c $WORKLOAD_DIR/client.txt -D . -t ${TIME}  -F  --clients-per-process=1 $2
      ;;
	 "leveldb")
	  ../autotestlib/db_bench --threads=$2 --db=. --benchmarks=fillsync 

	  ;;
	 "mobibench")
	  ;;
	 esac

}

run_bench()
{

for PROCESS in 1 2 4 8 12 16 24 32 40 48 64
do
    pre_bench $2
	delete_dmesg

	cd mnt;

	## prepare sysbench 
	if [ "$1" = "sysbench" ]; 
	then
        $1 --test=fileio --file-total-size=128G prepare
	else
	    echo $1
    fi

	## Delete Kernel Log
	sudo sync
	echo > /dev/null | sudo tee /var/log/kern.log

	OUTFILE=${OUTDIR}/$2thread${PROCESS};

	select_workload $1 ${PROCESS} > ${OUTFILE}.txt


	cd ..; 


	cp /var/log/kern.log ${OUTFILE}.log;
	chown $USER:$USER ${OUTFILE}.log;
	chmod 755 ${OUTFILE}.log;
done

}



ht_off

for STORAGE in nvme0n1 nvme1n1
do
 echo ======== $STORAGE ========
 run_bench $BENCHMARK $STORAGE 
done

delete_dmesg
