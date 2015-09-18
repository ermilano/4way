
# Figure out parental alleles: Decode marker phase
### 27 October 2014

## Find batch1 catalog from Stacks
### Had to rerun stacks because files were lost from scratch.  
Started with `all1.*` files output from process_radtags located in `/corral-repl/utexas/hallii_expression/Switchgrass/Pvirgatum_4way_ddRAD/raw/` This contains all 4 Illumina sequencing runs. 

#### Copied files to directory on scratch `last_stacks`

	cds
	mkdir last_stacks
	nano -w rsync.param
	cat rsync.param
	rsync --progress --ignore-existing -r /corral-repl/utexas/hallii_expression/Switchgrass/Pvirgatum_4way_ddRAD/raw/* .
	## double check path to make sure you get the specific samples you want
	
This runs for about two hours

** *Note: If starting with raw sequences, they need to be preprocessed before using BWA to map.* **

#### BWA mapping
Make sure Panicum reference has been indexed by bwa.  
Use makebwa.sh to create bwa script

	mkdir samfiles
	cat makebwa.sh
	#!/bin/bash
	# Elizabeth R. Milano June 11, 2014
	# filename.sh - creates commands file for bwa mem
	# Notes

	INDIR="/scratch/01798/ermilano/last_stacks/samples/"
	OUTSAM="/scratch/01798/ermilano/last_stacks/samfiles/"
	SCRIPT="bwa mem"
	REF="/work/01798/ermilano/Pvigratum/Panicum_virgatum_V1_release/Panicum_virgatum/20130515/sequences/Panicum_virgatum.main_genome.scaffolds.fasta"
	CMD="bwa.param"
	PRE=$(basename $INDIR)
	if [ -e $CMD ]; then rm $CMD; fi
	touch $CMD

	for fil in ${INDIR}all1.*; do
  		BASE=$(basename $fil)
  		NAME1=`echo $BASE|sed 's/all1.//g'`
  		NAME2=`echo $NAME1|sed 's/.fq//g'`
  		OFSAM="${OUTSAM}${NAME2}.sam"
  	echo "$SCRIPT -t 6 -M $REF $fil > $OFSAM" >> $CMD
	done
	head -3 bwa.param
	bwa mem -t 6 -M /work/01798/ermilano/Pvigratum/Panicum_virgatum_V1_release/Panicum_virgatum/20130515/sequences/Panicum_virgatum.main_genome.scaffolds.fasta /scratch/01798/ermilano/last_stacks/samples/all1.A_201.fq > /scratch/01798/ermilano/last_stacks/samfiles/A_201.sam
	bwa mem -t 6 -M /work/01798/ermilano/Pvigratum/Panicum_virgatum_V1_release/Panicum_virgatum/20130515/sequences/Panicum_virgatum.main_genome.scaffolds.fasta /scratch/01798/ermilano/last_stacks/samples/all1.A_202.fq > /scratch/01798/ermilano/last_stacks/samfiles/A_202.sam
	bwa mem -t 6 -M /work/01798/ermilano/Pvigratum/Panicum_virgatum_V1_release/Panicum_virgatum/20130515/sequences/Panicum_virgatum.main_genome.scaffolds.fasta /scratch/01798/ermilano/last_stacks/samples/all1.A_203.fq > /scratch/01798/ermilano/last_stacks/samfiles/A_203.sam
	
Run bwa.param 2way48 for around 2 hours.

#### Create and run ref_map.pl

	mkdir stacks
	cat ref_map.param
	ref_map.pl -T 12 -S -b 1 -m 10 -n 0 -o stacks -p ./samfiles/P_F1_12.sam -p ./samfiles/P_F1_30.sam -r ./samfiles/A_201.sam -r ./samfiles/A_202.sam -r ./samfiles/A_203.sam -r ./samfiles/A_204.sam -r ./samfiles/A_205.sam -r ./samfiles/A_206.sam -r ./samfiles/A_207.sam -r ./samfiles/A_208.sam -r ./samfiles/A_210.sam -r ./samfiles/A_211.sam -r ./samfiles/A_212.sam -r ./samfiles/A_213.sam -r ./samfiles/A_214.sam -r ./samfiles/A_215.sam -r ./samfiles/A_216.sam -r ./samfiles/A_217.sam -r ./samfiles/A_218.sam -r ./samfiles/A_219.sam -r ./samfiles/A_220.sam -r ./samfiles/A_222.sam -r ./samfiles/A_223.sam -r ./samfiles/A_224.sam -r ./samfiles/A_225.sam -r ./samfiles/A_226.sam -r ./samfiles/A_227.sam -r ./samfiles/A_228.sam -r ./samfiles/A_229.sam -r ./samfiles/A_230.sam -r ./samfiles/A_231.sam -r ./samfiles/A_232.sam -r ./samfiles/A_233.sam -r ./samfiles/A_234.sam -r ./samfiles/A_235.sam -r ./samfiles/A_236.sam -r ./samfiles/A_237.sam -r ./samfiles/A_239.sam -r ./samfiles/A_240.sam -r ./samfiles/A_241.sam -r ./samfiles/A_242.sam -r ./samfiles/A_243.sam -r ./samfiles/A_244.sam -r ./samfiles/A_246.sam -r ./samfiles/A_247.sam -r ./samfiles/A_248.sam -r ./samfiles/A_249.sam -r ./samfiles/A_250.sam -r ./samfiles/A_251.sam -r ./samfiles/A_252.sam -r ./samfiles/A_253.sam -r ./samfiles/A_254.sam -r ./samfiles/A_255.sam -r ./samfiles/A_256.sam -r ./samfiles/A_257.sam -r ./samfiles/A_258.sam -r ./samfiles/A_259.sam -r ./samfiles/A_260.sam -r ./samfiles/A_261.sam -r ./samfiles/A_262.sam -r ./samfiles/A_263.sam -r ./samfiles/A_264.sam -r ./samfiles/A_265.sam -r ./samfiles/A_266.sam -r ./samfiles/A_267.sam -r ./samfiles/A_268.sam -r ./samfiles/A_269.sam -r ./samfiles/A_270.sam -r ./samfiles/A_271.sam -r ./samfiles/A_272.sam -r ./samfiles/A_273.sam -r ./samfiles/A_274.sam -r ./samfiles/A_275.sam -r ./samfiles/A_276.sam -r ./samfiles/A_277.sam -r ./samfiles/A_278.sam -r ./samfiles/A_279.sam -r ./samfiles/A_280.sam -r ./samfiles/A_281.sam -r ./samfiles/A_282.sam -r ./samfiles/A_283.sam -r ./samfiles/A_284.sam -r ./samfiles/A_285.sam -r ./samfiles/A_286.sam -r ./samfiles/A_287.sam -r ./samfiles/A_288.sam -r ./samfiles/A_289.sam -r ./samfiles/A_290.sam -r ./samfiles/A_291.sam -r ./samfiles/A_292.sam -r ./samfiles/A_293.sam -r ./samfiles/A_294.sam -r ./samfiles/A_295.sam -r ./samfiles/A_296.sam -r ./samfiles/A_297.sam -r ./samfiles/A_298.sam -r ./samfiles/A_299.sam -r ./samfiles/A_300.sam -r ./samfiles/A_301.sam -r ./samfiles/A_302.sam -r ./samfiles/A_303.sam -r ./samfiles/A_304.sam -r ./samfiles/A_305.sam -r ./samfiles/A_306.sam -r ./samfiles/A_307.sam -r ./samfiles/A_308.sam -r ./samfiles/A_309.sam -r ./samfiles/A_310.sam -r ./samfiles/A_311.sam -r ./samfiles/A_312.sam -r ./samfiles/A_313.sam -r ./samfiles/A_314.sam -r ./samfiles/A_315.sam -r ./samfiles/A_316.sam -r ./samfiles/A_317.sam -r ./samfiles/A_318.sam -r ./samfiles/A_319.sam -r ./samfiles/A_320.sam -r ./samfiles/A_321.sam -r ./samfiles/A_322.sam -r ./samfiles/A_323.sam -r ./samfiles/A_324.sam -r ./samfiles/A_325.sam -r ./samfiles/A_326.sam -r ./samfiles/A_327.sam -r ./samfiles/A_328.sam -r ./samfiles/A_329.sam -r ./samfiles/A_330.sam -r ./samfiles/A_331.sam -r ./samfiles/A_332.sam -r ./samfiles/A_333.sam -r ./samfiles/A_334.sam -r ./samfiles/A_335.sam -r ./samfiles/A_336.sam -r ./samfiles/A_337.sam -r ./samfiles/A_338.sam -r ./samfiles/A_339.sam -r ./samfiles/A_340.sam -r ./samfiles/A_341.sam -r ./samfiles/A_342.sam -r ./samfiles/A_343.sam -r ./samfiles/A_344.sam -r ./samfiles/A_345.sam -r ./samfiles/A_346.sam -r ./samfiles/A_347.sam -r ./samfiles/A_348.sam -r ./samfiles/A_349.sam -r ./samfiles/A_350.sam -r ./samfiles/A_351.sam -r ./samfiles/A_352.sam -r ./samfiles/A_353.sam -r ./samfiles/A_354.sam -r ./samfiles/A_355.sam -r ./samfiles/A_356.sam -r ./samfiles/A_357.sam -r ./samfiles/A_358.sam -r ./samfiles/A_359.sam -r ./samfiles/A_360.sam -r ./samfiles/A_361.sam -r ./samfiles/A_362.sam -r ./samfiles/A_363.sam -r ./samfiles/A_364.sam -r ./samfiles/A_365.sam -r ./samfiles/A_366.sam -r ./samfiles/A_367.sam -r ./samfiles/A_368.sam -r ./samfiles/A_369.sam -r ./samfiles/A_370.sam -r ./samfiles/A_371.sam -r ./samfiles/A_372.sam -r ./samfiles/A_373.sam -r ./samfiles/A_374.sam -r ./samfiles/A_375.sam -r ./samfiles/A_377.sam -r ./samfiles/A_378.sam -r ./samfiles/A_379.sam -r ./samfiles/A_380.sam -r ./samfiles/A_381.sam -r ./samfiles/A_382.sam -r ./samfiles/A_384.sam -r ./samfiles/A_385.sam -r ./samfiles/A_386.sam -r ./samfiles/A_387.sam -r ./samfiles/A_388.sam -r ./samfiles/A_389.sam -r ./samfiles/A_390.sam -r ./samfiles/A_391.sam -r ./samfiles/A_392.sam -r ./samfiles/A_393.sam -r ./samfiles/A_394.sam -r ./samfiles/A_395.sam -r ./samfiles/A_396.sam -r ./samfiles/A_397.sam -r ./samfiles/A_398.sam -r ./samfiles/A_399.sam -r ./samfiles/A_400.sam -r ./samfiles/A_402.sam -r ./samfiles/A_403.sam -r ./samfiles/V_100.sam -r ./samfiles/V_101.sam -r ./samfiles/V_102.sam -r ./samfiles/V_103.sam -r ./samfiles/V_104.sam -r ./samfiles/V_105.sam -r ./samfiles/V_106.sam -r ./samfiles/V_107.sam -r ./samfiles/V_108.sam -r ./samfiles/V_109.sam -r ./samfiles/V_10.sam -r ./samfiles/V_110.sam -r ./samfiles/V_111.sam -r ./samfiles/V_112.sam -r ./samfiles/V_113.sam -r ./samfiles/V_114.sam -r ./samfiles/V_115.sam -r ./samfiles/V_116.sam -r ./samfiles/V_118.sam -r ./samfiles/V_119.sam -r ./samfiles/V_11.sam -r ./samfiles/V_120.sam -r ./samfiles/V_121.sam -r ./samfiles/V_122.sam -r ./samfiles/V_123.sam -r ./samfiles/V_124.sam -r ./samfiles/V_125.sam -r ./samfiles/V_126.sam -r ./samfiles/V_127.sam -r ./samfiles/V_128.sam -r ./samfiles/V_129.sam -r ./samfiles/V_12.sam -r ./samfiles/V_130.sam -r ./samfiles/V_131.sam -r ./samfiles/V_132.sam -r ./samfiles/V_133.sam -r ./samfiles/V_134.sam -r ./samfiles/V_135.sam -r ./samfiles/V_136.sam -r ./samfiles/V_137.sam -r ./samfiles/V_138.sam -r ./samfiles/V_139.sam -r ./samfiles/V_13.sam -r ./samfiles/V_140.sam -r ./samfiles/V_141.sam -r ./samfiles/V_142.sam -r ./samfiles/V_143.sam -r ./samfiles/V_144.sam -r ./samfiles/V_145.sam -r ./samfiles/V_147.sam -r ./samfiles/V_148.sam -r ./samfiles/V_149.sam -r ./samfiles/V_14.sam -r ./samfiles/V_150.sam -r ./samfiles/V_151.sam -r ./samfiles/V_152.sam -r ./samfiles/V_153.sam -r ./samfiles/V_154.sam -r ./samfiles/V_155.sam -r ./samfiles/V_156.sam -r ./samfiles/V_157.sam -r ./samfiles/V_158.sam -r ./samfiles/V_159.sam -r ./samfiles/V_15.sam -r ./samfiles/V_160.sam -r ./samfiles/V_161.sam -r ./samfiles/V_162.sam -r ./samfiles/V_163.sam -r ./samfiles/V_164.sam -r ./samfiles/V_165.sam -r ./samfiles/V_166.sam -r ./samfiles/V_167.sam -r ./samfiles/V_168.sam -r ./samfiles/V_169.sam -r ./samfiles/V_16.sam -r ./samfiles/V_170.sam -r ./samfiles/V_171.sam -r ./samfiles/V_172.sam -r ./samfiles/V_173.sam -r ./samfiles/V_174.sam -r ./samfiles/V_175.sam -r ./samfiles/V_176.sam -r ./samfiles/V_177.sam -r ./samfiles/V_178.sam -r ./samfiles/V_179.sam -r ./samfiles/V_17.sam -r ./samfiles/V_180.sam -r ./samfiles/V_181.sam -r ./samfiles/V_182.sam -r ./samfiles/V_183.sam -r ./samfiles/V_184.sam -r ./samfiles/V_185.sam -r ./samfiles/V_186.sam -r ./samfiles/V_187.sam -r ./samfiles/V_188.sam -r ./samfiles/V_189.sam -r ./samfiles/V_18.sam -r ./samfiles/V_190.sam -r ./samfiles/V_191.sam -r ./samfiles/V_192.sam -r ./samfiles/V_193.sam -r ./samfiles/V_194.sam -r ./samfiles/V_195.sam -r ./samfiles/V_196.sam -r ./samfiles/V_197.sam -r ./samfiles/V_198.sam -r ./samfiles/V_199.sam -r ./samfiles/V_19.sam -r ./samfiles/V_1.sam -r ./samfiles/V_200.sam -r ./samfiles/V_20.sam -r ./samfiles/V_21.sam -r ./samfiles/V_22.sam -r ./samfiles/V_23.sam -r ./samfiles/V_24.sam -r ./samfiles/V_25.sam -r ./samfiles/V_26.sam -r ./samfiles/V_27.sam -r ./samfiles/V_28.sam -r ./samfiles/V_29.sam -r ./samfiles/V_2.sam -r ./samfiles/V_30.sam -r ./samfiles/V_31.sam -r ./samfiles/V_32.sam -r ./samfiles/V_33.sam -r ./samfiles/V_34.sam -r ./samfiles/V_35.sam -r ./samfiles/V_36.sam -r ./samfiles/V_37.sam -r ./samfiles/V_38.sam -r ./samfiles/V_3.sam -r ./samfiles/V_401.sam -r ./samfiles/V_40.sam -r ./samfiles/V_41.sam -r ./samfiles/V_42.sam -r ./samfiles/V_43.sam -r ./samfiles/V_44.sam -r ./samfiles/V_45.sam -r ./samfiles/V_46.sam -r ./samfiles/V_47.sam -r ./samfiles/V_48.sam -r ./samfiles/V_49.sam -r ./samfiles/V_4.sam -r ./samfiles/V_50.sam -r ./samfiles/V_51.sam -r ./samfiles/V_52.sam -r ./samfiles/V_53.sam -r ./samfiles/V_54.sam -r ./samfiles/V_55.sam -r ./samfiles/V_56.sam -r ./samfiles/V_57.sam -r ./samfiles/V_58.sam -r ./samfiles/V_59.sam -r ./samfiles/V_5.sam -r ./samfiles/V_60.sam -r ./samfiles/V_61.sam -r ./samfiles/V_62.sam -r ./samfiles/V_63.sam -r ./samfiles/V_64.sam -r ./samfiles/V_65.sam -r ./samfiles/V_66.sam -r ./samfiles/V_67.sam -r ./samfiles/V_68.sam -r ./samfiles/V_69.sam -r ./samfiles/V_6.sam -r ./samfiles/V_70.sam -r ./samfiles/V_71.sam -r ./samfiles/V_72.sam -r ./samfiles/V_73.sam -r ./samfiles/V_74.sam -r ./samfiles/V_75.sam -r ./samfiles/V_76.sam -r ./samfiles/V_77.sam -r ./samfiles/V_78.sam -r ./samfiles/V_79.sam -r ./samfiles/V_7.sam -r ./samfiles/V_80.sam -r ./samfiles/V_81.sam -r ./samfiles/V_82.sam -r ./samfiles/V_83.sam -r ./samfiles/V_84.sam -r ./samfiles/V_85.sam -r ./samfiles/V_86.sam -r ./samfiles/V_87.sam -r ./samfiles/V_88.sam -r ./samfiles/V_89.sam -r ./samfiles/V_8.sam -r ./samfiles/V_90.sam -r ./samfiles/V_91.sam -r ./samfiles/V_92.sam -r ./samfiles/V_93.sam -r ./samfiles/V_94.sam -r ./samfiles/V_95.sam -r ./samfiles/V_96.sam -r ./samfiles/V_97.sam -r ./samfiles/V_98.sam -r ./samfiles/V_99.sam -r ./samfiles/V_9.sam

Run ref_map.param 1way12 for ~7 hours
	
#### Create reduced joinmap file with markers that have at least 50% coverage
	
	cat genotype.param
	genotypes -b 1 -P ./stacks -t CP -r 200 -c -s -o joinmap
	
Run 1way 12 for ~30 minutes.  
Final output should be `stacks/batch_1.genotypes_200.loc`

#### Compare to previous joinmap files

Count the number of marker types

	for i in `cat marker_type.txt`; do echo "$i" `grep "$i"  batch_1.genotypes_200.loc_new | wc -l`;done
	
Get the marker ID ranges for each mapped chromosome from the catalog file

	awk '{ print $3, $4 }' stacks/batch_1.catalog.tags.tsv | uniq -f 1 | grep -B 3 -A 3 -v 'contig'
	
### Genotype parents against catalog

	cat pstacks.param 
	pstacks -t sam -f ./samfiles/P_AP13.sam -o stacks -i 397 -p 3 -m 10
	pstacks -t sam -f ./samfiles/P_DAC6.sam -o stacks -i 398 -p 3 -m 10
	pstacks -t sam -f ./samfiles/P_VS16.sam -o stacks -i 399 -p 3 -m 10
	pstacks -t sam -f ./samfiles/P_WBC3.sam -o stacks -i 400 -p 3 -m 10

	cat sstacks.param 
	sstacks -g -b 1 -c stacks/batch_1 -s stacks/P_AP13 -o stacks -p 3
	sstacks -g -b 1 -c stacks/batch_1 -s stacks/P_DAC6 -o stacks -p 3
	sstacks -g -b 1 -c stacks/batch_1 -s stacks/P_VS16 -o stacks -p 3
	sstacks -g -b 1 -c stacks/batch_1 -s stacks/P_WBC3 -o stacks -p 3
	
	mkdir parents_stacks
	cp stacks/P* parents_stacks/
	cp stacks/batch_1.catalog* parents_stacks/
	genotypes -b 1 -P ./stacks_parents -t CP -c -s -o joinmap
	
	
### Choose phased markers from joinmap

Selected list of <abxcd> markers with no segregation distortion from the original joinmap file `newreftest2`  
Saved just the marker IDs to a file with a `^` in front of each number.  Then grep these from the parent genotypes outfile.

	grep 'abxcd' batch_1.genotypes_1.loc | grep -f ../abcd.txt

This will be a list of <abxcd> markers present in both the parents and the kids.  
Save the marker IDs again in a new file with two spaces before the number and one space after the number. Then remove the first two columns from the batch1.cataog.tags.tsv file and grep it for the marker IDs.  

	awk '{$1=$2=""; print $0}' stacks/batch_1.catalog.tags.tsv > batch_1.catalog.tags.new
	grep -f less_abcd.txt batch_1.catalog.tags.new | awk '{print $2"\t"$3}' > positions.txt
	
Can save the output form `grep -f less_abcd.txt batch_1.catalog.tags.new` to match marker ID with chromosome location.
	
This will give the chromosome positions for each of the abxcd markers.  
Copy the chromosome positions to a new file and grep the individual parent tags files for each position. Probably need to add a \t inbetween the chromID and BPstart.

	
	cat positions.txt 
	Chr01a_provisional_V1	29672668
	Chr02a_provisional_V1	59686530
	Chr02b_provisional_V1	42971053
	Chr03a_provisional_V1	11005357
	Chr04a_provisional_V1	9865290
	Chr05a_provisional_V1	13921479
	Chr05a_provisional_V1	55486743
	Chr06a_provisional_V1	17397163
	Chr06a_provisional_V1	31535611
	Chr06b_provisional_V1	11428742
	Chr06b_provisional_V1	35438919
	Chr08a_provisional_V1	22899460
	Chr08a_provisional_V1	24141675
	Chr09a_provisional_V1	70785235
	Chr09b_provisional_V1	32950652
	Chr09b_provisional_V1	35488445
	Chr09b_provisional_V1	41303567
	conig13304	8631
	conig14889	9241
	conig250350	407

	grep -nf positions.txt parents_stacks/P_*.tags.tsv > parentalleles
	
Then compare the consensus sequences across parents.  
	
	grep -P "`sed -n '1p' positions.txt`" parentalleles 
	
Now find those markers in several of the F2s with different alleles. Make sure to have the key for marker ID and chromosome location form `grep -f less_abcd.txt batch_1.catalog.tags.new`.  Then look up the marker in a phased file from joinmap.  For now these files are kept here `~/Dropbox/final4way_files/joinmap_files/group_loc_files/`

	head group_1.loc
	
	; Sat, 26 Jul 2014, 05:27:58

	name = group_1
	popt = CP
	nloc = 103
	nind = 394

	48180 <abxcd> {00} (ac,ad,bc,bd) ; 1362, 17.734 cM
 	 bc bc ad bd ac  bc -- bd bd bc  ad -- -- -- --  ac -- ad ac -- .......
 	 
 The first individuals genotyped are:
 
 	all1.A_201 ; 1  
	all1.A_202 ; 2 
	all1.A_203 ; 3
	all1.A_204 ; 4
	all1.A_205 ; 5
	all1.A_206 ; 6
	all1.A_207 ; 7
	all1.A_208 ; 8
	all1.A_210 ; 9
	all1.A_211 ; 10
	all1.A_212 ; 11

Now grep the sequence from their tag files

	grep -P "`sed -n '1p' positions.txt`" stacks/A_20?.tags.tsv 
