# GNU Plot for varmail test

set terminal qt size 600, 300 font "Helvetica,11"

set grid ytics

set style data histogram
set style histogram cluster gap 1
set style fill solid 0.8
set boxwidth 1 absolute
set yrange [0:]
set ytics 500

red = "#FF0000"; green = "#00FF00"; blue = "#0000FF";
wight = "#666666";gray = "#aaaaaa"; black = "#000000";

set key outside

#set title " ( throughput ) " font ",20"

set xlabel "The number of threads" font ",14"
set ylabel "Bandwidth [MiB/s]" font ",14"

set multiplot

plot 'varmail_thro.dat' using 2:xtic(1) t "ext4" lc rgb wight,\
                           '' using 3:xtic(1) t "ext4-RTC" lc rgb gray,\
                           '' using 4:xtic(1) t "ext-comp&RTC" lc rgb black


