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


GENOTYPE_FILE_NAME=${1} # {genotype_ch}
FREQ_FILE_NAME=${2} # {freq_ch}
MAP_FILE_NAME=${3} # {map_ch}
PEDIGREE_FILE_NAME=${4} # {pedigree_ch}
r_main_functions_conf=${5} # {r_main_functions_conf_ch}
r_check_lod_gael_conf=${6} # {r_check_lod_gael_conf_ch}
r_clean_lod_gael_conf=${7} # {r_clean_lod_gael_conf_ch}






################ SPECIAL VARIABLES DUE TO THE SLURM -> NEXTFLOW UPGRADE


RUNNING_OP="rawfile_check,cleaning,postcleaning_check,splitting,postsplitting_check,alohomora,merlin"
INPUT_DIR_PATH="."
JOB_NB=1
OUTPUT_DIR_PATH="."

R_OPT_TXT_CONF="notxt"
alias r_362_conf='module load R ; Rscript'

FILE_NAME=("GENOTYPE_FILE_NAME" "FREQ_FILE_NAME" "MAP_FILE_NAME" "PEDIGREE_FILE_NAME")
FILE_NAME_PATH=("${INPUT_DIR_PATH}" "${INPUT_DIR_PATH}" "${INPUT_DIR_PATH}" "${INPUT_DIR_PATH}") # path of the four FILE_NAME
file_name_Num=$(( ${#FILE_NAME[@]} - 1 )) # total number of elements in the array

################ END SPECIAL VARIABLES DUE TO THE SLURM -> NEXTFLOW UPGRADE






################ STARTING

echo -e "\n----CLEANING PROCESS----\n"
echo -e "SCRIPT LOCAL LANGUAGE USED: $LANG\n"

echo -e "GENOTYPE_FILE_NAME: ${GENOTYPE_FILE_NAME}\n"
echo -e "FREQ_FILE_NAME: ${FREQ_FILE_NAME}\n"
echo -e "MAP_FILE_NAME: ${MAP_FILE_NAME}\n"
echo -e "PEDIGREE_FILE_NAME: ${PEDIGREE_FILE_NAME}\n"
echo -e "r_main_functions_conf: ${r_main_functions_conf}\n"
echo -e "r_check_lod_gael_conf: ${r_check_lod_gael_conf}\n"
echo -e "r_clean_lod_gael_conf: ${r_clean_lod_gael_conf}\n"
echo -e "\n\n"


################ END STARTING








################ MAIN CODE


######## CLEANING

echo -e "\n\n################ FILE CLEANING\n\n"
if [[ $RUNNING_OP =~ cleaning ]] ; then
    # loop to recover the files from the config file
    if [[ $RUNNING_OP != rawfile_check ]] ; then # if rawfile_check, then FILE_NAME IS ALREADY SET BY THE CODE ABOVE, OTHERWISE SET  FILE_NAME
        for i in `seq 0  $file_name_Num` ; do
            # shopt -s extglob # -s unable global extention, ie the recognition of special global pattern in path, like [[:digit:]]
            # echo ${FILE_NAME[$i]}
            TEMPO1=$(echo ${FILE_NAME[$i]})
            # echo $TEMPO1
            TEMPO2="${TEMPO1}"
            # echo $TEMPO2
            TEMPO3=$(echo ${!TEMPO2[ $(( $JOB_NB - 1 )) ]}) # -1 because arrays start at 0
            # echo $TEMPO3
            export $(echo $TEMPO1)=$TEMPO3 # -1 because arrays start at 0
            # export $(echo FILE_NAME[$i])="$RAW_$(echo FILE_NAME[$i])_CONF[ $(( $JOB_NB - 1 )) ]" # -1 because arrays start at 0
            # shopt -u extglob # -u disable global extention
        done
        # the above loop is equivalent to the 4 following lines
        # GENOTYPE_FILE_NAME=${RAW_GENOTYPE_FILE_NAME_CONF[ $(( $JOB_NB - 1 )) ]} # -1 because arrays start at 0
        # FREQ_FILE_NAME=${RAW_FREQ_FILE_NAME_CONF[ $(( $JOB_NB - 1 )) ]} # -1 because arrays start at 0
        # MAP_FILE_NAME=${RAW_MAP_FILE_NAME_CONF[ $(( $JOB_NB - 1 )) ]} # -1 because arrays start at 0
        # PEDIGREE_FILE_NAME=${RAW_PEDIGREE_FILE_NAME_CONF[ $(( $JOB_NB - 1 )) ]} # -1 because arrays start at 0
        echo -e "\nTHE FOLLOWING VARIABLES ARE IMPORTED FROM THE linkage.config FILE:\n"
    else
        echo -e "\nTHE FOLLOWING VARIABLES ARE COMING FROM THE rawfile_check STEP:\n"
    fi
    echo -e "GENOTYPE_FILE_NAME: $GENOTYPE_FILE_NAME\n"
    echo -e "FREQ_FILE_NAME: $FREQ_FILE_NAME\n"
    echo -e "MAP_FILE_NAME: $MAP_FILE_NAME\n"
    echo -e "PEDIGREE_FILE_NAME: $PEDIGREE_FILE_NAME\n"

    OUTPUT_R="r_cleaning_checking_report.txt"
    if [[ -f $OUTPUT_R ]] ; then
        echo -e "\nPROBLEM: RUNNING_OP PARAMETER WITH cleaning BUT ${OUTPUT_R FILE} FILE ALREADY EXIST IN ${INPUT_DIR_NAME}\n"
        exit 1
    fi
    R_PROC="r_362_conf ${r_clean_lod_gael_conf} '$OUTPUT_DIR_PATH' $OUTPUT_R"
    for i in `seq 0  $file_name_Num` ; do # "$INPUT_DIR_NAME" is equivalent to genotyping[$i]
        INPUT=$(echo ${FILE_NAME_PATH[$i]})/$(echo ${!FILE_NAME[$i]})
        R_PROC="${R_PROC} ${INPUT}"
    done
    R_PROC="${R_PROC} $r_main_functions_conf $R_OPT_TXT_CONF" # for R analysis after the loop
    echo -e "\nTHE COMMAND USED FOR R ANALYSES IS:\n${R_PROC}\n"
    shopt -s expand_aliases # to be sure that alias are expended to the different environments
    eval "$R_PROC" # remove "" to allow regex translation
else
    echo -e "NO RAW DATA CLEANING PERFORMED\n"
fi

######## END CLEANING


######## FILE CHECKING AFTER CLEANING

echo -e "\n\n################ FILE CHECKING AFTER CLEANING\n\n"
if [[ $RUNNING_OP =~ postcleaning_check ]] ; then
    # loop to recover the files from the config file
    if [[ ! $RUNNING_OP =~ rawfile_check|cleaning ]] ; then # if rawfile_check, then FILE_NAME IS ALREADY SET BY THE CODE ABOVE, OTHERWISE SET  FILE_NAME
        for i in `seq 0  $file_name_Num` ; do
            # shopt -s extglob # -s unable global extention, ie the recognition of special global pattern in path, like [[:digit:]]
            # echo ${FILE_NAME[$i]}
            TEMPO1=$(echo ${FILE_NAME[$i]})
            # echo $TEMPO1
            TEMPO2="RAW_${TEMPO1}_CONF"
            # echo $TEMPO2
            TEMPO3=$(echo ${!TEMPO2[ $(( $JOB_NB - 1 )) ]}) # -1 because arrays start at 0
            # echo $TEMPO3
            export $(echo $TEMPO1)=$TEMPO3 # -1 because arrays start at 0
            # export $(echo FILE_NAME[$i])="$RAW_$(echo FILE_NAME[$i])_CONF[ $(( $JOB_NB - 1 )) ]" # -1 because arrays start at 0
            # shopt -u extglob # -u disable global extention
        done
        # the above loop is equivalent to the 4 following lines
        # GENOTYPE_FILE_NAME=${RAW_GENOTYPE_FILE_NAME_CONF[ $(( $JOB_NB - 1 )) ]} # -1 because arrays start at 0
        # FREQ_FILE_NAME=${RAW_FREQ_FILE_NAME_CONF[ $(( $JOB_NB - 1 )) ]} # -1 because arrays start at 0
        # MAP_FILE_NAME=${RAW_MAP_FILE_NAME_CONF[ $(( $JOB_NB - 1 )) ]} # -1 because arrays start at 0
        # PEDIGREE_FILE_NAME=${RAW_PEDIGREE_FILE_NAME_CONF[ $(( $JOB_NB - 1 )) ]} # -1 because arrays start at 0
        echo -e "\nTHE FOLLOWING VARIABLES ARE IMPORTED FROM THE linkage.config FILE:\n"
    else
        echo -e "\nTHE FOLLOWING VARIABLES ARE COMING FROM A PREVIOUS STEP:\n"
    fi
    echo -e "GENOTYPE_FILE_NAME: $GENOTYPE_FILE_NAME\n"
    echo -e "FREQ_FILE_NAME: $FREQ_FILE_NAME\n"
    echo -e "MAP_FILE_NAME: $MAP_FILE_NAME\n"
    echo -e "PEDIGREE_FILE_NAME: $PEDIGREE_FILE_NAME\n"

    OUTPUT_R="r_postcleaning_check_report.txt" ;
    OUTPUT_ERROR_R="r_postcleaning_check_error.txt" ;
    if [[ -f $OUTPUT_R || -f $OUTPUT_ERROR_R ]] ; then
        echo -e "\nPROBLEM: RUNNING_OP PARAMETER WITH postcleaning_check BUT ${OUTPUT_R FILE} OR ${OUTPUT_ERROR_R} FILE ALREADY EXIST IN ${INPUT_DIR_NAME}\n"
        exit 1
    fi
    R_PROC="r_362_conf ${r_check_lod_gael_conf} '$OUTPUT_DIR_PATH' $OUTPUT_R $OUTPUT_ERROR_R" # for R analysis after the loop
    for i in `seq 0  $file_name_Num` ; do # "$INPUT_DIR_NAME" is equivalent to genotyping[$i]
        INPUT=$(echo ${FILE_NAME_PATH[$i]})/$(echo ${!FILE_NAME[$i]})
        R_PROC="${R_PROC} ${INPUT}"
    done
    R_PROC="${R_PROC} $r_main_functions_conf postclean $R_OPT_TXT_CONF" # for R analysis after the loop
    echo -e "\nTHE COMMAND USED FOR R ANALYSES IS:\n${R_PROC}\n"
    shopt -s expand_aliases # to be sure that alias are expended to the different environments
    eval "$R_PROC" # remove "" to allow regex translation
else
    echo -e "NO FILE CHECKING AFTER CLEANING PERFORMED\n"
fi

######## END FILE CHECKING AFTER CLEANING




echo -e "\n\n################ END OF THE CLEANING PROCESS\n\n"



################ END MAIN CODE

