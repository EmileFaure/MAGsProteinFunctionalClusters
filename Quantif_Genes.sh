#	Build the index, that will be the same for all metagenomes
# salmon index -t Proka_nucl.faa -i Proka_nucl_index --type quasi -k 31

# Download the list of samples :
# wget http://merenlab.org/data/2017_Delmont_et_al_HBDs/files/ftp-links-for-raw-data-files.txt

# Now we want a table of the form :
# Name_of_metaG	Adress_reads1	Adress_reads2
#awk '/_1/{f=$0}/_2/{print f"\t"$0}' ftp-links-for-raw-data-files.txt > temp
#awk -F'/' '{print $7"\t"$0}' temp > ftp-links-for-raw-data-files.txt

# We will make a loop on all metagenomes :

cd /media/DATA/Emile/TARA_Genomics
while read name ad1 ad2; do
	# Create a directory for the focal metagenome
	mkdir /media/DATA/Emile/TARA_Genomics/Metadata_Salmon/$name
	cd /media/DATA/Emile/TARA_Genomics/Metadata_Salmon/$name
	
	# Download the data
	wget --output-document=reads_1.fastq.gz $ad1
	wget --output-document=reads_2.fastq.gz $ad2
	gunzip reads_1.fastq.gz
	gunzip reads_2.fastq.gz

	# Now the quantification:
	salmon quant -i Proka_nucl_index -l A -1 reads_1.fastq -2 reads_2.fastq -o Genes_quant --meta --incompatPrior 0.0 --seqBias --gcBias --biasSpeedSamp 5
	
	# This will create an output file named Genes_quant, containing three folders : aux_info, libParams and logs, as well as three files : cmd_info.json, lib_format_counts.json and quant.sf
	# All the information about the quantification are in quant.sf, the rest being metadata on salmon performances.
	# In quant.sf, we replace the column name TPM (transcripts per millions) with GPM_NameOfStation for easier further analyses
	sed -i -e '1s/TPM/GPM_$name/' /media/DATA/Emile/TARA_Genomics/Metadata_Salmon/$name/Genes_quant/quant.sf
	# We then stock the quantification results with the name of the corresponding station as file name, in a different folder
	mv /media/DATA/Emile/TARA_Genomics/Metadata_Salmon/$name/Genes_quant/quant.sf /media/DATA/Emile/TARA_Genomics/Salmon_Quant_Output/$name.sf
	
	# Cleaning
	rm reads_1.fastq
	rm reads_2.fastq
	cd ..
	;
done < ftp-links-for-raw-data-files.txt

