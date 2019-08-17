import statistics
import scipy.stats

def group_info(infile, k):
    '''
    This function groups the data into a dictionary according to library type 
    -poly and ribo- if k = 2, and according to tissue type -brain and tumor- 
    if k = 3.
    '''
    #capture the header to help separating the groups
    in_header1 = infile[0].strip().split(',')
    in_header2 = infile[1].strip().split(',')
    
    #the dictionary in where the data will be grouped
    info_dict = {}
    
    #loop over the file rows, create distinct keys and store all the values corresponding
    #to this key in a list.
    for line in infile[2:]:
        line = line.strip().split(',')
        info = ','.join(line[:k]) #key primary info based on library/tissue. 
                                  #i.e. scallop,poly/poly,brain
        
        #loop over the columns to identify the secondary info. i.e base,sensetivity 
        for i in range(len(in_header1[4:])):
            region_test = ','+in_header1[i+4]+','+in_header2[i+4]
            new_info = info + region_test
            
            #wheneve a key is encountered, the corresponding value is stored.
            if new_info in info_dict:
                info_dict[new_info].append(float(line[i+4]))
            else:
                info_dict[new_info] = [float(line[i+4])]
    return info_dict

def calc_stats(info_dict, k, outfile):
    '''
    This function takes as input the output of the previous function. It then
    performs statistical analysis over each value and store it in a dictionary,
    as well as outputting it to a file.
    The k variable is needed to define the shape of the input. i.e. library based
    -k = 2- or tissue based -k = 3-. 
    '''
    #print(info_dict)
    stats_dict = {}
    if k == 3:
        tissue_state = ['brain', 'tumor']
        outfile.write('aligner,lib,region,test,'+tissue_state[0]+',,'+tissue_state[1]+'\n,,,,mean,std,mean,std,p_val\n')
    else:
        tissue_state = ['poly', 'ribo']
        outfile.write('aligner,region,test,'+tissue_state[0]+',,'+tissue_state[1]+'\n,,,mean,std,mean,std,p_val\n')
    
    #loop over the keys of the dictionary. For each dictionary, there is a 
    #corresponding key with difference in library/tissue name. The loop captures
    #both keys, calculate mean and standared deviation for each key, then
    #calculates p-value for both keys. 
    visited_keys = []  #this list removes redundancy in repeating the analysis.
    for key,val in info_dict.items():
        if key not in visited_keys: 
            if tissue_state[0] in key:
                key2 = key.replace(tissue_state[0], tissue_state[1])
                val2 = info_dict[key2]
            else:
                key2 = key
                val2 = val
                key = key2.replace(tissue_state[1], tissue_state[0])
                val = info_dict[key]     
            #print(key,'\n',key2,'\n')
            #Run the statistics
            new_key = key.replace(','+tissue_state[0], '')
            key_mean = statistics.mean(val)
            key_std = statistics.stdev(val)
            key2_mean = statistics.mean(val2)
            key2_std = statistics.stdev(val2)
            p_val = scipy.stats.ttest_ind(val,val2)
            stats_dict[new_key] = {tissue_state[0]:(key_mean, key_std), tissue_state[1]:(key2_mean, key2_std), 'p_val':p_val[1]}
            outfile.write(new_key+','+str(key_mean)+','+str(key_std)+','+str(key2_mean)+','+str(key2_std)+','+str(p_val[1])+'\n')
            visited_keys.extend([key, key2])

    return stats_dict

infile = open("gffCompare.csv").readlines()
lib_info = group_info(infile, 2)
tissue_info = group_info(infile, 3)

outfile1 = open("lib_stats.csv",'w')
lib_stats = calc_stats(lib_info, 2, outfile1)
outfile1.close()

outfile2 = open("tissue_stats.csv",'w')
tissue_stats = calc_stats(tissue_info, 3, outfile2)
outfile2.close()



	
