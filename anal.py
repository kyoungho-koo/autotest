import numpy as np


lines = []
with open('tmp.txt','r') as f:
    lines = f.readlines()


ret = []
ret_fsync = []

count =0
temp = []
temp_fsync = []
start_time = 0;
for line in lines:
    cur_time = float(line[1:line.find(']')])
    if count > 100:
        break;

    if line.find("phase 7") != -1 :
        if start_time != 0:
            standard = cur_time - start_time;
            for value in temp:
                ret.append((value / standard )*1000)
                #print (value/ standard)
            temp=[]
            for value in temp_fsync:
                ret_fsync.append((value / standard)*1000)
            temp_fsync=[]
        count += 1;
        start_time = cur_time;
    elif (line.find("start") != -1 )and (start_time != 0):
        temp.append(cur_time - start_time);
    elif line.find("fsyn") != -1 and start_time != 0:
        temp.append(cur_time - start_time);
        temp_fsync.append(cur_time - start_time)

#print (ret_fsync)
print (np.mean(ret))
print (np.std(ret))
print (np.mean(ret_fsync))
print (np.std(ret_fsync))



