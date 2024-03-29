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
SPLIT_IND_CONF=${5} # IID_IN_GROUP_CONF



################ SPECIAL VARIABLES DUE TO THE SLURM -> NEXTFLOW UPGRADE



INPUT_DIR_PATH="."
JOB_NB=1
OUTPUT_DIR_PATH="."

SPLIT_OUTPUT_GROUP_NAME_CONF="Group"
SPLIT_OUTPUT_GENOTYPE_FILE_NAME_CONF="genotyping"
SPLIT_OUTPUT_FREQ_FILE_NAME_CONF="freq"
SPLIT_OUTPUT_MAP_FILE_NAME_CONF="map"
SPLIT_OUTPUT_PEDIGREE_FILE_NAME_CONF="pedfile.pro"

FILE_NAME=("GENOTYPE_FILE_NAME" "FREQ_FILE_NAME" "MAP_FILE_NAME" "PEDIGREE_FILE_NAME")
FILE_NAME_PATH=("${INPUT_DIR_PATH}" "${INPUT_DIR_PATH}" "${INPUT_DIR_PATH}" "${INPUT_DIR_PATH}") # path of the four FILE_NAME
file_name_Num=$(( ${#FILE_NAME[@]} - 1 )) # total number of elements in the array

SPLIT_IND_CONF=($SPLIT_IND_CONF)
conf_split_output_group_name_Num=$(( ${#SPLIT_IND_CONF[@]} - 1 )) # total number of elements in the array



################ END SPECIAL VARIABLES DUE TO THE SLURM -> NEXTFLOW UPGRADE






################ STARTING

echo -e "\n----SPLITTING PROCESS----\n"
echo -e "SCRIPT LOCAL LANGUAGE USED: $LANG\n"

echo -e "GENOTYPE_FILE_NAME: ${GENOTYPE_FILE_NAME}\n"
echo -e "FREQ_FILE_NAME: ${FREQ_FILE_NAME}\n"
echo -e "MAP_FILE_NAME: ${MAP_FILE_NAME}\n"
echo -e "PEDIGREE_FILE_NAME: ${PEDIGREE_FILE_NAME}\n"
echo -e "SPLIT_OUTPUT_GROUP_NAME_CONF: ${SPLIT_OUTPUT_GROUP_NAME_CONF}\n"
echo -e "SPLIT_IND_CONF: ${SPLIT_IND_CONF[@]}\n"
echo -e "\n\n"



################ END STARTING




################ CHECK







################ END CHECK








################ MAIN CODE




######## DATA SPLITTING

echo -e "\n\n################ DATA SPLITTING\n\n"

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




for ((i=0; i<=$conf_split_output_group_name_Num; i++)); do
    NUMBER=$((i + 1))
    mkdir $OUTPUT_DIR_PATH/${SPLIT_OUTPUT_GROUP_NAME_CONF}${NUMBER}
    # recovering the patient numbers -> TEMPO_IND
    TEMPO_IND=$(echo ${SPLIT_IND_CONF[$i]} | sed 's/,/\|/g') # comma replacement by |
    # echo "$TEMPO_IND"
    # cat $TEMPO_IND > $OUTPUT_DIR_PATH/${SPLIT_OUTPUT_GROUP_NAME_CONF[$i]}/tempo # save the initial file
    # awk -F "\t" 'FNR==NR{a[$1] ; next} $2 in a' $OUTPUT_DIR_PATH/${SPLIT_OUTPUT_GROUP_NAME_CONF[$i]}/tempo $INPUT_DIR_PATH/$PEDIGREE_FILE_NAME > $OUTPUT_DIR_PATH/${SPLIT_OUTPUT_GROUP_NAME_CONF[$i]}/${SPLIT_OUTPUT_PEDIGREE_FILE_NAME_CONF[$i]}# see protocol 44
    # splitting the pedigree file
    awk -v var1=$TEMPO_IND 'BEGIN{FS="\t" ; OFS="\t" ; ORS="\n"}{if ( $2 ~ "^(" var1 ")$" ) print $0 }' $INPUT_DIR_PATH/$PEDIGREE_FILE_NAME > $OUTPUT_DIR_PATH/${SPLIT_OUTPUT_GROUP_NAME_CONF}${NUMBER}/${SPLIT_OUTPUT_PEDIGREE_FILE_NAME_CONF} # see protocol 44
    # splitting the genotype file
    awk -v var1=$TEMPO_IND 'BEGIN{FS="\t" ; OFS="" ; ORS=""}{if(NR==1){for (j=1; j<=NF; j++){if ($j ~ "^(" var1 ")_Call$" || $j ~ "SNP_ID") {col_nb[j] = j ; print $j"\t" }} print "\n" }} {if(NR>1){for (j=1; j<=NF; j++){if (j==col_nb[j]) {print $j"\t"}} print "\n" }}' $INPUT_DIR_PATH/$GENOTYPE_FILE_NAME > $OUTPUT_DIR_PATH/${SPLIT_OUTPUT_GROUP_NAME_CONF}${NUMBER}/${SPLIT_OUTPUT_GENOTYPE_FILE_NAME_CONF} # see https://superuser.com/questions/929010/match-the-column-heading-and-print-the-values-of-the-column-using-awk
    sed -i 's/\t$//g' $OUTPUT_DIR_PATH/${SPLIT_OUTPUT_GROUP_NAME_CONF}${NUMBER}/${SPLIT_OUTPUT_GENOTYPE_FILE_NAME_CONF} # remove the tab just before end of line
    # adding the freq and map files
    cat $INPUT_DIR_PATH/$FREQ_FILE_NAME > $OUTPUT_DIR_PATH/${SPLIT_OUTPUT_GROUP_NAME_CONF}${NUMBER}/${SPLIT_OUTPUT_FREQ_FILE_NAME_CONF}
    cat $INPUT_DIR_PATH/$MAP_FILE_NAME > $OUTPUT_DIR_PATH/${SPLIT_OUTPUT_GROUP_NAME_CONF}${NUMBER}/${SPLIT_OUTPUT_MAP_FILE_NAME_CONF}
done


######## END RAW DATA SPLITTING






################ END MAIN CODE

echo -e "\n\n################ END OF THE SPLITTING PROCESS\n\n"