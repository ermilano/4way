# Readme document for original 4way files  

### Elizabeth R. Milano, September 2015
=============

###Stacks
Pipeline: `ddrad_pipeline_for_all_sequence_runs_from_p.virgatum_4way_mapping_project.md`

Raw Data location: `/corral-repl/utexas/hallii_expression/Switchgrass/Pvirgatum_4way_ddRAD/raw`

Output file for JoinMap:`genotype_stacks.loc`
(this is a copy of the original file `newref200.loc` that was used in the JoinMap linkage map analysis)


------
###Phenotype data

Info:`phenotype_descriptions.doc`

Raw Data location: Juenger Lab Dropbox Folder `~/Switchgrass Data Files/4WAY Files/Austin_BFLGD Files/2014 4WCR BFLGD Files`

------
###JoinMap

JoinMap project directory backed up in two places:
`/corral-repl/utexas/hallii_expression/Switchgrass/Pvirgatum_4way_ddRAD/Liz_4way_map.zip`  
and the Juenger Lab breakroom computer `~/Desktop/Liz_4way_map/`  

See the README file in the above directory for additional information.  

There are two files that result from mapping.  
The map: `final_map.txt`  
The genotypes: `group_all.loc`

The genotype file needs to be converted into R/qtl format. This is apparently a new feature in the latest version of rqtl, however I used the following: `joinmap_recode.sh`  



------
###Linkage Group Phasing
This was really annoying. After Stacks calls genotypes using an outbred design, JoinMap phases the genotypes on each linkage group. However, it does not phase across linkage groups. Therefore each linkage group needed to be phased using <abxcd> markers or microsats to figure out the parental identity of each allele.  
I used a version of the following general pipeline: 
`parental_phase.md`  
The correct phase is listed in the following excel file. I do not recommend trying to recreate this.
`4way_chrom_phase.xlsx`

------
###R/qtl

The recoded genotype file can then be used to create the rqtl input file. I did so by removing the space formating and linebreaks. This formatting with the individuals along the columns and markers along the rows is the 'rotated- csvr' format in rqtl.