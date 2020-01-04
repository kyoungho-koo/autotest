set term pdfcairo size 10in, 5in font "Helvetica,30"

in1 = "output/fop_exp48.csv"
out1 = "figure1.eps"

set xrange [0:]
set yrange [0:]

set xlabel "Normalized Commit Time" font "Helvetica, 30"
set ylabel "% of File Oper." font "Helvetica, 30"
set xtics nomirror
set ytics nomirror


set grid ytics
set border 3 back 
#set key horiz
#set key at 2,35
set key right top font "Helvetica,30"
#set key outside

set output out1
plot	in1 using 1:2 t "840pro" with lp ps 1.5 lw 5 pt 1 lc 1, \
		in1 using 1:3 t "850pro" with lp ps 1.5 lw 5 pt 2 lc 2, \
		in1 using 1:4 t "optane" with lp ps 1.5 lw 5 pt 3 lc 3 
