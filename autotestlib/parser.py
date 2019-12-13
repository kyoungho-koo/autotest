
infile = open("Input.txt", "r")
outfile = open("Output.txt", "w")
for line in infile.readline():
    temp = infile.readline()
    value = temp.split("<_|_>")
    outfile.write(value[1])
