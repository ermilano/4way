# ddRAD pipeline for all sequence runs from P.virgatum 4way mapping project

**Elizabeth R. Milano**

**Data**  
There are 4 separate Illimina HiSeq 2x100 runs that produced the data for this project. Each run spanned 1 to 4 lanes and all indexed samples for each run were evenly spread across each lane. Each sample has a dual barcode: an index or group 6-letter code, and a 5-letter inline code. There are 48 possible inline codes and 10 index groups. Barcode information is saved in a separate file.   
Runs:  
1. parents- 4 grandparents and 2 F1s  
2. testrun- group of 16 F2s  
3. fullrun- the rest of the F2s  
4. rerun- resequencing of 3 previous runs  


**Web resources**  
Stacks Manual `http://creskolab.uoregon.edu/stacks/manual/` and tutorials.  
Stacks google group `https://groups.google.com/forum/#!forum/stacks-users`    
Original pipeline for Peterson et al. 2012 `https://github.com/brantp/rtd`  
Kyle's Github `https://github.com/kmhernan/tacc-launcher-bio/wiki`

BWA, Fastqc and Stacks are available as TACC modules on Lonestar. As of June 2014 I used the fastqc v0.10.1 and stacks v1.06 modules and a local copy of bwa v0.7.9a-r786. 

##Raw sequence preperation

###Transfer files from fourierseq to TACC

Use rsync with --progress flag. This often fails, and you will need to `CTRL-C` and re-run with --ignore-existing. You can choose to rsync files directly to corral-repl and then copy them into your working directory 


	ermilano@fourierseq:/raid/jcruz/corral/SA14034$ rsync --progress -r Project_JA14191 ermilano@lonestar.tacc.utexas.edu:/scratch/01798/ermilano/final4way/raw/

####Lonestar working dir: `$SCRATCH/final4way`
also using `$SCRATCH/old4way` `$SCRATCH/new4way/process_stacks` `$SCRATCH/all4way/` `$WORK/Pvigratum/Panicum_virgatum_V1_release/Panicum_virgatum/20130515/sequences`
####Backed-up raw files: `/corral-repl/utexas/hallii_expression/Switchgrass/Pvirgatum_4way_ddRAD/raw`

###Fastqc

	fastqc -o /work/01798/ermilano/Pvigratum/ddRAD/fastqc_raw_4way -t 12 *.gz
	
Download image files to view. More info: `http://www.bioinformatics.babraham.ac.uk/projects/fastqc/`	


###Count raw sequences and check barcodes and cutsites

* Line count:

		gunzip -c 1B_CAGATC_L001_R1_001.fastq.gz | wc -l
		or
		for i in Project_JA14191/*_R1_*; do gunzip -c "$i" | grep -Hc '^@HWI' >> counts_r1.txt; done
Divide the line count by 4 to get the number of reads per file.  R1 and R2 should be equal.  

* Check cutsite and barcodes:

		zcat 1B_CAGATC_L001_R1_001.fastq.gz | sed -n '2~4p' | cut -c 6-10 | sort | uniq -c > barcode_check.txt
		zcat 1B_CAGATC_L001_R1_001.fastq.gz | sed -n '2~4p' | cut -c 1-5 | sort | uniq -c > cutsite_check.txt
	
###Prep for stacks analysis

	cd $SCRATCH/final4way
	mkdir ./raw ./samples ./stacks

* All raw files should be in the raw folder. This can be any combination of files across libraries, lanes and runs as long as all raw files are uniquely named and there are no repeated combinatorial barcodes across samples.

* Make sure all raw files have the format: `name_index_lane_[R1/R2]_001.fastq.gz`  
ie. `pool5a_CGATGT_L006_R2_001.fastq.gz` The `_001.` is important.

* Files do not have to be compressed but you cannot have a mix of `.fastq.gz` and `.fastq`. They must all be either compressed or uncompressed.

##Process_radtags

	process_radtags -P -p /scratch/01798/ermilano/final4way/raw/ -b /scratch/01798/ermilano/final4way/barcode_final4way.txt -o /scratch/01798/ermilano/final4way/samples/ -D --disable_rad_check -q -r --inline_index --renz_1 sphI --renz_2 ecoRI -t 100 -i gzfastq
	
This took about 11 hours to process all the raw 4way files.
	
Barcode file for ddRAD is in --inline_index format. It can contain barcodes across all the libraries. However, extranious barcodes will create empty files during process_radtags. Sample file:

	CGATC	ACAGTG
	TCGAT	ACAGTG
	TGCAT	ACAGTG
	CAACC	ACAGTG
	AGCTA	GCCAAT
	ACACA	GCCAAT
	AATTA	GCCAAT
	ACGGT	GCCAAT
	ACTGG	GCCAAT
	ACTTC	GCCAAT
	ATACG	GCCAAT
	ATGAG	GCCAAT
	ATTAC	GCCAAT
	CATAT	GCCAAT
	CGAAT	GCCAAT
	CGGCT	GCCAAT
	
###Rename files
(from stacks google group `https://groups.google.com/forum/#!searchin/stacks-users/process_radtags$20output/stacks-users/uPECXmTDA8o/U_e9-YRS89wJ`)

1. Create `.csv` file with barcodes,indices,newName

		CGATC,ACAGTG,P_WBC3
		TCGAT,ACAGTG,P_DAC6
		TGCAT,ACAGTG,P_F1_12
		CAACC,ACAGTG,P_F1_30
		AGCTA,GCCAAT,A_275
		ACACA,GCCAAT,A_258
		AATTA,GCCAAT,A_243
		ACGGT,GCCAAT,V_22
		ACTGG,GCCAAT,A_240
		ACTTC,GCCAAT,A_286
		ATACG,GCCAAT,A_282
		ATGAG,GCCAAT,A_279
		ATTAC,GCCAAT,V_92
		CATAT,GCCAAT,A_207
		CGAAT,GCCAAT,A_229
		CGGCT,GCCAAT,V_14

2. Use the following script to create a 'mv' list called "matchf":
	
		#!/bin/bash		
		#script to rename stacks process_radtags output.
		#uses a .csv with inline barcode, index, new name
		#creates a paramater file with mv commands for each file
		#originally from stacks google group: 
		#`https://groups.google.com/forum/#!searchin/stacks-users/process_radtags$20output/stacks-users/uPECXmTDA8o/U_e9-YRS89wJ`

		rm nomatchf matchf
		csvF=TrachemysRADIndexBarcodesmerged.csv
		for i in `ls sample*fq`; do
			src1=`echo $i | sed -e 's/sample_//g' -e 's/-/,/g'| awk -F'.' '{print $1}'`
			src2=`echo $i | sed 's/\./|/'| awk -F'|' '{print $2}'` 

			grep $src1 $csvF > /dev/null
      		if [ $? -eq 0 ]; then
				dest1=`grep $src1 $csvF | awk -F',' '{print $3}'`
	    	    dest2="$dest1.$src2"
            	echo "mv $i $dest2" >> matchf

       		else	
				echo "$i has no match on table"
                echo "$i" >> nomatchf
      	 	fi
		done
		
3. Double check the `matchf` file to make sure names match proper combinatorial barcodes. 

		mv sample_AAGGA-TAGCTT.1.fq V_100.1.fq
		mv sample_AAGGA-TAGCTT.2.fq V_100.2.fq
		mv sample_AAGGA-TAGCTT.rem.1.fq V_100.rem.1.fq
		mv sample_AAGGA-TAGCTT.rem.2.fq V_100.rem.2.fq
		mv sample_AATTA-ACTTGA.1.fq A_257.1.fq
		mv sample_AATTA-ACTTGA.2.fq A_257.2.fq
		mv sample_AATTA-ACTTGA.rem.1.fq A_257.rem.1.fq
		mv sample_AATTA-ACTTGA.rem.2.fq A_257.rem.2.fq

4. Run `$ bash matchf` to rename files. This is quick, no need to create a launcher script and submit as a job. 

###Concatinate files
Decide which files you want to use; R1 and R2 as a pair, R1 and including the remander files, only R1, all 4 output concatinated together etc. Then create the files you want to use for mapping (or denovo). I am using all the R1 files including the remanders.

There should be a new line at the end of each file. Check with `tail`. If not, run this line.

These take a while to run. Compare files to make sure everything has completed.
	
	for x in *; do if [ -n "$(tail -c 1 <"$x")" ]; then echo >>"$x"; fi; done
	
Then concatinate the files you want to use.
All four files together:

	for dna in `find . -name "*.fq" -print | awk -F / '{print $2}' | awk -F . '{print $1}' | uniq` ; do cat ./$dna.* > cat_$dna.fq; done
		
Read 1 and remainder 1 (used for final4way refmap analysis):
	
	for dna in `find . -name "*.fq" -print | awk -F / '{print $2}' | awk -F . '{print $1}' | uniq` ; do cat ./$dna.1.fq ./$dna.rem.1.fq > cat.1_$dna.fq; done
	
Read 2 and remander 2:	
	
	for dna in `find . -name "*.fq" -print | awk -F / '{print $2}' | awk -F . '{print $1}' | uniq` ; do cat ./$dna.2.fq ./$dna.rem.2.fq > cat.2_$dna.fq; done
	
If files have not been renamed, use the following for different cat schemes:

	for dna in `find . -name "*.fq" -print | awk -F _ '{print $2}' | awk -F . '{print $1}' | uniq`; do cat [!cat]*_$dna.* > cat_$dna.fq; done
	for dna in `find . -name "*.fq" -print | awk -F _ '{print $2}' | awk -F . '{print $1}' | uniq`; do cat [!cat]*_$dna.1.fq [!cat]*_$dna.rem.1.fq > cat.1_$dna.fq; done
	for dna in `find . -name "*.fq" -print | awk -F _ '{print $2}' | awk -F . '{print $1}' | uniq`; do cat [!cat]*_$dna.2.fq [!cat]*_$dna.rem.2.fq > cat.2_$dna.fq; done

Or, if files have the same name but are in different directories:

	#!/bin/bash
	#Creates a parameter file for concatenating files with the same name across directories 

	DIRONE="/scratch/01798/ermilano/new4way/process_stacks/samples_bwa/"
	DIRTWO="/scratch/01798/ermilano/old4way/samples_bwa/"
	ODIR="/scratch/01798/ermilano/all4way/samples_bwa/"
	PARAM="cat.param"

	if [ -e $PARAM ]; then rm $PARAM; fi
	touch $PARAM

	for fil in ${DIRONE}*.fq; do
		BASE=$(basename $fil)
		NAME=${BASE%.*}
		FILEONE="${DIRONE}${NAME}.fq"
		FILETWO="${DIRTWO}${NAME}.fq"
	echo "cat ${FILEONE} ${FILETWO} > ${ODIR}${NAME}.fq" >> $PARAM
	done

Move discards to a subdirectory

	mkdir discards
	mv *.discards ./discards
	
## Mapping with BWA
If using `ref_map.pl` rather than `denovo_map.pl` each sample needs to be mapped with BWA and output into a sam file. Before mapping, the Panicum genome file needs to be indexed.

###Index reference genome
I keep the reference genome and all associated index file in $WORK

	cd $WORK/Pvigratum/Panicum_virgatum_V1_release/Panicum_virgatum/20130515/sequences
	bwa index Panicum_virgatum.main_genome.scaffolds.fasta
	
###Create a paramaters file for BWA commands

	mkdir samfiles

Script to write bwa.param	

	#!/bin/bash
	# Elizabeth R. Milano January 8, 2014
	# filename.sh - creates commands file for bwa mem
	# Notes

	INDIR="/scratch/01798/ermilano/final4way/samples/"
	OUTSAM="/scratch/01798/ermilano/final4way/samfiles/"
	SCRIPT="bwa mem"
	REF="/work/01798/ermilano/Pvigratum/Panicum_virgatum_V1_release/Panicum_virgatum/20130515/sequences/	Panicum_virgatum.main_genome.scaffolds.fasta"
	CMD="bwa.param"
	PRE=$(basename $INDIR)
	if [ -e $CMD ]; then rm $CMD; fi
	touch $CMD

	for fil in ${INDIR}cat.1_*; do
	  BASE=$(basename $fil)
	  NAME1=`echo $BASE|sed 's/cat.1_//g'`
	  NAME2=`echo $NAME1|sed 's/.fq//g'`
	  OFSAM="${OUTSAM}${NAME2}.sam"
	  echo "$SCRIPT -t 6 -M $REF $fil > $OFSAM" >> $CMD
	done

BWA needs at least 6 threads to run without memory error. Specify a wayness of 2 when submitting jobs on lonestar's normal queue. This job ran for ~2 hours with 410 BWA commands at 2way 48.

Check that `.sam` files are populated. Remove (and rerun if necessary) any files that did not work at any stage up until this point.  

##Ref_map.pl
Use `ls -x` to get a list of all the `.sam` files that are going to be in the analysis. Use a text editer to build the ref_map.pl command. Each parent is preceded by `-p` and each progeny is preceded by `-r`. Make sure the file path is correct if running from a different directory level.

	ref_map.pl -T 12 -S -b 1 -o stacks -p /samfiles/P_F1_12.sam -p /samfiles/P_F1_30.sam -r /samfiles/...
	#4.5hours, 90496 loci to genotype file
	#after genotypes command: 1879 loci to JoinMap file
	
	ref_map.pl -T 12 -S -b 1 -m 10 -n 2 -o stacks_refm10n2
	#3.5 hours, 32278 loci to genotype file
	#after genotypes command: 1140 loci to JoinMap file
	
	ref_map.pl -T 12 -S -b 1 -m 10 -n 0 -o 
	#3.5 hours, 32278 loci to genotype file
	#after genotypes command: 1140 loci to JoinMap file
	
	ref_map.pl -T 12 -S -b 1 -m 15 -n 1 -o 
	# hours, 25860 loci to genotype file
	#after genotypes command: 892 loci to JoinMap file
	
###Genotypes
One round of `genotypes` is included in the ref_map.pl wrapper. However, rerun `genptypes` to only include markers that are present in most of the individuals and output in joinmap (or other) format.

	genotypes -b 1 -P ./stacks -t CP -r 300 -c -s -o joinmap	
	
-----
***problem with original cat files. read 2 remainders were cat onto original read 1. Made new files using:***

	for dna in `find . -name "*.fq" -print | awk -F / '{print $2}' | awk -F . '{print $1}' | uniq` ; do cat ./$dna.1.fq ./$dna.rem.1.fq > all1.$dna.fq; done

New Runs -> 'newrefmap'

	ref_map.pl -T 12 -S -b 1 -m 10 -n 0 -o stacks_newrefmapm10n0  
	30315 loci to genotype file
	1085 loci to JoinMap file -> 300  
	2482 loci to JoinMap file -> 200  
	5163 loci to JoinMap file -> 100  

	ref_map.pl -T 12 -S -b 1 -m 7 -n 1 -o stacks_newrefmapm7n1
	35253 loci to genotype file  
	1321 loci to JoinMap file -> 300
	3169 loci to JoinMap file -> 200
	

###denovo_map.pl

	denovo_map.pl -o ./stacks_denov -b 1 -S -i 1 -T 12 -m 5 -n 1 -M 2 -t
	#5 hours, 26562 loci to genotype file
	#after genotypes command: 199 loci to JoinMap file
	
	denovo_map.pl -o ./stacks_denovm10n0 -b 1 -S -i 1 -T 12 -m 10 -n 0 -M 2 -t 
	#4 hours, 14916 loci to genotype file
	#after genotypes command: 81 loci to JoinMap file
	
	denovo_map.pl -o ./stacks_denovm7M1n0 -b 1 -S -i 1 -T 12 -m 7 -n 0 -M 1 -t 
	# hours, 14147 loci to genotype file
	#after genotypes command: 89 loci to JoinMap file
	
	
##Some extra notes I found

	cstacks -g -b 1 -o stacks_pop -s stacks_pop/all1.P_DAC6 -s stacks_pop/all1.P_AP13 -s stacks_pop/all1.P_VS16 -s stacks_pop/all1.P_WBC3 -p 12 -n 0 --catalog ./stacks_pop/

	populations -b 1 -P ./stacks_newrefmapm10n0/ -M popfile.txt -r 0.75 -t 12 --vcf

	sstacks -g -b 1 -c stacks_pop/batch_1 -o stacks_pop -p 12 -s stacks_pop/all1.P_F1_12 	
	
##Quality/sanity checks
Figure it out.

##Join Map
`.loc` file is ready to load into JoinMap but the following pull out useful information.  

Count the number of marker types

	cat marker_type.txt
	<abxcd>
	<efxeg>
	<hkxhk>
	<lmxll>
	<nnxnp>

	for i in `cat marker_type.txt`; do echo "$i" `grep "$i"  batch_1.genotypes_200.loc_new | wc -l`;done


Get the marker ID ranges for each mapped chromosome from the catalog file

	awk '{ print $3, $4 }' stacks_newrefmapm10n0/batch_1.catalog.tags.tsv | uniq -f 1
	
###JoinMap Processing

For this analysis I did not use any markers with significant segregation distortion. I also used default settings for Maximum liklihood analysis. 18 linkage groups were found that resembled the 18 chromosomes. 


## Create list of loci with sequences from linkage group

After mapping, I found that the linkage group associated with linkage group 3b is made mostly of unanchored contigs. I want to send this list of markers, with sequence information, to the Nobel Foundation to assist with the mapping project.

First get list of markers from the text file associated with the linkage group. One place to find this is under the 'Map(text)' tab that is generated after the marker order for the group is calculated.

	; Tue, 8 Jul 2014, 20:00:51
	; nloc=64


	group 7

	61373                   0.000  ;  781
	18270                   1.027  ;  235
	59740                   1.217  ;  768
	56790                   3.024  ;  738
	53067                   4.056  ;  670
	18082                   8.357  ;  234
	88806                   9.835  ; 1041
	57530                  12.146  ;  746
	64248                  12.844  ;  806
	64247                  13.077  ;  805
	86950                  17.926  ; 1022
	54799                  18.707  ;  702

Copy just the list of marker names into a text file. One entry per line.

	61373
	59740
	56790
	53067
	88806
	57530
	64248
	64247
	86950
	54799
	
Then grep the catalog.tags.tsv file for each marker name

	grep -wf list.test stacks_newrefmapm10n0/batch_1.catalog.tags.tsv > 3b_contigs.tsv
	
You can also double check the markers by blasting the sequence against the reference

	blastn -db Panicum_virgatum.main_genome.scaffolds.fasta -query test.fa
	
## Parental phase

See parental_phase.md  
Still working on this.

## File transfering Joinmap to MapQTL
This needs to be done before converting to rqtl. There are three files necessary:  
  
- Map file (.txt). Make this by left clicking on all the finalized groups and then use the 'Join -> Combine Maps' function in JoinMap. This will create a list of all markers and group positions. 'Edit -> Export' to File will save this properly.  

		; Tue, 22 Jul 2014, 04:05:53		; ngrp=18, nloc=1281
		group 1
		49033                   0.000  ;    1		64489                   0.550  ;    2		48865                   0.910  ;    3				group 2		10735                   0.000  ;  104
		75868                   4.275  ;  105
		11436                   5.974  ;  106

- Genotypes file (.loc). This is not the original genotypes file, the phase information is needed. Each group's data tab from the finalized order needs to be saved separately and then combined in one large file with an updated header (correct number of markers) and the same list of sample names at the end of the file.

		; Sat, 26 Jul 2014, 05:31:52
		name = group_all
		popt = CP
		nloc = 1281
		nind = 394

		45103 <abxcd> {00} (ac,ad,bc,bd) ; 1276, 111.548 cM ac ac ad ad ac ac ad ac bc ad bc ad ad bc bd bc bd
		48634 <efxeg> {10} (ee,ef,eg,fg) ; 1384, 11.669 cM ee ee fg eg ef ee fg eg eg ee fg ee fg -- eg ef eg
		44744 <nnxnp> {-1} (nn,np) ; 1269, 64.576 cM -- nn nn nn nn np np nn -- nn np nn nn nn np np nn
	
		individual names:
		all1.A_201 ; 1
		all1.A_202 ; 2
		all1.A_203 ; 3

- Quantitative file (.qua). The individuals **MUST** be in the same order as the .loc file.



## Recode JoinMap/ MapQTL genotypes to R/qtl genotypes

This feature is apparently now built into JoinMap/ MapQTL but this script will work as well.


	#!/bin/bash
	
	# Script to convert 4way JoinMap/ MapQTL genotype codes to 4way R/qtl genotype codes.
	# Elizabeth R. Milano, August 2014
	
	# Usage: joinmap_recode.sh <infile> <outfile>
	
	touch $2
	grep "<nnxnp>\t{-0}" $1 | sed 's/nn/7/g' | sed 's/np/8/g' >> $2
	grep "<nnxnp>\t{-1}" $1 | sed 's/nn/8/g' | sed 's/np/7/g' >> $2
	grep "<lmxll>\t{0-}" $1 | sed 's/ll/5/g' | sed 's/lm/6/g' >> $2
	grep "<lmxll>\t{1-}" $1 | sed 's/ll/6/g' | sed 's/lm/5/g' >> $2
	grep "<efxeg>\t{00}" $1 | sed 's/ee/1/g' | sed 's/ef/2/g' | sed 's/eg/3/g' | sed 's/fg/4/g' >> $2
	grep "<efxeg>\t{10}" $1 | sed 's/ee/2/g' | sed 's/ef/1/g' | sed 's/eg/4/g' | sed 's/fg/3/g' >> $2
	grep "<efxeg>\t{01}" $1 | sed 's/ee/3/g' | sed 's/ef/4/g' | sed 's/eg/1/g' | sed 's/fg/2/g' >> $2
	grep "<efxeg>\t{11}" $1 | sed 's/ee/4/g' | sed 's/ef/3/g' | sed 's/eg/2/g' | sed 's/fg/1/g' >> $2
	grep "<hkxhk>\t{00}" $1 | sed 's/hh/1/g' | sed 's/hk/10/g' | sed 's/kk/4/g' >> $2
	grep "<hkxhk>\t{11}" $1 | sed 's/hh/1/g' | sed 's/hk/10/g' | sed 's/kk/4/g' >> $2
	grep "<hkxhk>\t{10}" $1 | sed 's/hh/2/g' | sed 's/hk/9/g' | sed 's/kk/3/g' >> $2
	grep "<hkxhk>\t{01}" $1 | sed 's/hh/3/g' | sed 's/hk/9/g' | sed 's/kk/2/g' >> $2
	grep "<abxcd>\t{00}" $1 | sed 's/ac/1/g' | sed 's/bc/2/g' | sed 's/ad/3/g' | sed 's/bd/4/g' >> $2
	grep "<abxcd>\t{10}" $1 | sed 's/ac/2/g' | sed 's/bc/1/g' | sed 's/ad/4/g' | sed 's/bd/3/g' >> $2
	grep "<abxcd>\t{01}" $1 | sed 's/ac/3/g' | sed 's/bc/4/g' | sed 's/ad/1/g' | sed 's/bd/2/g' >> $2
	grep "<abxcd>\t{11}" $1 | sed 's/ac/4/g' | sed 's/bc/3/g' | sed 's/ad/2/g' | sed 's/bd/1/g' >> $2

	
	
	




































