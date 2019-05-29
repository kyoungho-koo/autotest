ps -elf | grep filebench | awk '{print  $4}' | while read line; do kill $line; done

