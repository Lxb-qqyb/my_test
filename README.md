# WES Pipeline Readme 
## WES 生信分析流程
下机数据经过处理后获得原始数据，经过过滤去接头、去污染、然后与参考基因组比对。通过比对结果，去除出每个文库中由于 PCR 扩增引起的重复序列，然后计算出相对于参考基因组的测序深度和覆盖度、单核苷酸位点变异（SNV）、插入/缺失（InDels）等。

### **1、原始数据处理**
测序得到的原始 reads 里面还有带接头的、低质量的碱基，会为后续分析带来影响，为保证信息分析质量， 需要对 raw reads 进行精细过滤得到 clean reads，后续分析都基于clean reads 进行。

数据过滤使用软件：Fastp，过滤原则：
- 切除 reads 中接头部分碱基
- 头尾检查，需要测序质量高于 15
- 滑窗检测，窗口大小为 5bp，平均质量 20
- 过滤序列长度低于 30bp 的 reads。

### **2、比对结果评估**
有效测序数据通过 **sentieon** 比对到参考基因组，得到 BAM 格式的最初比对结果，去除重复 reads，对比对结果进行 Indel Realignment及Base QualityScore Recalibration (BQSR)获得样本最终 BAM 比对文件，同时对比对结果进行覆盖度、深度等的统计。

### **3、变异位点鉴定**
基于肿瘤样本与其对照样本与参考基因组 hs37d5 的 BWA 比对结果，**Vardict** 被用来从测序数据中进行变异鉴定，包括 SNP、INDEL。结果输出为 VCF（VariantCallFormat）格式文件，之后根据过滤条件（详细过滤条件见下）对变异结果过滤，最后利用 **vcf2maf** 对过滤结果进行注释，结果输出为 MAF 格式文件。

### **4、拷贝数变异鉴定**
基于肿瘤样本与其对照样本与参考基因组 hs37d5 的 BWA 比对结果，利用 **Facets** 进行 CNV 鉴定。

## 鉴定条件
#### SNV/Indel：
##### 位点信息分为 normal 和 hotspot 两种。
**保留以下突变类型的突变：**
- "In_Frame_Del" ， "In_Frame_Ins" ， "Missense_Mutation" ， "Nonsense_Mutation","Nonstop_Mutation"， "Splice_Site"，"Translation_Start_Site"
- 只保留 protein_coding 的基因。
- 人群频率阈值为 1%，即 1kg，exac 以及 gnomad 三个数据库的总人群频率和东亚人群频率均低于 1%
- 突变丰度阈值：0.02 即 2%

#### CNV：
**arm 水平:** 
- Amplification：CNVlevel 为 Deep_amplification或者amplification，segment 长度相加大于 arm 长度的 60%
- Deletion：CNVlevel 为 Deletion或者Deep_deletion，segment 长度相加大于 arm 长度的 60%。

**gene 水平:** 
- 扩增：注释上 hotgene，CNVlevel 为 Deep_amplification
- 缺失：注释上 hotgene，CNVlevel 为 Deep_deletion

## 参考文献：
>Shifu Chen, Yanqing Zhou, Yaru Chen, Jia Gu, fastp: an ultra-fast all-in-one FASTQ preprocessor, Bioinformatics, Volume 34, Issue 17, 01 September 2018, Pages i884–i890.

>Lai Z, et al. VarDict: a novel and versatile variant caller for next-generation sequencing in cancer research. Nucleic Acids Res. 2016;44:e108.

>Shen R, Seshan VE. FACETS: allele-specific copy number and clonal heterogeneity analysis tool for high-throughput DNA sequencing. Nucleic Acids Res. 2016;44(16):e131. 

>Riaz, N., Havel, J. J., Makarov, V., Desrichard, A., Urba, W. J., Sims, J. S., ... & Bhatia,S. (2017). Tumor and microenvironment evolution during immunotherapy with nivolumab. Cell, 171(4), 934-949.

## 软件版本：
- fastp 0.20.0
- Vardict V1.5.4
- facets 0.5.13
