#!/bin/bash -uel
# BEWARE: this code only works with the following file names: freq, map, genotyping[$i].txt and pedfile[$i].pro
# set -e # stop the workflow if a command return something different from 0 in $?. Use set -ex to have the blocking line. It is important to know that each instruction executed send a result in $? Either 0 (true) or something else (different from 0)

################ AIM

    # Perform:
    # 'rawfile_check'        - check the 4 initial files genotyping, freq, map & pedfile
    # 'cleaning'             - clean files to be ready for alohomora
    # 'postcleaning_check'   - check the 4 files after cleaning and provide basic information
    # 'splitting'            - split the initial data files to generate the 4 files for alohomora
    # 'postsplitting_check'  - check if the 4 files after splitting and provide basic information
    # 'alohomora'            - pretreatment of the files using alohomora
    # 'merlin'               - merlin use



# echo -e "\nJOB COMMAND EXECUTED:\n$0\n" # to get the line that executes the job but does not work (gives /bioinfo/guests/gmillot/Gael_code/workflow_fastq_gael.sh)
# BEWARE: double __ is a reserved character string to deal with spaces in paths
# LANG=en_us_8859_1 # to use for the correct use of the date function
# set -e # stop the workflow if a command return something different from 0 in $?. Use set -ex to have the blocking line. It is important to know that each instruction executed send a result in $? Either 0 (true) or something else (different from 0)

################ INITIALIZATION


DIR_NAME=${1}
bit_nb=${2}



################ SPECIAL VARIABLES DUE TO THE SLURM -> NEXTFLOW UPGRADE


OUTPUT_DIR_PATH="."
# module can be used because it is a specific docker
module load pedstats/0.6.12 merlin/1.1.2 # import also minx and pedwipe. This does not work MERLIN_112_CONF=$(module purge && module load Merlin/1.1.2 && Merlin)
# activated by merlin download: pedwipe remove things in the genotype file. Do not work for X chromo
# activated by merlin download: pedstats provide stats




################ END SPECIAL VARIABLES DUE TO THE SLURM -> NEXTFLOW UPGRADE






################ STARTING

echo -e "\n\n################ PRE MERLIN PROCESS\n\n"
echo -e "SCRIPT LOCAL LANGUAGE USED: $LANG\n"
echo -e "DIR_NAME: ${DIR_NAME}\n"
echo -e "bit_nb: ${bit_nb}\n"
echo -e "\n\n"


################ END STARTING

################ MAIN CODE


######## MERLIN

DIR_NAME=$(echo ${DIR_NAME} | sed 's/c//g') # remove the c of the chromo name
CHROMO_NB=$(echo ${DIR_NAME} | sed 's/b//g') # remove the b of the chromo name
shopt -s expand_aliases # to be sure that alias are expended to the different environments

cd c${CHROMO_NB}b # to add all the outputs in the ${CHROMO_NB} folder, which can then be channeled into the merlin process
if [[ ${CHROMO_NB} == 23 ]] ; then 
    EXEC1="pedstats -d ${OUTPUT_DIR_PATH}/datain.${CHROMO_NB} -p ${OUTPUT_DIR_PATH}/pedin.${CHROMO_NB} --chromosomeX --pdf --ignoreMendelianErrors"
    #EXEC1: PEDSTATS provides a text summary of the input pedigree and data files
    # see http://csg.sph.umich.edu/abecasis/Pedstats/tour/text.html for examples
    # for http://csg.sph.umich.edu/abecasis/Pedstats/program_options.html for the description of the options
    # -d: data (file present in )
    # -p: pedigree
    # --chromosomeX: Calculate statistics for X-linked loci. In this case, males are hemizygous and carry only one chromosome. In the pedigree file they should be encoded as if they carried two identical alleles
    # --pdf: Generate charts summarizing contents of pedigree file in Adobe PDF format
    # --ignoreMendelianErrors: Calculate statistics even if Mendelian inconsistencies are present in the pedigree. The default behavior is to list inconsistencies and stop. 
    echo -e "\nPROCESS 1/1: $EXEC1\n"
    $EXEC1
else
    EXEC1="pedstats -d ${OUTPUT_DIR_PATH}/datain.${CHROMO_NB} -p ${OUTPUT_DIR_PATH}/pedin.${CHROMO_NB} --pdf --ignoreMendelianErrors"
    #EXEC1: PEDSTATS provides a text summary of the input pedigree and data files
    # see http://csg.sph.umich.edu/abecasis/Pedstats/tour/text.html for examples
    # for http://csg.sph.umich.edu/abecasis/Pedstats/program_options.html for the description of the options
    # -d: data (file present in )
    # -p: pedigree
    # --pdf: Generate charts summarizing contents of pedigree file in Adobe PDF format
    # --ignoreMendelianErrors: Calculate statistics even if Mendelian inconsistencies are present in the pedigree. The default behavior is to list inconsistencies and stop. 
    EXEC2="merlin -d ${OUTPUT_DIR_PATH}/datain.${CHROMO_NB} -p ${OUTPUT_DIR_PATH}/pedin.${CHROMO_NB} -m ${OUTPUT_DIR_PATH}/merlin_map.${CHROMO_NB} --error --quiet --bit:${bit_nb} --minutes:3600 --smallSwap --megabytes:9999"
    # EXEC2: Merlin preanalyse to detect errors 
    # see http://csg.sph.umich.edu/abecasis/MERLIN/reference.html for the description of the options
    # -d: data (file present in )
    # -p: pedigree
    # -m: genetic map
    # --error: necessary for the next EXEC2
    # --bits: size of the family (must be sup to the real number of the family?)
    # --minutes: time limit. Over it, the job crashes 
    # -- swap
    # -- megabytes: RAM
    EXEC3="pedwipe -d ${OUTPUT_DIR_PATH}/datain.${CHROMO_NB} -p ${OUTPUT_DIR_PATH}/pedin.${CHROMO_NB}"
    # EXEC3: remove the mendelian errors (which results in a smoother lod score), pedwipe is installed with merlin I believe
    # Merlin using clean data and pedigree to generate the lodscore
    # --pdf:
    # --markerNames:
    # --model: parametric model uses these values, non parametric models do not use them
    echo -e "\nPROCESS 1/3: $EXEC1\n"
    $EXEC1
    echo -e "\nPROCESS 2/3: $EXEC2\n"
    $EXEC2
    echo -e "\nPROCESS 3/3: $EXEC2\n"
    $EXEC3
fi

echo -e "\n\n################ END OF PRE MERLIN PROCESS\n\n"

################ END MAIN CODE





