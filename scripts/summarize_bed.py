import sys
import statistics
import scipy.stats

infile_dir = sys.argv[1]
outfile_dir = sys.argv[2]

infile = open(infile_dir+"/jaccard_mBed.txt").readlines()
outfile = open(outfile_dir+"/jaccard_summary.csv", "w")
outfile.write("aligner,lib,tissue,lib_id,genomic_part,intersection,union_intersection,jaccard,n_intersection\n")

for line in infile:
    if line.startswith("poly") or line.startswith("ribo"):
        line = line.strip('\n').split(' ')
        #print(line)
        name_split = line[2].split("_")
        #print(name_split)
        lib = name_split[0]
        tissue = name_split[1]
        aligner = name_split[2]
        if "intersect" in name_split:
            index = name_split.index("intersect") + 1
            genomic_part = name_split[index].split(".")[0]
        else:
            genomic_part = 'all'
        
        if name_split[3].isdigit():
            cell_id = name_split[3]
        else:
            cell_id = " "
    
        lib_name = aligner + "," + lib + "," + tissue + "," + cell_id + "," + genomic_part  
    else:
        line = line.strip('\n').split('\t')
        if line[0] != 'intersection': 
            temp = ",".join(line)
            output = lib_name + "," + temp + "\n"
            outfile.write(output)
outfile.close()

infile2 = open(outfile_dir+"/jaccard_summary.csv").readlines()[1:]
outfile2 = open(outfile_dir+"/jaccard_vals.csv","w")
outfile2.write("aligner,lib,tissue,lib_id,exons,introns,intergenic\n")

lib_data = {}
for line in infile2:
    line = line.strip("\n").split(",")
    lib_info = ",".join(line[0:4])
    if lib_info in lib_data:
        lib_data[lib_info][line[4]] = str(float(line[7])*100)
    else: 
        lib_data[lib_info] = {line[4]:str(float(line[7])*100)}

for key, val in lib_data.items():
    output = key + "," + val['exons'] + "," + val['introns'] + ',' + val['intergenic']
    outfile2.write(output+"\n")
outfile2.close()
    
