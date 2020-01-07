# GNU Plot for varmail test

set terminal qt size 800, 800 font "Helvetica,18"

set grid ytics

set style data histogram
set style histogram cluster gap 1
set style fill solid 0.8
set boxwidth 0.4 absolute

red = "#FF0000"; green = "#00FF00"; blue = "#0000FF";

set key outside

set title "MongoDB TEST ( throughput ) " font ",20"

set xlabel "MongoDB mode" font ",16"
set ylabel "# of ops per second [Ops/s]" font ",16"

plot 'mongodb_throughput.dat' using 2:xtic(1) t "ext4" lc rgb red,\
                           '' using 3:xtic(1) t "xfs" lc rgb blue,\
                           '' using 0:2:(sprintf("%.f\n",$2)) with labels center offset -2.5,0.5 notitle,\
                           '' using 0:3:(sprintf("%.f\n",$3)) with labels center offset 2.5,0.5 notitle

