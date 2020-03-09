import json
import numpy as np

def log(filename,mesg):
    print ( filename + "\t:\t" + mesg)
def isSkip(json_data, line_num):
    if ( line_num < 300):
        return 1
    elif ( json_data["dev"] == 8388609):
        return 1
    else:
        return 0

def analysis(lines,filename):
    handle = []
    blocks = []
    lat_commit = []

    psp = []
    mem_overhead = []

    sleeptime = []
    sleepcount = []
    deg_coalescing = []
    line_num = 0
    for line in lines:
        try:
            json_string = line[line.find('{'):line.find('}')+1]
            if (json_string[-3] == ","):
                json_string = json_string[:-3] + "}"
            if (json_string[-2] == ","):
                json_string = json_string[:-2] + "}"

            json_data = json.loads(json_string)
            line_num += 1
            if ( isSkip(json_data, line_num) ):
                continue

            handle.append(json_data["handle"])
            blocks.append(json_data["blocks"])
            lat_commit.append(json_data["lat_commit"])

            if "psp" in json_data:
                psp.append(json_data["psp"])
            if "mem_overhead" in json_data:
                mem_overhead.append(json_data["mem_overhead"])

            if "sleeptime" in json_data:
                sleeptime.append(json_data["sleeptime"])
            if "sleepcount" in json_data:
                sleepcount.append(json_data["sleepcount"])
            if "deg_coalescing" in json_data:
                deg_coalescing.append(json_data["deg_coalescing"])
        except:
            pass
    print(filename +":total flush :\t" + str(len(handle)))
    print(filename +":avg handle :\t" + str(np.mean(handle)))
    print(filename +":avg blocks :\t" + str(np.mean(blocks) ))
    print(filename +":avg late_commit :\t" + str(np.mean(lat_commit) ))

    if psp:
        print(filename +":avg psp :\t" + str(np.mean(psp) ))
    if mem_overhead:
        print(filename + ":avg mem_overhead :\t" + str(np.mean(mem_overhead) ))

    if sleeptime:
        print(filename + ":avg sleeptime :\t" + str(np.mean(sleeptime) ))
    if sleepcount:
        print(filename + ":avg sleepcount :\t" + str(np.mean(sleepcount) ))
    if deg_coalescing:
        print(filename + ":avg deg_coalescing :\t" + str(np.mean(deg_coalescing) ))

for kernel in ["ext4" , "shadowing", "c2j"]:
    for device in ["nvme0n1","sdd1"]:
        for thread in range(1,49):
            Lines = []
            dirname = 'dbench/' + kernel + "/"
            filename = device + 'clients'+ str(thread) + "process1.log" 
            try:
                with open(dirname+filename) as log:
                    Lines = log.readlines()

                print ("======== " + filename + " ===========")
                analysis(Lines,kernel+filename)
            except:
                pass

