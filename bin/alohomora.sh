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



################ INITIALIZATION


GROUP_NAME=${1}
GENOTYPE_FILE_NAME=${2} # {genotype_ch}
FREQ_FILE_NAME=${3} # {freq_ch}
MAP_FILE_NAME=${4} # {map_ch}
PEDIGREE_FILE_NAME=${5} # {pedigree_ch}
r_main_functions_conf=${6} # {r_main_functions_conf_ch}
r_check_lod_gael_conf=${7} # {r_check_lod_gael_conf_ch}
alohomora_bch_conf=${8} # {alohomora_bch_conf_ch}
SPLIT_IND_CONF=${9} # IID_IN_GROUP_CONF


# echo -e "\nJOB COMMAND EXECUTED:\n$0\n" # to get the line that executes the job but does not work (gives /bioinfo/guests/gmillot/Gael_code/workflow_fastq_gael.sh)
# BEWARE: double __ is a reserved character string to deal with spaces in paths
# LANG=en_us_8859_1 # to use for the correct use of the date function
# set -e # stop the workflow if a command return something different from 0 in $?. Use set -ex to have the blocking line. It is important to know that each instruction executed send a result in $? Either 0 (true) or something else (different from 0)

################ SPECIAL VARIABLES DUE TO THE SLURM -> NEXTFLOW UPGRADE

RUNNING_OP="rawfile_check,cleaning,postcleaning_check,splitting,postsplitting_check,alohomora,merlin"
OUTPUT_DIR_PATH="."
# alias alohomora_036_conf='module load genehunter/1.3 pedstats/0.6.12 merlin/1.1.2 plink/1.90a pedcheck/1.1 gnuplot simwalk2 alohomora/v0.36 ; alohomora'
module load R # module can be used because it is a specific docker
module load genehunter/2.1_r2 pedstats/0.6.12 merlin/1.1.2 plink/1.90b6.16 pedcheck/1.1 gnuplot/5.2.8 simwalk2/2.91 alohomora/v0.36 # module can be used because it is a specific docker
R_OPT_TXT_CONF="notxt"

TEMPO_IND=$(echo ${SPLIT_IND_CONF} | sed 's/ /,/g') # space replacement by comma


################ END SPECIAL VARIABLES DUE TO THE SLURM -> NEXTFLOW UPGRADE

################ FUNCTIONS



################ STARTING TIME JOB & JOB ID




################ COMMAND DEFINITION



######## FILE CHECKING AFTER SPLITTING


echo -e "\n\n################ FILE CHECKING AFTER SPLITTING\n\n"
if [[ $RUNNING_OP =~ postsplitting_check ]] ; then
    # loop to recover the files from the config file
        echo -e "\n######## ${GROUP_NAME}\n"

        echo -e "SCRIPT LOCAL LANGUAGE USED: $LANG\n"
        echo -e "GROUP_NAME: ${GROUP_NAME}\n"
        echo -e "GENOTYPE_FILE_NAME: ${GENOTYPE_FILE_NAME}\n"
        echo -e "FREQ_FILE_NAME: ${FREQ_FILE_NAME}\n"
        echo -e "MAP_FILE_NAME: ${MAP_FILE_NAME}\n"
        echo -e "PEDIGREE_FILE_NAME: ${PEDIGREE_FILE_NAME}\n"
        echo -e "r_main_functions_conf: ${r_main_functions_conf}\n"
        echo -e "r_check_lod_gael_conf: ${r_check_lod_gael_conf}\n"
        echo -e "alohomora_bch_conf: ${alohomora_bch_conf}\n"
        echo -e "SPLIT_IND_CONF: ${SPLIT_IND_CONF}\n"
        echo -e "\n\n"

        OUTPUT_R="r_postsplitting_check_report_${GROUP_NAME}.txt" ;
        OUTPUT_ERROR_R="r_postsplitting_check_error_${GROUP_NAME}.txt" ;
        R_PROC="Rscript ${r_check_lod_gael_conf} $OUTPUT_DIR_PATH $OUTPUT_R $OUTPUT_ERROR_R ${GROUP_NAME}/${GENOTYPE_FILE_NAME} ${GROUP_NAME}/${FREQ_FILE_NAME} ${GROUP_NAME}/${MAP_FILE_NAME} ${GROUP_NAME}/${PEDIGREE_FILE_NAME}" # for R analysis after the loop
        R_PROC="${R_PROC} $r_main_functions_conf postsplit $TEMPO_IND $R_OPT_TXT_CONF" # for R analysis after the loop
        echo -e "\nTHE COMMAND USED FOR R ANALYSES IS:\n${R_PROC}\n"
        shopt -s expand_aliases # to be sure that alias are expended to the different environments
        $R_PROC
else
    echo -e "NO FILE CHECKING AFTER CLEANING PERFORMED\n"
fi

######## END FILE CHECKING AFTER SPLITTING


######## ALOHOMORA

echo -e "\n\n################ ALOHOMORA\n\n"
if [[ $RUNNING_OP =~ alohomora ]] ; then
    TEMPO_OUTPUT_PATH=${PWD}/${GROUP_NAME} # PWD because alohomora needs absolute path
    echo -e "\n######## GROUP ${GROUP_NAME}\n"
    ALOHOMORA_PROC="alohomora --nogui -b "${alohomora_bch_conf}" -p ${TEMPO_OUTPUT_PATH}/${PEDIGREE_FILE_NAME} -g ${TEMPO_OUTPUT_PATH}/${GENOTYPE_FILE_NAME}"
    echo -e "\nTHE COMMAND USED FOR ALOHOMORA ANALYSIS IS:\n${ALOHOMORA_PROC}\n"
    shopt -s expand_aliases # to be sure that alias are expended to the different environments
    $ALOHOMORA_PROC



    for i in "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" ; do # I left "" to set the numbers as character strings
        CHROMO_NB="c$i"
        if [[ ! -d ${TEMPO_OUTPUT_PATH}/merlin/$CHROMO_NB ]] ; then
            echo -e "\n======== ERROR: THE ${TEMPO_OUTPUT_PATH}/merlin/$CHROMO_NB DIRECTORY IS MISSING"
            exit 1
        fi
        if [[ ! -f ${TEMPO_OUTPUT_PATH}/merlin/$CHROMO_NB/datain.${i} || ! -f ${TEMPO_OUTPUT_PATH}/merlin/$CHROMO_NB/map.${i} || ! -f ${TEMPO_OUTPUT_PATH}/merlin/$CHROMO_NB/merlin_map.${i} || ! -f ${TEMPO_OUTPUT_PATH}/merlin/$CHROMO_NB/pedin.${i} ]] ; then
            echo -e "\n======== ERROR: ONE OF THIS FILE AT LEAST IS MISSING:"
            echo -e "datain.${i}: ${TEMPO_OUTPUT_PATH}/merlin/$CHROMO_NB/datain.${i}"
            echo -e "map.${i}: ${TEMPO_OUTPUT_PATH}/merlin/$CHROMO_NB/map.${i}"
            echo -e "merlin_map.${i}: ${TEMPO_OUTPUT_PATH}/merlin/$CHROMO_NB/merlin_map.${i}"
            echo -e "pedin.${i}: ${TEMPO_OUTPUT_PATH}/merlin/$CHROMO_NB/pedin.${i}\n"
            exit 1
        fi
    done










else
    echo -e "NO PREPROCESSING USING ALOHOMORA\n"
fi







################ END MAIN CODE

echo -e "\n\n################ END OF THE ALOHOMORA PROCESS\n\n"