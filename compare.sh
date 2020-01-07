for i in 1 10 20 30 40 50
do
        echo =============================================================
	grep -E "fsyncs" data/sysbench/*/rndwr/150G/nvme0n1thread$i
done

