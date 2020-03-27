./exec_annotation -o /media/DATA/Emile/TARA_Genomics/Annotations_KOFamScan/KOFamScan_AllProt -f mapper-one-line /media/DATA/Emile/TARA_Genomics/Proka_prot.faa 

# Then use KeggAnnotCC.R on the output

# We have a list of kegg ID we want to map on pathways
cd /home/faure/Documents/PhD/MAGs_Project/Data_tables/AnnotKOFAM
awk '$2!="NA"{print $2}' CC2Kegg_8080 | tail -n+2 | sort | uniq > KO_list_8080
awk '{print $1"\thttp://rest.kegg.jp/get/"$1}' KO_list_8080 > temp
mv temp KO_list_8080

#!/bin/bash
kegg_retrieve() {
	mkdir /home/faure/Documents/PhD/MAGs_Project/Data_tables/AnnotKOFAM/$1
	cd /home/faure/Documents/PhD/MAGs_Project/Data_tables/AnnotKOFAM/$1

	# To obtain corresponding pathways for each KO using kegg api:
	wget --user-agent="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0" --cookies=off --tries=inf --retry-connrefused -O kegg_db_query $2
	# Did the download work ?
	if [ -s kegg_db_query ]; then
	 # Grep pathways
	 grep ' ko[0-9][0-9][0-9][0-9][0-9]' kegg_db_query > pathways
	 # Are there pathways ?
	 if [ -s pathways ]; then
	  # Format output
	  sed 's/PATHWAY /\t/g' pathways | awk -F ' ' -v KO=$1 '{print KO"\t"$1}' > path_ko
	  sed 's/PATHWAY /\t/g' pathways | awk -F ' ' '{$1=""; print $0}' | sed 's/^ //g' > path_verbose
	  paste path_ko path_verbose | column -s $'\t' -t >> /home/faure/Documents/PhD/MAGs_Project/Data_tables/AnnotKOFAM/KO_pathways_mapping_file
	 else
	 echo $1 >> /home/faure/Documents/PhD/MAGs_Project/Data_tables/AnnotKOFAM/KO_pathways_mapping_file
	 fi
	else
	echo $2 >> /home/faure/Documents/PhD/MAGs_Project/Data_tables/AnnotKOFAM/KO_pathways_mapping_file
	fi
	# Cleaning
	cd ..
	rm -rf $1
}

while read keggid adress; do
kegg_retrieve $keggid $adress
done < KO_list_8080

# To run in parallel : (kegg server seem to return more download errors in parallel) 
#while read keggid adress; do
#kegg_retrieve $keggid $adress &
#[ $( jobs | wc -l ) -ge 5 ] && wait
#done < KO_list_8080

# Which KO failed downloading
grep http KO_pathways_mapping_file > KO_list_failed
awk -F'/' '{print $5"\t"$0}' KO_list_failed > temp
mv temp KO_list_failed
sed '/http/d' KO_pathways_mapping_file > temp
mv temp KO_pathways_mapping_file
while read keggid adress; do
kegg_retrieve $keggid $adress
done < KO_list_failed

# Two KO keep failing, because they don't have an API page : K00210 & K06955. We will consider that they are not associated to any pathway.
grep http KO_pathways_mapping_file > KO_list_failed
awk -F'/' '{print $5}' KO_list_failed >> KO_pathways_mapping_file
sed '/http/d' KO_pathways_mapping_file > temp
mv temp KO_pathways_mapping_file

# Separators are double space, we change it to tabs
awk -F '  ' 'BEGIN{OFS="\t";} {print $1,$2,$3}' KO_pathways_mapping_file > temp
mv temp KO_pathways_mapping_file


