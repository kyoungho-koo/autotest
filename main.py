import re
import subprocess
import sys
import argparse
from ast import literal_eval
import statistics
import PyGnuplot as pg
import numpy as np
from operator import itemgetter

def run_benchmark(type):
    subprocess.run(["sudo","sh","shell/init_filebench_test.sh"])
    subprocess.run(["sudo","filebench","-f","workload/varmail.f"])
    

def parse_dmesg(type):
    p1 = subprocess.Popen(["cat","log/jbd2_journal_commit_transaction/004.txt"], stdout=subprocess.PIPE)
    p2 = subprocess.Popen(["grep", "t_updates"], stdin=p1.stdout, stdout=subprocess.PIPE)
    p1.stdout.close()  # Allow p1 to receive a SIGPIPE if p2 exits.
    output = filter(None,p2.communicate()[0].decode('utf8').split('\n'))

    list = []
    x = []
    y = []
    z = []
    count = 0
    for data in output:
        tmp = literal_eval(data[49:-1])
        if tmp['critical_time'] >30000000: 
            count += 1
        list.append(tmp)
        y.append(tmp['critical_time']/1000000)
        x.append(tmp['t_updates'])

    if type == 1:
        newlist = sorted(list, key=itemgetter('t_updates'))
        max_t_updates = newlist[-1]['t_updates']
        z = [0] * max_t_updates
        ratio = [0] * max_t_updates

        for i in range(newlist[-1]['t_updates']):
            filter_list = filter(lambda k :k['t_updates'] == i, newlist)
            critical_time_list = []
            for filtered_data in filter_list:
                ratio[i] += 1
                critical_time_list.append(filtered_data['critical_time'])
            ratio[i] = ratio[i] / len(newlist) *100;

            if critical_time_list:
                z[i] = statistics.median(critical_time_list)/1000000 

        print ("miss rate : %lf" % ((count/len(list)  * 100)))
        #print ( ratio[33])

        average = statistics.median(y)

        return y,z,average,max_t_updates 
    else:
        return x,y
        

if __name__ == '__main__':
    parser = argparse.ArgumentParser(prog='main.py', formatter_class=argparse.RawTextHelpFormatter,
            description="""analysis : test""")
    parser.add_argument('--plot-type',default='dot',type=str ,help = '''  median
      dot''')
    parser.add_argument('--y-range',default='',type=str )
    parser.add_argument('--x-range',default='',type=str )


    gArg = parser.parse_args()

    plot_str = "plot"
    plot_str += " [:"+gArg.x_range + "]"
    plot_str += " [:"+gArg.y_range + "]"
    plot_str += " 'tmp.out' u 1:2"
    plot_value = " lc rgb \#000 t"


    if gArg.plot_type == 'dot':  
        x,y = parse_dmesg(0)
        pg.s([x,y], filename='tmp.out')
        pg.c('set title "Execution time for the number of access threads"; set xlabel "Access Thread Number"; set ylabel "Millisecond"')
        pg.c('set grid')
        plot_str += plot_value+" '"+gArg.plot_type+"'"
        #pg.c(plot_str)
        pg.c("plot [:33] [:] 'tmp.out' u 1:2 lc rgb 'black' t 'dot'")

    elif gArg.plot_type == 'median':
        run_benchmark(1);
        y,z,average,max_t_updates = parse_dmesg(1)
        print ( 'average' , average )
        x = np.arange(max_t_updates)
        pg.s([x,z], filename='tmp.out')
        pg.c('set title "Execution time for the number of access threads"; set xlabel "Access Thread Number"; set ylabel "Millisecond"')
        pg.c('set grid')
        plot_str += " w l"+plot_value+" '"+gArg.plot_type+"'"
        #pg.c(plot_str)
        pg.c("plot [:] [:] 'tmp.out' u 1:2 w l lc rgb 'black' t 'median'")

    else:
        print ("Invalid plot type" + gArg.plot_type)

    
    #print(y)
 #   with open(,'r') as fin:
 #       for line in fin:


'''
x = np.arange(1000)/20.0
y1 = x-25
y2 = y1*np.sin(x-25)

pg.s([x, y1, y2], filename='example.out')  # save data into a file t.out
pg.c('set title "example.pdf"; set xlabel "x-axis"; set ylabel "y-axis"')
pg.c('set yrange [-25:25]; set key center top')
pg.c("plot 'example.out' u 1:2 w l t 'y=x-25")  # plot fist part
pg.c("replot 'example.out' u 1:3 w l t 'y=(x-25)*sin(x-25)'")
pg.c("replot 'example.out' u 1:(-$2) w l t 'y=25-x'")
pg.pdf('example.pdf')  # export figure into a pdf file
'''
