#!/bin/bash
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


RAW_GENOTYPE_FILE_NAME_CONF=${1} # {genotype_ch}
RAW_FREQ_FILE_NAME_CONF=${2} # {freq_ch}
RAW_MAP_FILE_NAME_CONF=${3} # {map_ch}
RAW_PEDIGREE_FILE_NAME_CONF=${4} # {pedigree_ch}
BASH_FUNCTIONS_CONF=${5} # {BASH_FUNCTIONS_CONF_ch}
r_main_functions_conf=${6} # {r_main_functions_conf_ch}
r_check_lod_gael_conf=${7} # {r_check_lod_gael_conf_ch}
REPLACE_SPACE_CONF=${8}
SPLIT_OUTPUT_GROUP_NAME_CONF=${9}
SPLIT_IND_CONF=${10}
MERLIN_ANALYSE_OPTION_CONF=${11}
MERLIN_PARAM_CONF=${12}
# MERLIN_CHROMO_CONF=${17}
# MERLIN_LOD_CUTOFF_CONF=${18}


################ END INITIALIZATION

################ SPECIAL VARIABLES DUE TO THE SLURM -> NEXTFLOW UPGRADE


RUNNING_OP="rawfile_check,cleaning,postcleaning_check,splitting,postsplitting_check,alohomora,merlin"
INPUT_DIR_PATH="."
JOB_NB=1
OUTPUT_DIR_PATH="."
# JOB_ID="1" # probably remove all the JOB_ID in the code
R_OPT_TXT_CONF="notxt"
alias r_362_conf='module load R ; Rscript'

SPLIT_OUTPUT_GENOTYPE_FILE_NAME_CONF="genotyping genotyping genotyping"
SPLIT_OUTPUT_FREQ_FILE_NAME_CONF="freq freq freq"
SPLIT_OUTPUT_MAP_FILE_NAME_CONF="map map map"
SPLIT_OUTPUT_PEDIGREE_FILE_NAME_CONF="pedfile.pro pedfile.pro pedfile.pro"



FILE_NAME=("GENOTYPE_FILE_NAME" "FREQ_FILE_NAME" "MAP_FILE_NAME" "PEDIGREE_FILE_NAME")
FILE_NAME_PATH=("${INPUT_DIR_PATH}" "${INPUT_DIR_PATH}" "${INPUT_DIR_PATH}" "${INPUT_DIR_PATH}") # path of the four FILE_NAME
file_name_Num=$(( ${#FILE_NAME[@]} - 1 )) # total number of elements in the array


################ END SPECIAL VARIABLES DUE TO THE SLURM -> NEXTFLOW UPGRADE






################ STARTING

echo -e "\n----CHECKING PROCESS----\n"
echo -e "SCRIPT LOCAL LANGUAGE USED: $LANG\n"

echo -e "GENOTYPE_FILE_NAME: ${RAW_GENOTYPE_FILE_NAME_CONF}\n"
echo -e "FREQ_FILE_NAME: ${RAW_FREQ_FILE_NAME_CONF}\n"
echo -e "MAP_FILE_NAME: ${RAW_MAP_FILE_NAME_CONF}\n"
echo -e "PEDIGREE_FILE_NAME: ${RAW_PEDIGREE_FILE_NAME_CONF}\n"
echo -e "BASH_FUNCTIONS_CONF: ${BASH_FUNCTIONS_CONF}\n"
echo -e "r_main_functions_conf: ${r_main_functions_conf}\n"
echo -e "r_check_lod_gael_conf: ${r_check_lod_gael_conf}\n"
echo -e "REPLACE_SPACE_CONF: ${REPLACE_SPACE_CONF}\n"
echo -e "\n\n"

source "${BASH_FUNCTIONS_CONF}"

################ END STARTING



################ CHECK




if [[ $RUNNING_OP =~ splitting|postsplitting_check|alohomora|merlin ]]; then
    SPLIT_OUTPUT_GROUP_NAME_CONF=($SPLIT_OUTPUT_GROUP_NAME_CONF)
    SPLIT_OUTPUT_GENOTYPE_FILE_NAME_CONF=($SPLIT_OUTPUT_GENOTYPE_FILE_NAME_CONF)
    SPLIT_OUTPUT_FREQ_FILE_NAME_CONF=($SPLIT_OUTPUT_FREQ_FILE_NAME_CONF)
    SPLIT_OUTPUT_MAP_FILE_NAME_CONF=($SPLIT_OUTPUT_MAP_FILE_NAME_CONF)
    SPLIT_OUTPUT_PEDIGREE_FILE_NAME_CONF=($SPLIT_OUTPUT_PEDIGREE_FILE_NAME_CONF)
    SPLIT_IND_CONF=($SPLIT_IND_CONF)
    conf_split_output_group_name_Num=$(( ${#SPLIT_OUTPUT_GROUP_NAME_CONF[@]} - 1 )) # total number of elements in the array
    if [[ $conf_split_output_group_name_Num == $(( ${#SPLIT_OUTPUT_GENOTYPE_FILE_NAME_CONF[@]} - 1 )) && $conf_split_output_group_name_Num == $(( ${#SPLIT_OUTPUT_FREQ_FILE_NAME_CONF[@]} - 1 )) && $conf_split_output_group_name_Num == $(( ${#SPLIT_OUTPUT_MAP_FILE_NAME_CONF[@]} - 1 )) && $conf_split_output_group_name_Num == $(( ${#SPLIT_OUTPUT_PEDIGREE_FILE_NAME_CONF[@]} - 1 )) && $conf_split_output_group_name_Num == $(( ${#SPLIT_IND_CONF[@]} - 1 )) ]] ; then
         echo -e "THE VARIABLES FOR SPLITTING IN THE linkage.config FILE HAVE ALL THE SAME NUMBER OF ELEMENTS: $(($conf_split_output_group_name_Num + 1))\n"
    else
        echo -e "\n### ERROR ###  THE VARIABLES FOR SPLITTING IN THE linkage.config FILE HAVE DIFFERENT NUMBER OF ELEMENTS:\n"
        echo -e "SPLIT_OUTPUT_GROUP_NAME_CONF: $(( ${#SPLIT_OUTPUT_GROUP_NAME_CONF[@]} - 1 ))"
        echo -e "SPLIT_OUTPUT_GENOTYPE_FILE_NAME_CONF: $(( ${#SPLIT_GENOTYPE_FILE_NAME_CONF[@]} - 1 ))"
        echo -e "SPLIT_OUTPUT_FREQ_FILE_NAME_CONF: $(( ${#SPLIT_FREQ_FILE_NAME_CONF[@]} - 1 ))"
        echo -e "SPLIT_OUTPUT_MAP_FILE_NAME_CONF: $(( ${#SPLIT_MAP_FILE_NAME_CONF[@]} - 1 ))"
        echo -e "SPLIT_OUTPUT_PEDIGREE_FILE_NAME_CONF: $(( ${#SPLIT_PEDIGREE_FILE_NAME_CONF[@]} - 1 ))"
        echo -e "SPLIT_IND_CONF: $(( ${#SSPLIT_IND_CONF[@]} - 1 ))\n"
        echo -e "\n\n"
        exit 1
    fi

# verif that MERLIN_PARAM_CONF is correctly written
    MERLIN_PARAM_CONF_CHECK2=$(echo ${MERLIN_PARAM_CONF} | sed 's/\\t/ /g ; s/\,/ /g') # as an array
    MERLIN_PARAM_CONF_CHECK=($MERLIN_PARAM_CONF_CHECK2)
    conf_merlin_param_check_Num=$(( ${#MERLIN_PARAM_CONF_CHECK[@]})) # total number of elements in the array
    if [[ $conf_merlin_param_check_Num != 6 ]] ; then
        echo -e "\n### ERROR ###  PROBLEM WITH THE MERLIN_PARAM_CONF PARAMETER IN THE linkage.config FILE: SHOULD HAVE 6 ELEMENTS SEPARATED BY TABS AND COMMAS (AS THIS TRAIT\\t0.01\\t0.01,0.90,0.90\\tPARAM_MODEL)\nHERE THE PARAMETER IS: ${MERLIN_PARAM_CONF_CHECK[@]}\nAND THE NUMBER IS: $$conf_merlin_param_check_Num\n"
        exit 1
    else
        echo -e "MERLIN_PARAM_CONF PARAMETER IN THE linkage.config FILE HAS 6 ELEMENTS SEPARATED BY TABS AND COMMAS: ${MERLIN_PARAM_CONF_CHECK[@]}"
    fi
# verif that MERLIN_ANALYSE_OPTION_CONF is correctly written
    if [[ $MERLIN_ANALYSE_OPTION_CONF == "--model" || $MERLIN_ANALYSE_OPTION_CONF == "--npl" || $MERLIN_ANALYSE_OPTION_CONF == "--best" ]] ; then
        echo -e "MERLIN_ANALYSE_OPTION_CONF PARAMETER IN THE linkage.config FILE IS: $MERLIN_ANALYSE_OPTION_CONF"
    else
        echo -e "\n### ERROR ###  PROBLEM WITH THE MERLIN_ANALYSE_OPTION_CONF PARAMETER IN THE linkage.config FILE: SHOULD BE EITHER --model OR -npl OR --best\n"
        exit 1
    fi
fi





#### end check the files and variables necessary for the process .sh file


# files below necessary for the process .sh file
for i in "show_time_fun" "test_tab_in_file_fun" "test_space_in_file_fun" "space_replacement_in_file_fun" "file_pattern_detection_fun" "test_column_nb_perline_in_file_fun" ; do
   if [[ ! $(type -t $i) == "function" ]] ; then
        echo -e "\n### ERROR ###  $i FUNCTION NOT AVAILABLE IN THE GLOBAL ENVIRONMENT: CHECK THE BASH_FUNCTIONS_CONF PARAMETER IN THE linkage.config FILE\n"
        usage
        exit 1
    else
        echo -e "$i FUNCTION DETECTED IN THE GLOBAL ENVIRONMENT"
    fi
done
echo -e "\n"
echo -e "\nALL CHECKS OK: PROCESS ENGAGED......................\n"








################ END CHECK



################ MAIN CODE


######## RAW DATA CHECKING

echo -e "\n\n################ RAW DATA CHECKING\n\n"
if [[ $RUNNING_OP =~ rawfile_check ]] ; then
    OUTPUT_R="r_raw_checking_report.txt" ;
    OUTPUT_ERROR_R="r_raw_checking_error.txt" ;
    if [[ -f $OUTPUT_R || -f $OUTPUT_ERROR_R ]] ; then
        echo -e "\nPROBLEM: RUNNING_OP PARAMETER WITH rawfile_check BUT ${OUTPUT_R FILE} OR ${OUTPUT_ERROR_R} FILE ALREADY EXIST IN ${INPUT_DIR_NAME}\n"
        exit 1
    fi
    R_PROC="r_362_conf ${r_check_lod_gael_conf} $OUTPUT_DIR_PATH $OUTPUT_R $OUTPUT_ERROR_R" # for R analysis after the loop
    # loop to recover the files from the config file
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
    echo -e "GENOTYPE_FILE_NAME: $GENOTYPE_FILE_NAME\n"
    echo -e "FREQ_FILE_NAME: $FREQ_FILE_NAME\n"
    echo -e "MAP_FILE_NAME: $MAP_FILE_NAME\n"
    echo -e "PEDIGREE_FILE_NAME: $PEDIGREE_FILE_NAME\n"
    
    for i in `seq 0  $file_name_Num` ; do # "$INPUT_DIR_NAME" is equivalent to genotyping[$i]
        KEPT_FILE=$(echo ${!FILE_NAME[$i]}) # will be use to change the name of the file if error lines are removed
        KEPT_FILE_PATH=$(echo ${FILE_NAME_PATH[$i]}) # will be use to change the name of the file if error lines are removed
        echo -e "\n\n######## ${KEPT_FILE} FILE\n\n"
        echo -e "\nFILE: ${KEPT_FILE}"
        echo -e "FILE PATH: ${KEPT_FILE_PATH}\n"
       if [[ $KEPT_FILE == $PEDIGREE_FILE_NAME ]]  ;then
            echo -e "\nREMINDER: THE ${KEPT_FILE} FILE MUST BE ANY SPACE SEPARATED FOR SUBSEQUENT ALOHOMORA AND MERLIN ANALYSIS\n"
        else
            echo -e "\nREMINDER: THE ${KEPT_FILE} FILE MUST BE TAB SEPARATED FOR SUBSEQUENT ALOHOMORA AND MERLIN ANALYSIS\n"
        fi
        INPUT=${INPUT_DIR_PATH}/${KEPT_FILE}
        OUTPUT_3=${OUTPUT_DIR_PATH}/${KEPT_FILE}_pattern.txt
        OUTPUT_4=${OUTPUT_DIR_PATH}/${KEPT_FILE}_wo_pattern.txt
        PATTERN="(^#)|(^[[:space:]]*$)" # any line starting by #or any empty line or fill with only spaces and tabs
        file_pattern_detection_fun -i $INPUT -o $OUTPUT_3 -c $OUTPUT_4 -d $PATTERN # removal of lines starting by # or empty lines
        TEMPO_RETURN_4=$(echo $?) # test pattern
        if [[ $TEMPO_RETURN_4 == 1 ]] ; then
            echo -e "\nPROBLEM USING file_pattern_detection_fun ON $INPUT: FUNCTION RETURNS ${TEMPO_RETURN_4}\n"
            exit 1
        elif [[ $TEMPO_RETURN_4 == 0 ]]; then
            NUMBER_LINES_RM=$(awk 'END{print NR}' $OUTPUT_3)
            echo -e "\nUSING PATTERN ${PATTERN}, ${NUMBER_LINES_RM} LINES REMOVED IN $INPUT (see $OUTPUT_3)\n"
            # R_PROC="${R_PROC} ${OUTPUT_2}"
        elif [[ $TEMPO_RETURN_4 == 2 ]]; then
            echo -e "\nUSING PATTERN ${PATTERN}, NO LINES REMOVED IN $INPUT\n"
            OUTPUT_4=$INPUT
            # R_PROC="${R_PROC} ${OUTPUT_2}"
        else
            echo -e "\nPROBLEM USING file_pattern_detection_fun: return DIFFERENT FROM 0, 1 or 2\n"
            exit 1
        fi
        INPUT=$OUTPUT_4
        echo -e "\nTHE ${INPUT} FILE WILL BE USED FOR SUBSEQUENT LINE ERROR ANALYSIS AND ANALYSIS BY R\n"

        OUTPUT_2=${OUTPUT_DIR_PATH}/${KEPT_FILE}_spacereplace.txt
        test_space_in_file_fun $INPUT
        TEMPO_RETURN_1=$(echo $?) # test space
        # echo "TEMPO_RETURN_1 $TEMPO_RETURN_1\n"
        if [[ $TEMPO_RETURN_1 == 1 ]] ; then
            echo -e "\nPROBLEM USING test_space_in_file_fun ON $INPUT: FUNCTION RETURNS ${TEMPO_RETURN_1}\n"
            exit 1
        elif [[ $TEMPO_RETURN_1 == 0 ]] ; then # space detected
            if [[ $KEPT_FILE == "pedfile${JOB_NB}.pro" ]] ; then
                REPLACE_CHAR="\t"
            else
                REPLACE_CHAR=$REPLACE_SPACE_CONF
            fi
            
            space_replacement_in_file_fun -i $INPUT -o $OUTPUT_2 -r $REPLACE_CHAR # space replacement by _._
            TEMPO_RETURN_2=$(echo $?)
            if [[ $TEMPO_RETURN_2 == 1 ]] ; then # error
                echo -e "\nPROBLEM USING space_replacement_in_file_fun ON $INPUT: FUNCTION RETURNS ${TEMPO_RETURN_2}\n"
                exit 1
            elif [[ $TEMPO_RETURN_2 == 0 ]]; then # space replacement
                echo -e "\nREPLACEMENT OF SPACES BY ${REPLACE_CHAR} IN THE ${INPUT} FILE\n"
            else
                echo -e "\nPROBLEM USING space_replacement_in_file_fun: return DIFFERENT FROM 0, 1 or 2 VALUES, OR SPACES DETECTED BY test_space_in_file_fun BUT NOT REPLACED BY space_replacement_in_file_fun\n"
                exit 1
            fi
        elif [[ $TEMPO_RETURN_1 == 2 ]]; then # no space replacement 
                 echo -e "\nNO SPACES DETECTED IN THE ${INPUT} FILE BY THE test_space_in_file_fun FUNCTION\n"
                OUTPUT_2=$INPUT
        else
            echo -e "\nPROBLEM USING test_space_in_file_fun: return DIFFERENT FROM 0, 1 or 2\n"
            exit 1
        fi
        INPUT=$OUTPUT_2
        echo -e "\nTHE ${INPUT} FILE WILL BE USED FOR SUBSEQUENT LINE ERROR ANALYSIS AND ANALYSIS BY R\n"
        # R_PROC="${R_PROC} ${OUTPUT_2}"

        test_tab_in_file_fun $INPUT
        TEMPO_RETURN_3=$(echo $?) # test tabulation
        if [[ $TEMPO_RETURN_3 != 0 ]] ; then
            echo -e "\nPROBLEM USING test_tab_in_file_fun ON $INPUT: FUNCTION RETURNS ${TEMPO_RETURN_3}\n"
            exit 1
        fi

        OUTPUT_5=${OUTPUT_DIR_PATH}/${KEPT_FILE}_line_error.txt
        OUTPUT_6=${OUTPUT_DIR_PATH}/${KEPT_FILE}_wo_error_line.txt
        test_column_nb_perline_in_file_fun -i $INPUT -o $OUTPUT_5 -c $OUTPUT_6 -d "\t"
        TEMPO_RETURN_5=$(echo $?) # test number of columns. If =5, remove lines for R analysis
        if [[ $TEMPO_RETURN_5 =~ [1-3] ]] ; then # idem $TEMPO_RETURN_4 == 1 || $TEMPO_RETURN_4 == 2 || $TEMPO_RETURN_4 == 3
            echo -e "\nPROBLEM USING test_column_nb_perline_in_file_fun ON $INPUT: FUNCTION RETURNS ${TEMPO_RETURN_4}\n"
            exit 1
        elif [[ $TEMPO_RETURN_5 == 4 ]]; then
            echo -e "\nERROR LINES DETECTED IN $INPUT (see $OUTPUT_5) BY THE test_column_nb_perline_in_file_fun FUNCTION\n"
            # R_PROC="${R_PROC} ${OUTPUT_2}"
            KEPT_FILE=$OUTPUT_6
            KEPT_FILE_PATH=$OUTPUT_DIR_PATH
        elif [[ $TEMPO_RETURN_5 == 0 ]]; then
            echo -e "\nNO ERROR LINE DETECTED IN $INPUT BY THE test_column_nb_perline_in_file_fun FUNCTION\n"
            OUTPUT_6=$INPUT
            # R_PROC="${R_PROC} ${OUTPUT_2}"
        else
            echo -e "\nPROBLEM USING test_column_nb_perline_in_file_fun DIFFERENT FROM 0-4\n"
            exit 1
        fi
        INPUT=$OUTPUT_6
        echo -e "\nTHE ${INPUT} FILE WILL BE USED FOR SUBSEQUENT LINE ERROR ANALYSIS AND ANALYSIS BY R\n"
        R_PROC="${R_PROC} ${INPUT}"
        export $(echo ${FILE_NAME[$i]})=$KEPT_FILE # this is to put the name of the file back into one of these FILE_NAME=("GENOTYPE_FILE_NAME" "FREQ_FILE_NAME" "MAP_FILE_NAME" "PEDIGREE_FILE_NAME") 
        FILE_NAME_PATH[$i]=$KEPT_FILE_PATH # this is to put the name of the file back into one of these FILE_NAME=("GENOTYPE_FILE_NAME" "FREQ_FILE_NAME" "MAP_FILE_NAME" "PEDIGREE_FILE_NAME") 
        echo -e "\nTHE ${!FILE_NAME[$i]} FILE WILL BE USED FOR SUBSEQUENT PROCESSINGS\nTHIS FILE IS IN ${FILE_NAME_PATH[$i]}/\n"
    done

    R_PROC="${R_PROC} $r_main_functions_conf raw $R_OPT_TXT_CONF" # raw to specify that the check is at the raw step
    echo -e "\nTHE COMMAND USED FOR R ANALYSES IS:\n${R_PROC}\n"
    shopt -s expand_aliases # to be sure that alias are expended to the different environments
    eval "$R_PROC" # remove "" to allow regex translation
else
    echo -e "NO RAW DATA CHECKING PERFORMED\n"
fi

######## END RAW DATA CHECKING


echo -e "\n\n################ END OF THE CHECKING PROCESS\n\n"




################ END MAIN CODE

