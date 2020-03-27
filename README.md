# Towards omics-based predictions of planktonic functional composition from known and unknown proteins and physico-chemical data
Code to reproduce results from Faure et al. 2020, Towards omics-based predictions of planktonic functional composition from known and unknown proteins and physico-chemical data

All information on how to download MAGs are already detailes in http://merenlab.org/data/tara-oceans-mags/.

*Script_Creation_SSN.sh* allows to detect genes and translate them into proteins in all MAGs files through Prodigal, then blast the obtained genes against themselves using Diamond. Finally, it filters diamond output, and calls the perl script *diamond2graph_V2.pl*, which transforms the Diamond output to an igraph compatible file.

*KOFamScan.sh* allows to annotate all MAGs' proteins using KOFamScan, which has to be installed first (see instructions here : https://www.genome.jp/tools/kofamkoala/)
*eggnog_mags_allprot.qsub* and *eggnog_mags_annot_allprot.qsub* allow to annotate all MAGs' proteins using eggNOG mapper, which also has to be installed (see instructions here : https://github.com/eggnogdb/eggnog-mapper)

*Quantif_genes.sh* allows to quantify proteins sequence abundance in metagenomes using Salmon, which has to be downloaded as instructed here : https://salmon.readthedocs.io/en/latest/salmon.html.

Finally, the R scripts allowing to build the sequence similarity network in igraph, extract the protein functional clusters, and study their response to the environment were all concatenated in the R markdown file *Script_Statistical_Analysis_Faureetal2020.Rmd*. An html version of this code, including code outputs, is also available through the *Script_Statistical_Analysis_Faureetal2020.nb.html* file. 
All files necessary to launch this R code without running the other scripts are also on the figshare repository associated to our article (public link available upon publication).
