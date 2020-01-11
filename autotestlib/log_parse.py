import json
import numpy as np

def analysis(lines):
    lat_commit = []
#    lat_shadow = []
#    lat_forget = []

    for line in lines:
        #print (line)
        try:
            json_string = line[line.find('{'):line.find('}')+1]
            json_data = json.loads(json_string)

            lat_commit.append(json_data["lat_commit"])
#           lat_shadow.append(json_data["lat_shadow"])
#           lat_forget.append(json_data["lat_forget"])

#            "avg shadow lat : " + np.mean(lat_shadow) + "\n"
#            "avg forget lat : " + np.mean(lat_forget) + "\n")
        except:
            a = 1
    print ( "avg commit lat : " + str(np.mean(lat_commit) )+ "\n")
      #      print("") 


for thread in [10 ,20 ,30 ,40 ,50]:
    Lines = []
    filename = 'data/sysbench/ext4/filesize_old/64G/log/nvme0n1thread'+str(thread) + '.log'
    print ("======== nvme0n1thread" + str(thread) + ".log ===========")

    with open(filename) as log:
        Lines = log.readlines()

    analysis(Lines)

