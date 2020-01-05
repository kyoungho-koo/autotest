import re
import subprocess
import sys
import argparse
from ast import literal_eval
import statistics
import PyGnuplot as pg
import numpy as np
from operator import itemgetter
import time
import os
import errno

#
# run filebench varmail workload and store log in log directory
#
def run_benchmark(workload, numOfTry, thread):
    currentTimestr = time.strftime("log/%Y%m%d%H%M/")

    if not os.path.exists(currentTimestr):
        try:
            os.makedirs(currentTimestr)
        except OSError as exc:
            if exc.errno != errno.EEXIST:
                raise


def run_benchmark(bench):
    subprocess.run(["sudo","sh","autotestlib/shell/start_"+bench+".sh"])
    
#    kernlog_file = open(currentTimestr+"kern.log","w+")
#    benchRet_file = open(currentTimestr+"varmail.log","w+")


#    subprocess.run(["sudo","sh","shell/init_filebench_test.sh"])
#    subprocess.run(["sudo","filebench","-f","workload/varmail.f"],stdout=benchRet_file)

#    get_kernel_log = subprocess.Popen(["cat","/var/log/kern.log"], stdout=subprocess.PIPE)
#    grep_test_log = subprocess.Popen(["grep", "t_updates"], stdin=get_kernel_log.stdout, stdout=subprocess.PIPE)
#    get_kernel_log.stdout.close()  # Allow p1 to receive a SIGPIPE if p2 exits.
    
#    kernlog = grep_test_log.communicate()[0].decode('utf8')
#    kernlog_file.write(kernlog)
    
#    kernlog_filter = filter(None,kernlog.split('\n'))

#    return kernlog_filter

    

def parse_dmesg(type, kernlog_filter):

    list = []
    x = []
    y = []
    z = []
    count = 0
    for data in kernlog_filter:
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
    parser.add_argument('--filebench',default='',type=str)
    parser.add_argument('--bench',default='',type=str)

    if gArg.plot_type == 'sysbench':
        run_bench("sysbench");



    gArg = parser.parse_args()

    #if gArg.filebench == 'varmail':


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
        kernlog_filter = run_benchmark(1);
        y,z,average,max_t_updates = parse_dmesg(1,kernlog_filter)
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
