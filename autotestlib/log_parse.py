import json
import numpy as np

def analysis(lines):
    lat_commit = []
    lat_shadow = []
    lat_forget = []

    for line in lines:
        json_string = line[line.find(']'+1:]
        json_data = json.load(json_string)

        lat_commit.append(json_data["lat_commit"])
        lat_shadow.append(json_data["lat_shadow"])
        lat_forget.append(json_data["lat_forget"])

    print ( "avg commit lat : " + np.mean(lat_commit) + "\n"
            "avg shadow lat : " + np.mean(lat_shadow) + "\n"
            "avg forget lat : " + np.mean(lat_forget) + "\n")


Lines = []
with open('~/filebench/atc20/log/') as log
    Lines = log.readlines()

analysis(Lines)

