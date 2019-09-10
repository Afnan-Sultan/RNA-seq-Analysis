import sys

infile_path = sys.argv[1]
outfile_dir = sys.argv[2]
gtf_type = sys.argv[3]
data_type = sys.argv[4]

data = open(infile_path).readlines()
header = data[0].strip("\n").split(",")
out_header = header[:3] 
first_3cols = []
m = 0
k = 0
if data_type == 'gtf':
    key_words = ['sensitivity', 'specificity']
    start = 1
elif data_type == 'bed':
    key_words = ['exons', 'introns', 'intergenic']
    start = 0

for keyWord in key_words:
    df = []    
    i = 0
    for name in data[start].strip("\n").split(","): 
        if name == keyWord:
            if m == 0:
                out_header.append(header[i])
            temp = []
            for line in data[start+1:]:
                line = line.strip("\n").split(",")
                if k == 0:    
                    first_3cols.append(line[:3])
                temp.append(line[i])
            df.append(temp)
            k += 1
        i += 1
    m += 1
    outfile = open(outfile_dir+'/'+data_type+'_'+keyWord+'.csv', 'w')
    outfile.write(','.join(out_header)+'\n')
    for i in range(len(first_3cols)):
        out = ','.join(first_3cols[i])
        for j in range(len(df)):
            out = out + ',' + df[j][i]
        outfile.write(out+'\n')
    outfile.close()

    new_data = open(outfile_dir+'/'+data_type+'_'+keyWord+'.csv').readlines()[1:]
    dicts = {}
    files = []
    if data_type == 'gtf':
        genomic_regions = ['base_', 'exon_', 'intron_', 'intron_chain_', 'transcript_', 'locus_']
    elif data_type == 'bed':
        genomic_regions = ['_']

    for line in new_data:
        line = line.strip("\n").split(",")
        name = line[:3]
        if name[1] == "poly":
            lib = 'poly_'
        else:
            lib = 'ribo_'
        if name[2] == "brain":
            tissue = 'brain_'
        else:
            tissue = 'tumor_'
        
        i = 3
        for region in genomic_regions:
            if gtf_type == 'single':
                dict_name = lib+tissue+region 
            else:
                dict_name = lib+region
            file_name = dict_name+keyWord+'_'+data_type+'_split.csv'
            if dict_name in dicts:
                open(file_name,'a').write(line[0]+','+str(line[i])+'\n')
                if line[0] in dicts[dict_name]:
                    dicts[dict_name][line[0]].append(line[i])
                else:
                    dicts[dict_name][line[0]] = [line[i]] 
            else:
                dicts[dict_name] = {line[0]:[line[i]]}
                file_out = open(file_name,'w')
                file_out.write('aligner,region\n'+line[0]+','+str(line[i])+'\n')
                file_out.close()
                files.append(file_out)
            i += 1                   
