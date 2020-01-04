set term pdfcairo size 10in, 5in font "Helvetica,25"

in1 = "output/fop_exp16.csv"
out1 = "figure1.eps"

set xrange [0:]
set yrange [0:]

set xlabel "" font "Helvetica, 20"
set ylabel "" font "Helvetica, 20"
set xtics nomirror
set ytics nomirror


set grid ytics
set border 3 back 
set key horiz
set key at 2,35
set key left top font "Helvetica,10"
set key outside

set output out1
plot	in1 using 1:2 t "HDD" with lp ps 2 lw 5 pt 1 lc 1, \
		in1 using 1:3 t "SSD A" with lp ps 2 lw 5 pt 2 lc 2, \
		in1 using 1:4 t "SSD B" with lp ps 2 lw 5 pt 3 lc 3, \
		in1 using 1:5 t "SSD C" with lp ps 2 lw 5 pt 4 lc 4
