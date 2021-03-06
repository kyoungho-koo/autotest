class Experiments:

    def __init__(self, matrix,process):
        self.matrix = matrix
        self.process = process

    def run_bench(self,filename, param_list):
        print("RUN Bench",filename ,param_list);

    def nested_loop(self,name,depth,param_list):
        if depth == 0:
            param_list = []

        if depth == len(self.matrix):
            self.process(name,param_list)
            return

        for index in self.matrix[depth][1:]:
            local_list = param_list.copy()
            local_list.append(index)
            self.nested_loop ( name+self.matrix[depth][0],depth+1,local_list)


    def run(self):
        self.nested_loop("",0,[])


#matrix = [ ["device","nvme0n1","sdd1","sdc1"],  ["client",1 ,2 ,3 ,4 ,5], ["thread",2 ,4 ,5 ,8] ]

#Experiments(matrix).run()
