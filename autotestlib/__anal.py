import colorama
from colorama import Fore, Style
import numpy as np
import random

#mode
DEBUG = True

#define CONSTANTS
SKIP_RATIO = 0
GRAPH_NUM =  1
DIVIDE_PER_GRAPH = 50
DIVIDE = GRAPH_NUM * DIVIDE_PER_GRAPH
ITERATION_PER_GRAPH = 5000
ITERATION = ITERATION_PER_GRAPH * GRAPH_NUM

CONST = 100


def analysis(lines):
    ret = DIVIDE * [0]
    total = 0

    flush_bar = [[] for y in range(GRAPH_NUM)]
    running_bar = [[0 for x in range(ITERATION_PER_GRAPH)] for y in range(GRAPH_NUM)]
    finished_bar = [[0 for x in range(ITERATION_PER_GRAPH)] for y in range(GRAPH_NUM)]
    



    count =0
    temp = []
    temp_flush_bar = [[] for y in range(GRAPH_NUM)]
    temp_flush_bar[0].append(0)
#temp_fsync = []
    start_time = 0;


    for line in lines:
        cur_time = float(line[1:line.find(']')])

        # Manipulate Iteration
        if count > ITERATION:
            print( count )
            break;

        if (line.find("FLUSH") != -1):
            #print(line)
            if start_time != 0:

                standard = CONST*(cur_time - start_time);

                # for five Continuous Graph
                if (count % GRAPH_NUM == 0):

                    # next step
                    start_time = cur_time;

                    if ( SKIP_RATIO < random.randint(0,100)) :
                        #Make Result
                        #print("== Make Result ",count,"==")
                        for value in temp:
                            #print(value)
                            ret[int(value * DIVIDE / standard)] += 1
                            total += 1
                            #print ( value )
                            #print (value/ standard)
                        for i in range(GRAPH_NUM):
                            for value in temp_flush_bar[i]:
                                flush_bar[i].append(DIVIDE * value / standard)
                   # else :
                        #print(Fore.RED + "== SKIP Result ",count,"==" + Style.RESET_ALL)

                    #initialize
                    temp = []
                    temp_flush_bar = [[] for y in range(GRAPH_NUM)]
                    temp_flush_bar[0].append(0)

                else:
                    temp_flush_bar[int(count%GRAPH_NUM)].append(standard)
            else:
                start_time = cur_time;
            count += 1;
        elif (line.find("fileOperation") != -1) and (start_time != 0):
            temp.append(CONST* (cur_time - start_time));
            #if((count % 5) == 4):
            #    print ( CONST * (cur_time-start_time))
            #temp_fsync.append(cur_time - start_time)

    for i in range(DIVIDE):
        ret[i] = round(ret[i]  / (total / 100 ),2)
    print (ret)
    print()
    return ret
    

#print (ret_fsync)
#print (flush_bar)
    for i in range(GRAPH_NUM):
        print("flush : ",i,int(np.mean(flush_bar[i])));
        #print (ret[int(np.mean(flush_bar[i]))]);
#print (np.mean(ret))
#print (np.std(ret))
#print (np.mean(ret_fsync))
#print (np.std(ret_fsync))
from tempfile import TemporaryFile

for thread in ['16','48']:
    outfile = 'output/fop_exp' + thread + '.csv'
    outRet = [[] for y in range(4)] 
    for i in range(DIVIDE_PER_GRAPH):
        outRet[0].append(i + 1)
    iterator = 1
    for filename in ['840pro','850pro','optane']:
        Lines = []
        directory = 'data/fop_experiments/'+ filename + thread + ".txt"
        print(directory)
        with open(directory,'r') as f:
            Lines = f.readlines()
        outRet[iterator] = analysis(Lines)
        iterator += 1
    ret = np.asarray(outRet)
    a = ret.T
    print (a)
    np.savetxt(outfile,a, delimiter=' ',fmt='%d')



