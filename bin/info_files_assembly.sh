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

r_info_files_assembly_conf=${1}
r_main_functions_conf_ch=${2}
info_files=${3}
map_file=${4}
nb_of_groups=${5}


################ SPECIAL VARIABLES DUE TO THE SLURM -> NEXTFLOW UPGRADE


OUTPUT_DIR_PATH="."

module load R # module can be used because it is a specific docker


################ END SPECIAL VARIABLES DUE TO THE SLURM -> NEXTFLOW UPGRADE


################ STARTING

echo -e "\n----INFO FILE ASSEMBLY PROCESS----\n"
echo -e "r_info_files_assembly_conf: ${r_info_files_assembly_conf}\n"
echo -e "r_main_functions_conf_ch: ${r_main_functions_conf_ch}\n"
echo -e "info_files: ${info_files}\n"
echo -e "map_file: ${map_file}\n"
echo -e "nb_of_groups: ${nb_of_groups}\n"
echo -e "\n\n"


################ END STARTING

################ MAIN CODE

echo -e "\n\n################ INFO FILE ASSEMBLY\n\n"
CHROMO_NB="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23"

if [[ $MERLIN_ANALYSE_OPTION_CONF == "--best" ]] ; then
    echo -e "HAPLOTYPE INFERENCE (ANALYSE IS: $MERLIN_ANALYSE_OPTION_CONF)\n"
else
    for i in $CHROMO_NB ; do # I left "" to set the numbers as character strings
        for ((j=1; j<=$nb_of_groups; j++)); do
            if [[ ! -f "$OUTPUT_DIR_PATH/info_Group${j}_c${i}.tsv" ]] ; then
                echo -e "\nWARNING: THE info_Group${j}_c${i}.tsv LODSCORE FILE IS MISSING\n"
                # exit 1
            fi
        done
    done
    info_files2=$(echo "$info_files" | sed -e 's/ /,/g')
    map_file2=$(echo "$map_file" | sed -e 's/ /,/g')
    R_PROC="Rscript ${r_info_files_assembly_conf} ${r_main_functions_conf_ch} $info_files2 $map_file2 $nb_of_groups $OUTPUT_DIR_PATH"
    echo -e "\nTHE COMMAND USED FOR R ANALYSES IS:\n${R_PROC}\n"
    shopt -s expand_aliases # to be sure that alias are expended to the different environments
    $R_PROC
fi

echo -e "\n\n################ END OF INFO FILE ASSEMBLY\n\n"

################ END MAIN CODE





