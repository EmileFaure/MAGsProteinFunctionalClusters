#################    This script will create a table of sequence similarity that can then be used to create an igraph object.
 
# First place yourself in the directory containing all the sequences you want to use.
cd /export/home04/users/faure/MAGs_Delmont/NON_REDUNDANT_MAGs/Prokaryotes

# Use Prodigal to detect genes and translate them to amino acids.
for file in TARA*; do prodigal -i "$file" -o "$file.coords.gbk" -a "$file.protein.faa" -d "$file.nucl.faa" ; done

# Create a protein database adapted to diamond
cat *.protein.faa >> Proka_prot.faa
diamond makedb --in Proka_prot.faa -d Proka_prot_db

# We also create a nucleotide database adapted to Salmon/FeatureCounts/etc...
cat *.nucl.faa >> Proka_nucl.faa

# Blast all proteins against themselves using diamond
diamond blastp -d Proka_prot_db.dmnd -q Proka_prot.faa -o Proka_MAGs_Diamond_out -e 1e-3 -p 30 --sensitive -f 6 qseqid qlen qstart qend sseqid slen sstart send length pident ppos score evalue bitscore
# Here we use a maximum p-value of 1e-3, and the sensitive option adapted to long reads.


# Alignments filtering
awk '$1!=$5'  Proka_MAGs_Diamond_out   >  Proka_MAGs_Diamond_out_1e-3_no-selfhits.tsv # Get rid of selfhits
# Set a threshold for percentage of identity and covering
awk -F "\t" '(($10 >= 80) && (($9 >= ($6 * .8)) || (($9 >= ($2 * .8))))) { print $0 }'  Proka_MAGs_Diamond_out_1e-3_no-selfhits.tsv  >   Proka_MAGs_Diamond_out_1e-3_no-selfhits_pident80_cov80.blastp

# Export to igraph compatible
perl diamond2graph_V2.pl --input Proka_MAGs_Diamond_out_1e-3_no-selfhits_pident80_cov80.blastp
