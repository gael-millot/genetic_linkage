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



FULL_LOD_FILE_NAME=${1}
r_custom_graph_lod_gael_conf=${2}
r_main_functions_conf_ch=${3}
human_chr_info_ch=${4}
MERLIN_ANALYSE_OPTION_CONF=${5}
MERLIN_PARAM_CONF=${6}
MERLIN_DISPLAY_CHROMO_CONF=${7}
MERLIN_LOD_CUTOFF_CONF=${8}



################ SPECIAL VARIABLES DUE TO THE SLURM -> NEXTFLOW UPGRADE


OUTPUT_DIR_PATH="."
# JOB_ID="1" # probably remove all the JOB_ID in the code
R_OPT_TXT_CONF="notxt"





################ END SPECIAL VARIABLES DUE TO THE SLURM -> NEXTFLOW UPGRADE




################ STARTING

echo -e "\n----CUSTOM GRAPH PROCESS----\n"
echo -e "FULL_LOD_FILE_NAME: ${FULL_LOD_FILE_NAME}\n"
echo -e "r_custom_graph_lod_gael_conf: ${r_custom_graph_lod_gael_conf}\n"
echo -e "r_main_functions_conf_ch: ${r_main_functions_conf_ch}\n"
echo -e "human_chr_info_ch: ${human_chr_info_ch}\n"
echo -e "MERLIN_ANALYSE_OPTION_CONF: ${MERLIN_ANALYSE_OPTION_CONF}\n"
echo -e "MERLIN_PARAM_CONF: ${MERLIN_PARAM_CONF}\n"
echo -e "MERLIN_DISPLAY_CHROMO_CONF: ${MERLIN_DISPLAY_CHROMO_CONF}\n"
echo -e "MERLIN_LOD_CUTOFF_CONF: ${MERLIN_LOD_CUTOFF_CONF}\n"
echo -e "\n\n"


################ END STARTING

################ MAIN CODE

echo -e "\n\n################ CUSTOM GRAPH\n\n"


if [[ "$MERLIN_ANALYSE_OPTION_CONF" == "--best" ]] ; then
    echo -e "HAPLOTYPE INFERENCE (ANALYSE IS: $MERLIN_ANALYSE_OPTION_CONF)\n"
else
    if [[ "$MERLIN_ANALYSE_OPTION_CONF" == "--model" ]] ; then
        MODEL_PRINT="MODEL: ${MERLIN_ANALYSE_OPTION_CONF} | $(echo $MERLIN_PARAM_CONF | sed 's/\t/ /g')"
    elif [[ "$MERLIN_ANALYSE_OPTION_CONF" == "--npl" || "$MERLIN_ANALYSE_OPTION_CONF" == "--npl --exp" ]]; then
        MODEL_PRINT="MODEL: ${MERLIN_ANALYSE_OPTION_CONF}"
        echo -e "IN THE merlin.lod FILE, ALL THE TRAIT [ALL] HAVE BEEN REPLACED BY TRAIT[ALL]\n"
    else
        echo -e "\n### ERROR ###  PROBLEM WITH THE MERLIN_ANALYSE_OPTION_CONF PARAMETER IN THE linkage.config FILE: SHOULD BE EITHER --model OR --npl\n"
        exit 1
    fi

    MODEL_PRINT="$MODEL_PRINT | $MERLIN_DISPLAY_CHROMO_CONF | $MERLIN_LOD_CUTOFF_CONF"

    # R_PROC="Rscript" because the docker is r_ext, not bash. With bash, we would have to use "module load R ; Rscript"
    MERLIN_DISPLAY_CHROMO_CONF=$(echo $MERLIN_DISPLAY_CHROMO_CONF | sed -e 's/ /_;_/g')
    MODEL_PRINT=$(echo $MODEL_PRINT | sed -e 's/ /_;_/g')
    MERLIN_LOD_CUTOFF_CONF=$(echo $MERLIN_LOD_CUTOFF_CONF | sed -e 's/ /_;_/g')
    R_PROC="Rscript \
        ${r_custom_graph_lod_gael_conf} \
        ${r_main_functions_conf} \
        ${human_chr_info_ch} \
        ${FULL_LOD_FILE_NAME} \
        ${MERLIN_DISPLAY_CHROMO_CONF} \
        ${MERLIN_LOD_CUTOFF_CONF} \
        $OUTPUT_DIR_PATH \
        $MODEL_PRINT
    "
    echo -e "\nTHE COMMAND USED FOR R ANALYSES IS:\n${R_PROC}\n"
    shopt -s expand_aliases # to be sure that alias are expended to the different environments
    $R_PROC
fi

echo -e "\n\n################ END OF CUSTOM GRAPH\n\n"

################ END MAIN CODE





