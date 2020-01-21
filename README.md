# Motivation

  The study of transcriptome enables us to understand the functionality of the genome in different physiological conditions, development stages, and disease status [1]. Two widely used transcriptome data come from poly(A) enriched libraries [2] or poly(A)- library which depends on depleting ribosomal RNA [3]. Both libraries are important in analyzing different functionality and to gain different insights about the cell. However, both libraries are usually assembled by the same RNA-seq assemblers even tho the two libraries exhibit huge content difference [3, 4, 5, 6] that might affect the assemblers' performance differently. Our suspicion is that due to the higher content and difference of ribo-depleted libraries, and since most assemblers were designed to detect the most features of poly(A) libraries, the performance of the assemblers will be compromised for ribo-depleted libraries. This project designed different pipelines for assembling RNA-seq reads coming from both poly(A) and ribo-depleted libraries. We also used assemblers that were made to assemble RNA-seq reads either based on a reference or de novo. The results showed that performance of the assemblers on the same tissue but using different libraries were greatly negatively affected for ribo-depleted RNA-seq.     

# Materials and Methods

## Data

  A publicly available dataset [6] was used for the benchmarking analysis. The dataset is composed of paired-end poly(A) and ribo-depleted RNA-seq libraries for the same human tissues, including healthy brain tissues and tumor brain tissues. The reference genome (GRCh38) and transcriptome annotation files were obtained from GENCODE Release 27. 

## Reads download, quality assurance and data normalization

  The reads were downloaded using the sra-toolkit [7]. For each library preparation, reads coming from the same biological sample in all sequencing lanes were merged together, adapters were trimmed and low-quality reads were discarded using Trimomatic 0.36 [8]. The data was normalized to have equal number  of reads per both libraries. The bigger samples were subsampled randomly using seqtk [9].

## Transcriptome assembly using reference based pipeline

  Two pipelines were used: HISAT2 [10] - StringTie v1.3.4 [11] and STAR v2.5.3a [12] - Scallop [13]. The  aligners were fed with the reference genome to generate indexes, then each pair of the fastq paired reads were given to the aligner to output a sam file. Sam files were sorted and converted to bam files using samtools 1.6 [14]. The bam files were used as input to the assemblers. The assembly was done without reference transcriptome annotation guidance in order to assess the ability of these programs to assemble the correct transcriptome independently. The outputs GTF files of the HISAT-StringTie pipeline for each tissue type were merged into one gtf file using stringtie merge software. Cuffmerge from cufflinks 2.2.1 package [15] was used to do the same for the outputs GTF files of the STAR-Scallop pipeline. 

## Transcriptome assembly using De novo pipeline

  Trinity 2.5.1 was used for de novo assembly. The output fasta files were converted into GTF files using a pipeline of blat, pslToBed, bedToGenPred and GenPredToGTF tools from ucsclib [16]. Cuffmerge was used to merge the resulted GTF files for each tissue type.

## Benchmarking Analysis

  Sensitivity and specificity for the detection of transcriptomic features were calculated using gffcompare 0.10.1 [17]. Base pair intersection between the assembled transcriptomes and different genomic parts (intronic, exonic and intergenic) was done using bedtools [18]. Different between-group analysis was done using R.  

# Results

## Sensitivity and Specificity 

Sensitivity and specificity were calculated per base pair, exon, intron, intron chain, transcript and locus levels for each sample. The samples were then analysed statistically to highlight the different behavior of each library. Table 1 and 2 show the sensitivity and specificity for the two studied libraries over all tissues and samples with each assembler.

Table 1 shows the sensitivity for both libraries regardless of the tissue type. The values at each level represent the mean value for all samples that belong to this library. Standard deviation values can be found in [supplementary1](https://docs.google.com/spreadsheets/d/10a3DVhutzcYtuJMuFTLCK2HrLlniRZhSuxamEBnz9j4/edit?usp=sharing). Sensitivity for poly-A libraries was higher for all genomic levels and for all assemblers. The difference was significant statistically as well between both libraries as indicated by the P-value. The last two columns represent the Anova test to compare the performance of the three assemblers with respect to library. The test showed significant difference between the performance of the three assemblers for all genomic levels. For the genomic levels, sensitivity for bases was generally higher than all other levels, and sensitivity for introns was higher than exons across all assemblers and libraries. regarding the assemblers, Stringtie performed better on the base level, however, exon and intron levels showed sensitivity closer to the other two assemblers.  

![](https://github.com/Afnan-Sultan/RNA-seq-Analysis/blob/master/Figures/repo1.PNG)

The sensitivity tables for brain and tumor tissues independently, available in tables 3 in [supplementary1](https://docs.google.com/spreadsheets/d/10a3DVhutzcYtuJMuFTLCK2HrLlniRZhSuxamEBnz9j4/edit?usp=sharing) data,  showed a similar pattern on genomic levels where poly-A libraries had higher sensitivity and introns sensitivity was higher than exons. The pattern across assemblers was also preserved. The differences between table 1 and tissue-specific tables were seen in the P-values for the Anova test. For brain tissues, the three assemblers performed similarly on the exon and intron levels for ribo-depleted library only. For tumor tissues, exon and intron levels didn’t show significant difference for poly-A library, while only base level showed significant difference for ribo-depleted library. Another observation was that all of brain tissue values lie above the mean values of table 1, while all values of tumor tissues lie below it. 

To further understand the effect of tissue on the library, tables 5 and 6 in [supplementary1](https://docs.google.com/spreadsheets/d/10a3DVhutzcYtuJMuFTLCK2HrLlniRZhSuxamEBnz9j4/edit?usp=sharing) shows the statistical difference between brain and tumor tissues at each genomic level with respect to the library and the assembler. For poly-A library, only base and intron levels showed significant difference between the two tissues for Scallop and Stringtie, while only base level showed significant difference for Trinity. The case was different for ribo-depleted libraries across the assemblers. For scallop, all genomic levels showed significant difference between brain and tumor tissues. Stringtie showed significant difference on the levels of base, exon and introns only, while Trinity showed significant difference for all levels except locus.

Table 2 shows the specificity for the two libraries, where the same pattern of sensitivity can be observed. Poly-A libraries showed higher specificity than ribo-depleted in all assemblers with significant difference, as well as a significant difference between the three assemblers performance. An interesting result is that specificity of intron level is very high for all three assemblers with specificity higher than 95% for Scallop and Stringtie and higher than 81% for trinity. Also, the difference in specificity on the intron level was slight between poly-A and ribo-depleted libraries for Scallop and StringTie. The pattern for genomic levels were also quite similar with sensitivity, base specificity was higher than all other levels except for introns, and introns specificity was significantly higher compared to exons. Although the pattern matches between sensitivity and specificity, the values show a great discrepancy across libraries and assemblers. For Scallop, the difference between all genomic levels for both libraries were similar to sensitivity except for base and intron levels, base specificity had a higher drop between poly-A and ribo depleted while intron level didn’t exhibit a noticeable change. For Stringtie and trinity, all genomic level specificity were almost halved or more between poly-A and ribo-depleted libraries except for intron level.  

![](https://github.com/Afnan-Sultan/RNA-seq-Analysis/blob/master/Figures/repo2.PNG)

Tables 3 and 4 in [supplementary1](https://docs.google.com/spreadsheets/d/10a3DVhutzcYtuJMuFTLCK2HrLlniRZhSuxamEBnz9j4/edit?usp=sharing) shows the specificity analysis for both brain and tumor independently. They also exhibited the same pattern for the two libraries across the genomic levels and assemblers. The mean values for Brain tissues lie above the mean values of table 2 such as sensitivity in table 1, and tumor tissues values lie below it. The P-values of brain tissues were all significant except for intron level between poly-A and ribo-depleted libraries for Stringtie, as well as intron chain for poly-A library across the three assemblers for the Anova test. All P-values for tumor tissues were significant. Additional observation was that the drop between specificity for both libraries was higher for tumor tissues than for brain tissues.

To further analyse the differences between brain and tumor tissues in terms of specificity, tables 6 in [supplementary1](https://docs.google.com/spreadsheets/d/10a3DVhutzcYtuJMuFTLCK2HrLlniRZhSuxamEBnz9j4/edit?usp=sharing) provides the P-values for comparing both libraries with respect to tissue. This time, poly-A library doesn’t show any significant difference across any genomic level for any of the three assemblers. For ribo-depleted library, all genomic levels exhibited significant difference between tissues for Scallop and Trinity. This was also the case for Stringtie except for intron and intron chain levels. 

Generally, scallop performed slightly better for most of the genomic levels for sensitivity and specificity. Stringtie and trinity had similar values for specificity, however, trinity performed slightly worse for specificity. The most important observation for both tables is that the performance always declined for ribo-depleted libraries regardless of the assembler.

The same analysis were done after merging the libraries for each sample regardless of the tissue type, tables 1 and 2 in [supplementary2](https://docs.google.com/spreadsheets/d/1x3pLYdyc8KZCveFD7HYAsKm8-8F_JQPG7mV1yaaY7ZM/edit?usp=sharing), the same trend discussed above almost persisted. Poly-A libraries showed higher sensitivity and specificity than ribo-depleted for the three assemblers, base sensitivity/specificity was almost the highest, and introns sensitivity/specificity was higher than exons. Generally, the sensitivity increased for all genomic levels across the three assemblers while specificity decreased.

The merged libraries were also merged with respect to tissue, and both sensitivity and specificity were calculated, Tables 3-6 in [supplementary2](https://docs.google.com/spreadsheets/d/1x3pLYdyc8KZCveFD7HYAsKm8-8F_JQPG7mV1yaaY7ZM/edit?usp=sharing). The same pattern for libraries and assemblers was preserved as table 1 and 2. Also, brain tissues generally exhibited higher performance than tumor tissues for all values.  

## Intersection with genomic regions

In addition to sensitivity and specificity analysis, the assemblers’ transcriptomes were compared against reference transcriptome to determine how much of these transcriptomes map to intronic, exonic or intergenic base pairs. 

Table 3 shows the mean values for each sample as well as the p-value for difference between poly-A and ribo-depleted libraries. The three assemblers showed regions mapping to exons for poly-A libraries way more than ribo-depleted. The case is inverted for intronic regions as ribo-depleted libraries map big portion of its content to introns compared to poly-A. Stringtie and Trinity are performing very poorly as more than half of the reads map to intronic base pairs. Intergenic regions occupied small percentage from the mapping and didn’t have significant difference for any of the three assemblers. On the contrast, intersection with exonic and intronic regions showed very strong statistical difference between poly-A and ribo-depleted for all assemblers.

The p-value for the anova test showed very strong statistical difference for poly-A and ribo-depleted libraries among the three assemblers for all regions, including intergenic one. Again, scallop outperforms the other assemblers with much higher percentage of the transcriptome mapping to exonic regions for both poly-A and ribo-depleted. Trinity is outperforming stringtie for poly-A, but stringtie performed better for ribo-depleted library. 

![](https://github.com/Afnan-Sultan/RNA-seq-Analysis/blob/master/Figures/repo4.PNG)

The same analysis was done with respect to tissue, table 2 and 3 in [supplementary3](https://docs.google.com/spreadsheets/d/1CL4a0loD2ZFupbhLMCbhpX9Eac1fb-lxJ2ZNzYFOWAA/edit?usp=sharing).  The same pattern persisted as  table 3 for the libraries and assemblers. Almost all P-values were significant for both brain and tumor tissues, and both tissues fluctuated around the mean values of table 3. 

To identify the difference between the two tissue types, table 4 in [supplementary3](https://docs.google.com/spreadsheets/d/1CL4a0loD2ZFupbhLMCbhpX9Eac1fb-lxJ2ZNzYFOWAA/edit?usp=sharing) provides a comparison between the two tissues in terms of P-value. exons and introns base pairs maintained a uniform pattern across poly-A and ribo-depleted libraries for the three assemblers; there was no significant difference between poly-A libraries, but strong difference between ribo-depleted libraries.  Intergenic base pairs didn’t exhibit a uniform pattern across libraries or assemblers.  

In addition to averaging the samples intersection with genomic regions, all samples were merged and the same analysis were done again to test the differences before and after merging table 1 in [supplementary4](https://docs.google.com/spreadsheets/d/1dgCwjvbRirgNfXiuTk_8U4FyaT5Vch7ni-dzP3Kgyhs/edit?usp=sharing). The intersection between the three regions decreased for scallop and trinity as well as stringtie when merged using cuffmerge. However, the merged libraries improved significantly for stringtie when merged using StringtieMerge. Despite the improvement for stringtie results, applying StringtieMerge for scallop and trinity libraries didn’t enhance their performance.

# Discussion and remaining work

The above highlights the cases where RNA-seq assemblers manage to use most of the information content from poly(A) library, yet fail to assemble ribo-depleted library properly. Big chunk of the data contained in ribo-depleted libraries is mislabeled as intronic regions. 

Further analysis needed is to dig deeper into the assembled transcriptome and compare it to the reference transcriptome. This should give us more insight about the types of errors the assembler are prone to, the additional info retained in ribo-depleted libraries and propose future guidelines for better analysis when using ribo-depleted libraries. 

# References

1- Wang, Z., Gerstein, M., & Snyder, M. (2009). RNA-Seq: A revolutionary tool for transcriptomics. Nature Reviews Genetics, 10(1), 57-63. doi:10.1038/nrg2484

2- Sultan M, Dokel S, Amstislavskiy V, Wuttig D, Sultmann H, Lehrach H, Yaspo ML. A simple strand-specific RNA-Seq library preparation protocol combining the Illumina TruSeq RNA and the dUTP methods. Biochem Biophys Res Commun. 2012;422(4):643–646. doi: 10.1016/j.bbrc.2012.05.043.

3- Cui, P., Lin, Q., Ding, F., Xin, C., Gong, W., Zhang, L., . . . Yu, J. (2010). A comparison between ribo-minus RNA-sequencing and polyA-selected RNA-sequencing. Genomics, 96(5), 259-265. doi:10.1016/j.ygeno.2010.07.010

4- Tariq, M. A., Kim, H. J., Jejelowo, O., & Pourmand, N. (2011). Whole-transcriptome RNAseq analysis from minute amount of total RNA. Nucleic Acids Research, 39(18). doi:10.1093/nar/gkr547

5- Li, S., Tighe, S. W., Nicolet, C. M., Grove, D., Levy, S., Farmerie, W., . . . Mason, C. E. (2014). Multi-platform assessment of transcriptome profiling using RNA-seq in the ABRF next-generation sequencing study. Nature Biotechnology, 32(9), 915-925. doi:10.1038/nbt.2972

6- Sultan, M., Amstislavskiy, V., Risch, T., Schuette, M., Dökel, S., Ralser, M., . . . Yaspo, M. (2014). Influence of RNA extraction methods and library selection schemes on RNA-seq data. BMC Genomics, 15(1), 675. doi:10.1186/1471-2164-15-675

7- https://hpc.nih.gov/apps/sratoolkit.html 

8- Bolger, A. M., Lohse, M., & Usadel, B. (2014). Trimmomatic: A flexible trimmer for Illumina sequence data. Bioinformatics, 30(15), 2114-2120. doi:10.1093/bioinformatics/btu170

9- https://github.com/lh3/seqtk 

10- Kim, D., Langmead, B., & Salzberg, S. L. (2015). HISAT: A fast spliced aligner with low memory requirements. Nature Methods, 12(4), 357-360. doi:10.1038/nmeth.3317

11- Garber, M., Grabherr, M. G., Guttman, M., & Trapnell, C. (2011). Computational methods for transcriptome annotation and quantification using RNA-seq. Nature Methods, 8(6), 469-477. doi:10.1038/nmeth.1613

12- Dobin, A., Davis, C. A., Schlesinger, F., Drenkow, J., Zaleski, C., Jha, S., . . . Gingeras, T. R. (2012). STAR: Ultrafast universal RNA-seq aligner. Bioinformatics, 29(1), 15-21. doi:10.1093/bioinformatics/bts635

13- Shao, M., & Kingsford, C. (2017). Scallop Enables Accurate Assembly Of Transcripts Through Phasing-Preserving Graph Decomposition. doi:10.1101/123612 

14- Li, H., Handsaker, B., Wysoker, A., Fennell, T., Ruan, J., Homer, N., . . . Durbin, R. (2009). The Sequence Alignment/Map format and SAMtools. Bioinformatics, 25(16), 2078-2079. doi:10.1093/bioinformatics/btp352

15- http://cole-trapnell-lab.github.io/cufflinks/ 

16- http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/ 

17- ttps://github.com/gpertea/gffcompare 

18- https://bedtools.readthedocs.io/en/latest/ 



