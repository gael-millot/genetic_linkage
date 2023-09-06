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


CHROMO_NB=${1}
MERLIN_ANALYSE_OPTION_CONF=${2}
MERLIN_PARAM_CONF=${3}
bit_nb=${4}
# MERLIN_CHROMO_CONF=${4}
# MERLIN_LOD_CUTOFF_CONF=${5}



################ SPECIAL VARIABLES DUE TO THE SLURM -> NEXTFLOW UPGRADE


OUTPUT_DIR_PATH="."
# module can be used because it is a specific docker
module load pedstats/0.6.12 merlin/1.1.2 # import also minx and pedwipe. This does not work MERLIN_112_CONF=$(module purge && module load Merlin/1.1.2 && Merlin)
# activated by merlin download: dedicated to X chromo





################ END SPECIAL VARIABLES DUE TO THE SLURM -> NEXTFLOW UPGRADE






################ STARTING

echo -e "\n----MERLIN PROCESS----\n"
echo -e "SCRIPT LOCAL LANGUAGE USED: $LANG\n"
echo -e "CHROMO_NB: ${CHROMO_NB}\n"
echo -e "MERLIN_ANALYSE_OPTION_CONF: ${MERLIN_ANALYSE_OPTION_CONF}\n"
echo -e "MERLIN_PARAM_CONF: ${MERLIN_PARAM_CONF}\n"
echo -e "bit_nb: ${bit_nb}\n"
echo -e "\n\n"


################ END STARTING

################ MAIN CODE


######## MERLIN

echo -e "\n\n################ MERLIN\n\n"
shopt -s expand_aliases # to be sure that alias are expended to the different environments

if [[ $MERLIN_ANALYSE_OPTION_CONF == "--model" ]] ; then
    if [[ -f ${OUTPUT_DIR_PATH}/param.tbl ]] ; then
        echo -e "THE param.tbl FILE ALREADY EXISTS (AS $(cat -A ${OUTPUT_DIR_PATH}/param.tbl)) AND WILL BE OVERWRITTEN\n" # -A to show all
    fi
    echo -e $MERLIN_PARAM_CONF > ${OUTPUT_DIR_PATH}/param.tbl # create the param.tbl file required by Merlin
fi
if [[ ${CHROMO_NB} == 23 ]] ; then 
    #cd ${OUTPUT_DIR_PATH}/res${CHROMO_NB}_${JOB_ID}
    if [[ $MERLIN_ANALYSE_OPTION_CONF == "--model" ]] ; then
        MODEL_SET="${MERLIN_ANALYSE_OPTION_CONF} ${OUTPUT_DIR_PATH}/param.tbl"
    elif [[ $MERLIN_ANALYSE_OPTION_CONF == "--npl" ]] ; then
        MODEL_SET=${MERLIN_ANALYSE_OPTION_CONF}
    elif [[ $MERLIN_ANALYSE_OPTION_CONF == "--best" ]] ; then
        MODEL_SET="${MERLIN_ANALYSE_OPTION_CONF} --horizontal"
    else
        echo -e "\n### ERROR ###  PROBLEM WITH THE MERLIN_ANALYSE_OPTION_CONF PARAMETER IN THE linkage.config FILE: SHOULD BE EITHER --model OR --npl OR --best\n"
        exit 1
    fi
    EXEC1="minx -d ${OUTPUT_DIR_PATH}/c${CHROMO_NB}b/datain.${CHROMO_NB} -p ${OUTPUT_DIR_PATH}/c${CHROMO_NB}b/pedin.${CHROMO_NB} -m ${OUTPUT_DIR_PATH}/c${CHROMO_NB}b/merlin_map.${CHROMO_NB} --error --quiet --pdf --bit:${bit_nb} --minutes:3600 --smallSwap --megabytes:9999 --markerNames --perFamily --rankFamilies --information --tabulate $MODEL_SET > ${OUTPUT_DIR_PATH}/c${CHROMO_NB}b/merlin_log"
    echo -e "\nBEWARE: MENDELIAN ERRORS NOT WIPED OUT IN CHROMO 23 (CHROMO X)\n"
    echo -e "\nPROCESS 1/1: $EXEC1\n"
    $EXEC1
    if [[ $MERLIN_ANALYSE_OPTION_CONF == "--npl" ]] ; then
        sed -i -r "s/TRAIT\ \[ALL\]/TRAIT\[ALL\]/g" ${OUTPUT_DIR_PATH}/c${CHROMO_NB}b/merlin.lod
    fi
else
    if [[ $MERLIN_ANALYSE_OPTION_CONF == "--model" ]] ; then
        MODEL_SET="${MERLIN_ANALYSE_OPTION_CONF} ${OUTPUT_DIR_PATH}/param.tbl"
    elif [[ $MERLIN_ANALYSE_OPTION_CONF == "--npl" ]] ; then
        MODEL_SET=${MERLIN_ANALYSE_OPTION_CONF}
    elif [[ $MERLIN_ANALYSE_OPTION_CONF == "--best" ]] ; then
        MODEL_SET="${MERLIN_ANALYSE_OPTION_CONF} --horizontal"
    else
        echo -e "\n### ERROR ###  PROBLEM WITH THE MERLIN_ANALYSE_OPTION_CONF PARAMETER IN THE linkage.config FILE: SHOULD BE EITHER --model OR --npl OR --best\n"
        exit 1
    fi
    EXEC1="merlin -d ${OUTPUT_DIR_PATH}/c${CHROMO_NB}b/wiped.dat -p ${OUTPUT_DIR_PATH}/c${CHROMO_NB}b/wiped.ped -m ${OUTPUT_DIR_PATH}/c${CHROMO_NB}b/merlin_map.${CHROMO_NB} --error --quiet --pdf --bit:${bit_nb} --minutes:3600 --smallSwap --megabytes:9999 --markerNames --perFamily --rankFamilies --information --tabulate $MODEL_SET # > ${OUTPUT_DIR_PATH}/c${CHROMO_NB}b/merlin_log"
    # Merlin using clean data and pedigree to generate the lodscore
    # --pdf:
    # --markerNames:
    # --model: parametric model uses these values, non parametric models do not use them
    echo -e "\nPROCESS 1/1: $EXEC1\n"
    $EXEC1
    if [[ $MERLIN_ANALYSE_OPTION_CONF == "--npl" ]] ; then
        sed -i -r "s/TRAIT\ \[ALL\]/TRAIT\[ALL\]/g" ${OUTPUT_DIR_PATH}/c${CHROMO_NB}b/merlin.lod
    fi
fi


echo -e "\n\n################ END OF MERLIN PROCESS\n\n"

################ END MAIN CODE





