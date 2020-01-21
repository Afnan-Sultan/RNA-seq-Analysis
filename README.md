# Motivation

  The study of transcriptome enables us to understand the functionality of the genome in different physiological conditions, development stages, and disease status [1]. Two widely used transcriptome data come from poly(A) enriched libraries [16] or poly(A)- library which depends on depleting ribosomal RNA [4]. Both libraries are important in analyzing different functionality and to gain different insights about the cell. However, both libraries are usually assembled by the same RNA-seq assemblers even tho the two libraries exhibit huge content difference [4, 10, 11, 12] that might affect the assemblers' performance differently. Our suspicion is that due to the higher content and difference of ribo-depleted libraries, and since most assemblers were designed to detect the most features of poly(A) libraries, the performance of the assemblers will be compromised for ribo-depleted libraries. This project designed different pipelines for assembling RNA-seq reads coming from both poly(A) and ribo-depleted libraries. We also used assemblers that were made to assemble RNA-seq reads either based on a reference or de novo. The results showed that performance of the assemblers on the same tissue but using different libraries were greatly negatively affected for ribo-depleted RNA-seq.     

# Materials and Methods

## Data

  A publicly available dataset [12] was used for the benchmarking analysis. The dataset is composed of paired-end poly(A) and ribo-depleted RNA-seq libraries for the same human tissues, including healthy brain tissues and tumor brain tissues. The reference genome (GRCh38) and transcriptome annotation files were obtained from GENCODE Release 27. 

## Reads download, quality assurance and data normalization

  The reads were downloaded using the sra-toolkit [18]. For each library preparation, reads coming from the same biological sample in all sequencing lanes were merged together, adapters were trimmed and low-quality reads were discarded using Trimomatic 0.36 [19]. The data was normalized to have equal number  of reads per both libraries. The bigger samples were subsampled randomly using seqtk [25].

## Transcriptome assembly using reference based pipeline

  Two pipelines were used: HISAT2 [5] - StringTie v1.3.4 [8] and STAR v2.5.3a [6] - Scallop [13]. The  aligners were fed with the reference genome to generate indexes, then each pair of the fastq paired reads were given to the aligner to output a sam file. Sam files were sorted and converted to bam files using samtools 1.6 [20]. The bam files were used as input to the assemblers. The assembly was done without reference transcriptome annotation guidance in order to assess the ability of these programs to assemble the correct transcriptome independently. The outputs GTF files of the HISAT-StringTie pipeline for each tissue type were merged into one gtf file using stringtie merge software. Cuffmerge from cufflinks 2.2.1 package [22] was used to do the same for the outputs GTF files of the STAR-Scallop pipeline. 

## Transcriptome assembly using De novo pipeline

  Trinity 2.5.1 was used for de novo assembly. The output fasta files were converted into GTF files using a pipeline of blat, pslToBed, bedToGenPred and GenPredToGTF tools from ucsclib [21]. Cuffmerge was used to merge the resulted GTF files for each tissue type.

## Benchmarking Analysis

  Sensitivity and specificity for the detection of transcriptomic features were calculated using gffcompare 0.10.1 [23]. Base pair intersection between the assembled transcriptomes and different genomic parts (intronic, exonic and intergenic) was done using bedtools [24]. Different between-group analysis was done using R.  

# Results

## Sensitivity and Specificity 

Sensitivity and specificity were calculated per base pair, exon, intron, intron chain, transcript and locus levels for each sample. The samples were then analysed statistically to highlight the different behavior of each library. Table 1 and 2 show the sensitivity and specificity for the two studied libraries over all tissues and samples with each assembler.

Table 1 shows the sensitivity for both libraries regardless of the tissue type. The values at each level represent the mean value for all samples that belong to this library. Standard deviation values can be found in [supplementary](https://docs.google.com/document/d/1xAWk4MIoafpGdCEr_A9PoQTUybusyoLcF7rNrnVuDGU/edit?usp=sharing). Sensitivity for poly-A libraries was higher for all genomic levels and for all assemblers. The difference was significant statistically as well between both libraries as indicated by the P-value. The last two columns represent the Anova test to compare the performance of the three assemblers with respect to library. The test showed significant difference between the performance of the three assemblers for all genomic levels. For the genomic levels, sensitivity for bases was generally higher than all other levels, and sensitivity for introns was higher than exons across all assemblers and libraries. regarding the assemblers, Stringtie performed better on the base level, however, exon and intron levels showed sensitivity closer to the other two assemblers.  

![](https://github.com/Afnan-Sultan/RNA-seq-Analysis/blob/master/Figures/repo1.PNG)

The sensitivity tables for brain and tumor tissues independently, available in supplementary data,  showed a similar pattern on genomic levels where poly-A libraries had higher sensitivity and introns sensitivity was higher than exons. The pattern across assemblers was also preserved. The differences between table 1 and tissue-specific tables were seen in the P-values for the Anova test. For brain tissues, the three assemblers performed similarly on the exon and intron levels for ribo-depleted library only. For tumor tissues, exon and intron levels didn’t show significant difference for poly-A library, while only base level showed significant difference for ribo-depleted library. Another observation was that all of brain tissue values lie above the mean values of table 1, while all values of tumor tissues lie below it. 

To further understand the effect of tissue on the library, table x in [supplementary](https://docs.google.com/document/d/1xAWk4MIoafpGdCEr_A9PoQTUybusyoLcF7rNrnVuDGU/edit?usp=sharing) shows the statistical difference between brain and tumor tissues at each genomic level with respect to the library and the assembler. For poly-A library, only base and intron levels showed significant difference between the two tissues for Scallop and Stringtie, while only base level showed significant difference for Trinity. The case was different for ribo-depleted libraries across the assemblers. For scallop, all genomic levels showed significant difference between brain and tumor tissues. Stringtie showed significant difference on the levels of base, exon and introns only, while Trinity showed significant difference for all levels except locus.

Table 2 shows the specificity for the two libraries, where the same pattern of sensitivity can be observed. Poly-A libraries showed higher specificity than ribo-depleted in all assemblers with significant difference, as well as a significant difference between the three assemblers performance. An interesting result is that specificity of intron level is very high for all three assemblers with specificity higher than 95% for Scallop and Stringtie and higher than 81% for trinity. Also, the difference in specificity on the intron level was slight between poly-A and ribo-depleted libraries for Scallop and StringTie. The pattern for genomic levels were also quite similar with sensitivity, base specificity was higher than all other levels except for introns, and introns specificity was significantly higher compared to exons. Although the pattern matches between sensitivity and specificity, the values show a great discrepancy across libraries and assemblers. For Scallop, the difference between all genomic levels for both libraries were similar to sensitivity except for base and intron levels, base specificity had a higher drop between poly-A and ribo depleted while intron level didn’t exhibit a noticeable change. For Stringtie and trinity, all genomic level specificity were almost halved or more between poly-A and ribo-depleted libraries except for intron level.  

![](https://github.com/Afnan-Sultan/RNA-seq-Analysis/blob/master/Figures/repo2.PNG)

Tables x and y in [supplementary](https://docs.google.com/document/d/1xAWk4MIoafpGdCEr_A9PoQTUybusyoLcF7rNrnVuDGU/edit?usp=sharing) shows the specificity analysis for both brain and tumor independently. They also exhibited the same pattern for the two libraries across the genomic levels and assemblers. The mean values for Brain tissues lie above the mean values of table 2 such as sensitivity in table 1, and tumor tissues values lie below it. The P-values of brain tissues were all significant except for intron level between poly-A and ribo-depleted libraries for Stringtie, as well as intron chain for poly-A library across the three assemblers for the Anova test. All P-values for tumor tissues were significant. Additional observation was that the drop between specificity for both libraries was higher for tumor tissues than for brain tissues.

To further analyse the differences between brain and tumor tissues in terms of specificity, table x in [supplementary](https://docs.google.com/document/d/1xAWk4MIoafpGdCEr_A9PoQTUybusyoLcF7rNrnVuDGU/edit?usp=sharing) provides the P-values for comparing both libraries with respect to tissue. This time, poly-A library doesn’t show any significant difference across any genomic level for any of the three assemblers. For ribo-depleted library, all genomic levels exhibited significant difference between tissues for Scallop and Trinity. This was also the case for Stringtie except for intron and intron chain levels. 
Generally, scallop performed slightly better for most of the genomic levels for sensitivity and specificity. Stringtie and trinity had similar values for specificity, however, trinity performed slightly worse for specificity. The most important observation for both tables is that the performance always declined for ribo-depleted libraries regardless of the assembler.
The same analysis were done after merging the libraries for each sample regardless of the tissue type, table x and y in [supplementary](https://docs.google.com/document/d/1xAWk4MIoafpGdCEr_A9PoQTUybusyoLcF7rNrnVuDGU/edit?usp=sharing), the same trend discussed above almost persisted. Poly-A libraries showed higher sensitivity and specificity than ribo-depleted for the three assemblers, base sensitivity/specificity was almost the highest, and introns sensitivity/specificity was higher than exons. Generally, the sensitivity increased for all genomic levels across the three assemblers while specificity decreased.
The merged libraries were also merged with respect to tissue, and both sensitivity and specificity were calculated, Tables x-y in [supplementary](https://docs.google.com/document/d/1xAWk4MIoafpGdCEr_A9PoQTUybusyoLcF7rNrnVuDGU/edit?usp=sharing). The same pattern for libraries and assemblers was preserved as table 1 and 2. Also, brain tissues generally exhibited higher performance than tumor tissues for all values.  

## Intersection with genomic regions

In addition to sensitivity and specificity analysis, the assemblers’ transcriptomes were compared against reference transcriptome to determine how much of these transcriptomes map to intronic, exonic or intergenic base pairs. 

Table 3 shows the mean values for each sample as well as the p-value for difference between poly-A and ribo-depleted libraries. The three assemblers showed regions mapping to exons for poly-A libraries way more than ribo-depleted. The case is inverted for intronic regions as ribo-depleted libraries map big portion of its content to introns compared to poly-A. Stringtie and Trinity are performing very poorly as more than half of the reads map to intronic base pairs. Intergenic regions occupied small percentage from the mapping and didn’t have significant difference for any of the three assemblers. On the contrast, intersection with exonic and intronic regions showed very strong statistical difference between poly-A and ribo-depleted for all assemblers.

The p-value for the anova test showed very strong statistical difference for poly-A and ribo-depleted libraries among the three assemblers for all regions, including intergenic one. Again, scallop outperforms the other assemblers with much higher percentage of the transcriptome mapping to exonic regions for both poly-A and ribo-depleted. Trinity is outperforming stringtie for poly-A, but stringtie performed better for ribo-depleted library. 

![](https://github.com/Afnan-Sultan/RNA-seq-Analysis/blob/master/Figures/repo4.PNG)

The same analysis was done with respect to tissue, table x and y in [supplementary](https://docs.google.com/document/d/1xAWk4MIoafpGdCEr_A9PoQTUybusyoLcF7rNrnVuDGU/edit?usp=sharing).  The same pattern persisted as  table 3 for the libraries and assemblers. Almost all P-values were significant for both brain and tumor tissues, and both tissues fluctuated around the mean values of table 3. 

To identify the difference between the two tissue types, table x in [supplementary](https://docs.google.com/document/d/1xAWk4MIoafpGdCEr_A9PoQTUybusyoLcF7rNrnVuDGU/edit?usp=sharing) provides a comparison between the two tissues in terms of P-value. exons and introns base pairs maintained a uniform pattern across poly-A and ribo-depleted libraries for the three assemblers; there was no significant difference between poly-A libraries, but strong difference between ribo-depleted libraries.  Intergenic base pairs didn’t exhibit a uniform pattern across libraries or assemblers.  

In addition to averaging the samples intersection with genomic regions, all samples were merged and the same analysis were done again to test the differences before and after merging table x in [supplementary](https://docs.google.com/document/d/1xAWk4MIoafpGdCEr_A9PoQTUybusyoLcF7rNrnVuDGU/edit?usp=sharing). The intersection between the three regions decreased for scallop and trinity as well as stringtie when merged using cuffmerge. However, the merged libraries improved significantly for stringtie when merged using StringtieMerge. Despite the improvement for stringtie results, applying StringtieMerge for scallop and trinity libraries didn’t enhance their performance.

# Discussion and remaining work

The above highlights the cases where RNA-seq assemblers manage to use most of the information content from poly(A) library, yet fail to assemble ribo-depleted library properly. Big chunk of the data contained in ribo-depleted libraries is mislabeled as intronic regions. 

Further analysis needed is to dig deeper into the assembled transcriptome and compare it to the reference transcriptome. This should give us more insight about the types of errors the assembler are prone to, the additional info retained in ribo-depleted libraries and propose future guidelines for better analysis when using ribo-depleted libraries. 
