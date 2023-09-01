nextflow.enable.dsl=2
/*
#########################################################################
##                                                                     ##
##     linkage.nf                                                      ##
##                                                                     ##
##     Gael A. Millot                                                  ##
##     Bioinformatics and Biostatistics Hub                            ##
##     Computational Biology Department                                ##
##     Institut Pasteur Paris                                          ##
##                                                                     ##
#########################################################################
*/

//////// Aim

    // Perform:
    // 'rawfile_check'        - check the 4 initial files genotyping, freq, map & pedfile
    // 'cleaning'             - clean files to be ready for alohomora
    // 'postcleaning_check'   - check the 4 files after cleaning and provide basic information
    // 'splitting'            - split the initial data files to generate the 4 files for alohomora
    // 'postsplitting_check'  - check if the 4 files after splitting and provide basic information
    // 'alohomora'            - pretreatment of the files using alohomora
    // 'merlin'               - merlin use

//////// End Aim



//////// Processes


process workflowParam { // create a file with the workflow parameters in out_path
    label 'bash' // see the withLabel: bash in the nextflow config file 
    publishDir "${out_path}/reports", mode: 'copy', overwrite: false
    cache 'false'

    input:
    val modules

    output:
    path "Run_info.txt"

    script:
    """
    echo "Project (empty means no .git folder where the main.nf file is present): " \$(git -C ${projectDir} remote -v | head -n 1) > Run_info.txt # works only if the main script run is located in a directory that has a .git folder, i.e., that is connected to a distant repo
    echo "Git info (empty means no .git folder where the main.nf file is present): " \$(git -C ${projectDir} describe --abbrev=10 --dirty --always --tags) >> Run_info.txt # idem. Provide the small commit number of the script and nextflow.config used in the execution
    echo "Cmd line: ${workflow.commandLine}" >> Run_info.txt
    echo "execution mode": ${system_exec} >> Run_info.txt
    modules=$modules # this is just to deal with variable interpretation during the creation of the .command.sh file by nextflow. See also \$modules below
    if [[ ! -z \$modules ]] ; then
        echo "loaded modules (according to specification by the user thanks to the --modules argument of main.nf): ${modules}" >> Run_info.txt
    fi
    echo "Manifest's pipeline version: ${workflow.manifest.version}" >> Run_info.txt
    echo "result path: ${out_path}" >> Run_info.txt
    echo "nextflow version: ${nextflow.version}" >> Run_info.txt
    echo -e "\\n\\nIMPLICIT VARIABLES:\\n\\nlaunchDir (directory where the workflow is run): ${launchDir}\\nprojectDir (directory where the main.nf script is located): ${projectDir}\\nworkDir (directory where tasks temporary files are created): ${workDir}" >> Run_info.txt
    echo -e "\\n\\nUSER VARIABLES:\\n\\nout_path: ${out_path}" >> Run_info.txt
    """
}
//${projectDir} nextflow variable
//${workflow.commandLine} nextflow variable
//${workflow.manifest.version} nextflow variable
//Note that variables like ${out_path} are interpreted in the script block


process checking {
    label 'bash'
    publishDir path: "${out_path}/merlin_reports", mode: 'copy', pattern: "{r_raw_checking*}", overwrite: false
    publishDir path: "${out_path}", mode: 'copy', pattern: "{raw_snp*}", overwrite: false
    publishDir path: "${out_path}/merlin_reports", mode: 'copy', pattern: "{checking_report.log}", overwrite: false
    cache 'true'

    input:
    // channels
    path RAW_GENOTYPE_FILE_NAME_CONF_ch
    path RAW_FREQ_FILE_NAME_CONF_ch
    path RAW_MAP_FILE_NAME_CONF_ch
    path RAW_PEDIGREE_FILE_NAME_CONF_ch
    path BASH_FUNCTIONS_CONF_ch
    path r_main_functions_conf_ch
    path r_check_lod_gael_conf_ch

    output:
    path "r_raw_checking*"
    path "raw_snp*"
    path "checking_report.log", emit: wait_ch

    script:
    """
    #!/bin/bash -uel
    # -l is required for the module command
    checking.sh \
${RAW_GENOTYPE_FILE_NAME_CONF_ch} \
${RAW_FREQ_FILE_NAME_CONF_ch} \
${RAW_MAP_FILE_NAME_CONF_ch} \
${RAW_PEDIGREE_FILE_NAME_CONF_ch} \
${BASH_FUNCTIONS_CONF_ch} \
${r_main_functions_conf_ch} \
${r_check_lod_gael_conf_ch} \
 &> >(tee -a checking_report.log) &
    """
}

process cleaning {
    label 'bash'
    publishDir path: "${out_path}/merlin_reports", mode: 'copy', pattern: "{r_cleaning_checking*}", overwrite: false
    publishDir path: "${out_path}/merlin_reports", mode: 'copy', pattern: "{r_postcleaning_check*}", overwrite: false
    publishDir path: "${out_path}/merlin_reports", mode: 'copy', pattern: "{cleaning_report.log}", overwrite: false
    cache 'true'

    input:
    // channels
    path RAW_GENOTYPE_FILE_NAME_CONF_ch
    path RAW_FREQ_FILE_NAME_CONF_ch
    path RAW_MAP_FILE_NAME_CONF_ch
    path RAW_PEDIGREE_FILE_NAME_CONF_ch
    path r_main_functions_conf_ch
    path r_check_lod_gael_conf_ch
    path r_clean_lod_gael_conf_ch
    path wait_ch

    output:
    path "genotype.txt", emit: genotype_ch
    path "freq.txt", emit: freq_ch
    path "map.txt", emit: map_ch
    path "pedigree.pro", emit: pedigree_ch
    path "r_cleaning_checking*"
    path "r_postcleaning_check*"
    path "cleaning_report.log"

    script:
    """
    #!/bin/bash -uel
    # -l is required for the module command
    cp ${RAW_GENOTYPE_FILE_NAME_CONF_ch} "./genotype.txt"
    cp ${RAW_FREQ_FILE_NAME_CONF_ch} "./freq.txt"
    cp ${RAW_MAP_FILE_NAME_CONF_ch} "./map.txt"
    cp ${RAW_PEDIGREE_FILE_NAME_CONF_ch} "./pedigree.pro"
    chmod 777 ./genotype.txt
    chmod 777 ./freq.txt
    chmod 777 ./map.txt
    chmod 777 ./pedigree.pro
    cleaning.sh \
"genotype.txt" \
"freq.txt" \
"map.txt" \
"pedigree.pro" \
"${r_main_functions_conf_ch}" \
"${r_check_lod_gael_conf_ch}" \
"${r_clean_lod_gael_conf_ch}" \
| tee -a cleaning_report.log
    """
}


process splitting {
    label 'bash'
    publishDir path: "${out_path}/merlin_reports", mode: 'copy', pattern: "{splitting_report.log}", overwrite: false
    cache 'true'

    input:
    // channels
    path genotype_ch
    path freq_ch
    path map_ch
    path pedigree_ch
    // variables
    val IID_IN_GROUP_CONF

    output:
    path "Group*", emit: group_dir_ch
    path "splitting_report.log"

    script:
    """
    #!/bin/bash -uel
    # -l is required for the module command
    splitting.sh \
${genotype_ch} \
${freq_ch} \
${map_ch} \
${pedigree_ch} \
"${IID_IN_GROUP_CONF}" \
| tee -a splitting_report.log
    """
}


process alohomora {
    label 'bash'
    publishDir path: "${out_path}/merlin_reports", mode: 'copy', pattern: "{r_postsplitting_check*}", overwrite: false
    publishDir path: "${out_path}/merlin_reports", mode: 'copy', pattern: "{alohomora_report*}", overwrite: false
    cache 'true'

    input:
    // channel
    path group_dir_ch // 3 parallelization expected (if 3 pedigrees)
    path r_main_functions_conf_ch
    path r_check_lod_gael_conf_ch
    path alohomora_bch_conf_ch

    output:
    tuple val(group_dir_ch.baseName), path("Group*/merlin/c*"), emit: chr_dir_ch // Warning: make 3 channels, each with one tuple with a single group_name associated with 23 path
    path "r_postsplitting_check*"
    path "alohomora_report*"

    script:
    """
    #!/bin/bash -uel
    # -l is required for the module command
    GROUP_NAME=${group_dir_ch.baseName}
    # see https://stackoverflow.com/questions/1371261/get-current-directory-or-folder-name-without-the-full-path
    shopt -s extglob           # enable +(...) glob syntax
    # GROUP_NAME=\${GROUP_NAME%%+(/)}    # trim however many trailing slashes exist
    # GROUP_NAME=\${GROUP_NAME##*/}       # remove everything before the last / that still remains
    # GROUP_NAME=\${GROUP_NAME:-/}        # correct for dirname=/
    cp -Lr ${group_dir_ch} "./\${GROUP_NAME}b/" # to have the hard directory, not the symlink, because modifications will be performed inside
    chmod 777 ./\${GROUP_NAME}b/*.*
    rm \${GROUP_NAME} # remove the intitial directory to facilitate output
    GROUP_NAME="\${GROUP_NAME}b"
    GENOTYPE_FILE_NAME="genotyping"
    FREQ_FILE_NAME="freq"
    MAP_FILE_NAME="map"
    PEDIGREE_FILE_NAME="pedfile.pro"
    alohomora.sh \
\${GROUP_NAME} \
\${GENOTYPE_FILE_NAME} \
\${FREQ_FILE_NAME} \
\${MAP_FILE_NAME} \
\${PEDIGREE_FILE_NAME} \
${r_main_functions_conf} \
${r_check_lod_gael_conf} \
${alohomora_bch_conf} \
| tee -a alohomora_report_\${GROUP_NAME}.log
    """
}


process pre_merlin {
    label 'bash'
    publishDir path: "${out_path}/merlin_reports", mode: 'copy', pattern: "{pre_merlin_report*}", overwrite: false
    publishDir path: "${out_path}", mode: 'copy', pattern: "{pedstats*}", overwrite: false
    cache 'true'

    input:
    // channel
    tuple val(group_name), path(chr_dir_ch) // 23 * 3 = 69 parallelization expected
    //path chr_dir_ch // parallelization expected
    val bit_nb

    output:
    //tuple val(TEMPO), path("c*"), emit: chr_dir_ch2
    tuple val(group_name), path("c*"), emit: chr_dir_ch2
    path "pedstats*", optional: true // because chromo 23 has no pedstats files
    path "pre_merlin_report*"

    script:
    """
    #!/bin/bash -uel
    # -l is required for the module command
    CHR_NAME=${chr_dir_ch.baseName} # path of the symlink folder in the new merlin work directory
    # see https://stackoverflow.com/questions/1371261/get-current-directory-or-folder-name-without-the-full-path
    # shopt -s extglob           # enable +(...) glob syntax
    # CHROMO_NB=\${DIR_PATH%%+(/)}    # trim however many trailing slashes exist
    # CHROMO_NB=\${CHROMO_NB##*/}       # remove everything before the last / that still remains
    # CHROMO_NB=\${CHROMO_NB:-/}        # correct for dirname=/

    # at that stage, CHR_NAME should be like c01
    cp -Lr ${chr_dir_ch} "./\${CHR_NAME}b/" # to have the hard directory, not the symlink, because modifications will be performed inside
    chmod 777 ./\${CHR_NAME}b/*.*
    rm \${CHR_NAME} # remove the intitial directory to facilitate output
    TEMPO=\${CHR_NAME}
    CHR_NAME="\${CHR_NAME}b"
    pre_merlin.sh \
"\${CHR_NAME}" \
${bit_nb} \
| tee -a pre_merlin_report_${group_name}_\${TEMPO}.log
    if [[ -f ./\${CHR_NAME}/pedstats.markerinfo ]] ; then
        cp ./\${CHR_NAME}/pedstats.markerinfo "pedstats.markerinfo_\${TEMPO}"
        cp ./\${CHR_NAME}/pedstats.pdf "pedstats_\${TEMPO}.pdf"
    else
        echo -e "\nWARNING: pedstats.markerinfo_\${TEMPO} COULD NOT BE COMPUTED\n\n"
    fi
    """
}


process merlin {
    label 'bash'
    publishDir path: "${out_path}/merlin_reports", mode: 'copy', pattern: "{merlin_report*}", overwrite: false
    publishDir path: "${out_path}", mode: 'copy', pattern: "{Group*}", overwrite: false
    cache 'true'

    input:
    // channel
    // tuple val("CHROMO_NB"), path("DIR_NAME") // from group_dir_ch, parallelization expected, CHROMO_NB is the raw chr number, e.g., "01", DIR_NAME is directory name, like "c01b" ok
    tuple val(group_name), path(chr_dir_ch2) // parallelization expected
    // variable
    val MERLIN_ANALYSE_OPTION_CONF
    val MERLIN_PARAM_CONF
    val bit_nb

    output:
    path "Group*"
    path "lodscore_*", emit: lod_ch
    path "map_*", emit: map_ch
    path "info_*", emit: info_ch
    path "merlin_report*"

    script:
    """
    #!/bin/bash -uel
    # -l is required for the module command
    CHR_NAME=${chr_dir_ch2} # path of the symlink folder in the new merlin work directory
    # see https://stackoverflow.com/questions/1371261/get-current-directory-or-folder-name-without-the-full-path
    # shopt -s extglob           # enable +(...) glob syntax
    # CHROMO_NB=\${DIR_PATH%%+(/)}    # trim however many trailing slashes exist
    # CHROMO_NB=\${CHROMO_NB##*/}       # remove everything before the last / that still remains
    # CHROMO_NB=\${CHROMO_NB:-/}        # correct for dirname=/

    # at that stage, CHROMO_NB should be like c01b
    TEMPO=\${CHR_NAME}
    CHR_NAME=\$(echo \${CHR_NAME} | sed 's/c//g') # remove the c of the chromo name
    CHROMO_NB=\$(echo \${CHR_NAME} | sed 's/b//g') # remove the b of the chromo name
    # below the lines are inactivated because Merlin does not modify the input files: thus, no problem with cache for the modification of files in symlinks
    # cp -Lr ./\${TEMPO} "./c\${CHROMO_NB}c/" # to have the hard directory, not the symlink, because modifications will be performed inside, dir are now like c01c
    # chmod 777 ./c\${CHROMO_NB}c/*.*
    # rm \${TEMPO} # remove the intitial directory to facilitate output
    merlin.sh \
"\${CHROMO_NB}" \
"${MERLIN_ANALYSE_OPTION_CONF}" \
"${MERLIN_PARAM_CONF}" \
${bit_nb} \
| tee -a merlin_report_${group_name}_\${CHROMO_NB}.log
    mkdir ${group_name}_c\${CHROMO_NB}_merlin
    cp -r merlin* ${group_name}_c\${CHROMO_NB}_merlin/
    cp -r \${TEMPO}/map* ${group_name}_c\${CHROMO_NB}_merlin/map_${group_name}_c\${CHROMO_NB}.txt # required for plotting
    cp -r \${TEMPO}/map* ./MAP_FILE # required for plotting

    # the following lines are for the next processes
    INFO_FILE="merlin-info.tbl"
    if [[ ${MERLIN_ANALYSE_OPTION_CONF} == "--best" ]] ; then
        echo -e "WARNING: HAPLOTYPE INFERENCE (ANALYSE IS: $MERLIN_ANALYSE_OPTION_CONF)\nNO LODSCORE OR INFORMATION FILE RETURNED BY THE PIPELINE (CODE of merlin.sh FILEHAS TO BE MODIFIED)"
        LOD_FILE="no-lodscore-computed.tbl"
        INFO_FILE="no-information-computed.tbl"
        echo "" > ${group_name}_c\${CHROMO_NB}_merlin/\${LOD_FILE}
        echo "" > ${group_name}_c\${CHROMO_NB}_merlin/\${LOD_FILE}
    elif [[ ${MERLIN_ANALYSE_OPTION_CONF} == "--model" ]] ; then
        LOD_FILE="merlin-parametric.tbl"
    elif [[ ${MERLIN_ANALYSE_OPTION_CONF} == "--npl" ]] ; then
        LOD_FILE="merlin-nonparametric.tbl"
    else
        echo -e "\n### ERROR ###  PROBLEM WITH THE MERLIN_ANALYSE_OPTION_CONF PARAMETER IN THE linkage.config FILE: SHOULD BE EITHER --best, --model OR --npl\n"
        exit 1
    fi
    awk -v var1=${group_name} 'BEGIN{OFS="" ; ORS=""}{if(NR==1){print \$0"\\tGROUP\\n"}else{print \$0"\\t"var1"\\n"}}' \${LOD_FILE} > TEMPO1_FILE # add the group name as last column
    awk -v var1=${group_name} 'BEGIN{OFS="" ; ORS=""}{if(NR==1){print \$0"\\tGROUP\\n"}else{print \$0"\\t"var1"\\n"}}' \${INFO_FILE} > TEMPO2_FILE # add the group name as last column
    awk -v var1=${group_name} 'BEGIN{OFS="" ; ORS=""}{if(NR==1){print \$0"\\tGROUP\\n"}else{print \$0"\\t"var1"\\n"}}' MAP_FILE > TEMPO3_FILE # add the group name as last column
    cp TEMPO1_FILE "lodscore_${group_name}_c\${CHROMO_NB}.tsv" # rename to facilitate export into channel
    cp TEMPO2_FILE "info_${group_name}_c\${CHROMO_NB}.tsv" # rename to facilitate export into channel
    cp TEMPO3_FILE "map_${group_name}_c\${CHROMO_NB}.txt" # rename to facilitate export into channel
    """
}


process lod_files_assembly {
    label 'bash'
    publishDir path: "${out_path}/merlin_reports", mode: 'copy', pattern: "{lod_files_assembly_report*}", overwrite: false
    publishDir path: "${out_path}", mode: 'copy', pattern: "complete_lodscore.tsv", overwrite: false

    cache 'true'

    input:
    // channel
    path lod_files // no parallelization but 69 files
    path map_files // no parallelization but 69 files
    val nb_of_groups
    path r_main_functions_conf_ch
    path r_lod_files_assembly_conf

    output:
    path "lod_files_assembly_report*"
    path "complete_lodscore.tsv", emit: full_ch

    script:
    """
    #!/bin/bash -uel
    # -l is required for the module command
    lod_files_assembly.sh \
${r_lod_files_assembly_conf} \
${r_main_functions_conf_ch} \
"${lod_files}" \
"${map_files}" \
${nb_of_groups} \
| tee -a lod_files_assembly_report.log
    """
}


process custom_lod_graph {
    label 'r_ext'
    publishDir path: "${out_path}/merlin_reports", mode: 'copy', pattern: "{custom_lod_graph_*}", overwrite: false
    publishDir path: "${out_path}", mode: 'copy', pattern: "lodscore*.pdf", overwrite: false
    publishDir path: "${out_path}", mode: 'copy', pattern: "cutoff*", overwrite: false
    publishDir path: "${out_path}", mode: 'copy', pattern: "*.RData", overwrite: false
    cache 'true'

    input:
    // channel
    path full_ch // no parallelization
    path r_custom_lod_graph_gael_conf
    path r_main_functions_conf_ch
    path human_chr_info_ch
    // variable
    val MERLIN_ANALYSE_OPTION_CONF
    val MERLIN_PARAM_CONF
    val MERLIN_DISPLAY_CHROMO_CONF
    val MERLIN_LOD_CUTOFF_CONF

    output:
    path "custom_lod_graph_*"
    path "lodscore*.pdf", optional: true
    path "cutoff*", optional: true
    path "*.RData", optional: true

    script:
    """
    #!/bin/bash -ue
    # -l is required for the module command
    MERLIN_DISPLAY_CHROMO_CONF=\$(eval $MERLIN_DISPLAY_CHROMO_CONF)
    MERLIN_LOD_CUTOFF_CONF=\$(eval $MERLIN_LOD_CUTOFF_CONF)
    custom_lod_graph.sh \
"${full_ch}" \
${r_custom_lod_graph_gael_conf} \
${r_main_functions_conf_ch} \
${human_chr_info_ch} \
"${MERLIN_ANALYSE_OPTION_CONF}" \
"${MERLIN_PARAM_CONF}" \
"\${MERLIN_DISPLAY_CHROMO_CONF}" \
"\$MERLIN_LOD_CUTOFF_CONF" \
| tee -a custom_lod_graph_report.log
    """
}

process info_files_assembly {
    label 'bash'
    publishDir path: "${out_path}/merlin_reports", mode: 'copy', pattern: "{info_files_assembly_report*}", overwrite: false
    publishDir path: "${out_path}", mode: 'copy', pattern: "complete_information*.tsv", overwrite: false

    cache 'true'

    input:
    // channel
    path info_files // no parallelization but 69 files
    path map_files // no parallelization but 69 files
    val nb_of_groups
    path r_main_functions_conf_ch
    path r_info_files_assembly_conf

    output:
    path "info_files_assembly_report*"
    path "complete_information*.tsv", emit: full_info_ch // a single file

    script:
    """
    #!/bin/bash -uel
    # -l is required for the module command
    info_files_assembly.sh \
${r_info_files_assembly_conf} \
${r_main_functions_conf_ch} \
"${info_files}" \
"${map_files}" \
${nb_of_groups} \
| tee -a info_files_assembly_report.log
    """
}


process custom_info_graph {
    label 'r_ext'
    publishDir path: "${out_path}/merlin_reports", mode: 'copy', pattern: "{custom_info_graph_*}", overwrite: false
    publishDir path: "${out_path}", mode: 'copy', pattern: "info*.pdf", overwrite: false
    publishDir path: "${out_path}", mode: 'copy', pattern: "cutoff*", overwrite: false
    publishDir path: "${out_path}", mode: 'copy', pattern: "*.RData", overwrite: false
    cache 'true'

    input:
    // channel
    path full_info_ch // no parallelization
    path r_custom_info_graph_gael_conf
    path r_main_functions_conf_ch
    path human_chr_info_ch
    // variable
    val MERLIN_ANALYSE_OPTION_CONF
    val MERLIN_PARAM_CONF
    val MERLIN_DISPLAY_CHROMO_CONF
    val MERLIN_LOD_CUTOFF_CONF

    output:
    path "custom_info_graph_*"
    path "info*.pdf", optional: true
    path "cutoff*", optional: true
    path "*.RData", optional: true

    script:
    """
    #!/bin/bash -ue
    # -l is required for the module command
    # WARNING : lod_files_assembly.sh reused here because no need to change anything
    MERLIN_DISPLAY_CHROMO_CONF=\$(eval $MERLIN_DISPLAY_CHROMO_CONF)
    MERLIN_LOD_CUTOFF_CONF=\$(eval $MERLIN_LOD_CUTOFF_CONF)
    custom_lod_graph.sh \
"${full_info_ch}" \
${r_custom_info_graph_gael_conf} \
${r_main_functions_conf_ch} \
${human_chr_info_ch} \
"${MERLIN_ANALYSE_OPTION_CONF}" \
"${MERLIN_PARAM_CONF}" \
"\${MERLIN_DISPLAY_CHROMO_CONF}" \
"\$MERLIN_LOD_CUTOFF_CONF" \
| tee -a custom_info_graph_report.log
    """
}



process backup {
    label 'bash' // see the withLabel: bash in the nextflow config file 
    publishDir "${out_path}/reports", mode: 'copy', overwrite: false // since I am in mode copy, all the output files will be copied into the publishDir. See \\wsl$\Ubuntu-20.04\home\gael\work\aa\a0e9a739acae026fb205bc3fc21f9b
    cache 'false'

    input:
    path config_file
    path log_file

    output:
    path "${config_file}" // warning message if we use file config_file
    path "${log_file}" // warning message if we use file log_file
    path "Log_info.txt"

    script:
    """
    #!/bin/bash -ue
    echo -e "full .nextflow.log is in: ${launchDir}\nThe one in the result folder is not complete (miss the end)" > Log_info.txt
    """
}


workflow {

    //////// Options of nextflow run

    print("\n\nINITIATION TIME: ${workflow.start}")

    //////// end Options of nextflow run


    //////// Options of nextflow run

    // --modules (it is just for the process workflowParam)
    params.modules = "" // if --module is used, this default value will be overridden
    // end --modules (it is just for the process workflowParam)

    //////// end Options of nextflow run


    //////// Variables

    modules = params.modules // remove the dot -> can be used in bash scripts
    config_file = workflow.configFiles[0] // better to use this than config_file = file("${projectDir}/ig_clustering.config") because the latter is not good if -c option of nextflow run is used
    log_file = file("${launchDir}/.nextflow.log")


    //////// end Variables


    //////// Channels


    //////// end Channels


    //////// Checks

    if( ! file(RAW_INPUT_DIR_CONF).exists()){
        error "\n\n========\n\nERROR IN NEXTFLOW EXECUTION\n\nINVALID RAW_INPUT_DIR_CONF PARAMETER IN linkage.config FILE (DOES NOT EXIST): ${RAW_INPUT_DIR_CONF}\nIF POINTING TO A DISTANT SERVER, CHECK THAT IT IS MOUNTED\n\n========\n\n"
    }
    if( ! file(RAW_INPUT_DIR_CONF+"/"+RAW_GENOTYPE_FILE_NAME_CONF).exists()){
        error "\n\n========\n\nERROR IN NEXTFLOW EXECUTION\n\nINVALID RAW_GENOTYPE_FILE_NAME_CONF PARAMETER IN linkage.config FILE (DOES NOT EXIST): ${RAW_GENOTYPE_FILE_NAME_CONF}\nIF POINTING TO A DISTANT SERVER, CHECK THAT IT IS MOUNTED\n\n========\n\n"
    }else{
        RAW_GENOTYPE_FILE_NAME_CONF_ch = Channel.fromPath("${RAW_INPUT_DIR_CONF}/${RAW_GENOTYPE_FILE_NAME_CONF}", checkIfExists: false)
        //TEMPO_GENOTYPE_FILE_NAME = file(RAW_INPUT_DIR_CONF+"/"+RAW_GENOTYPE_FILE_NAME_CONF).baseName
    }
    if( ! file(RAW_INPUT_DIR_CONF+"/"+RAW_FREQ_FILE_NAME_CONF).exists()){
        error "\n\n========\n\nERROR IN NEXTFLOW EXECUTION\n\nINVALID RAW_FREQ_FILE_NAME_CONF PARAMETER IN linkage.config FILE (DOES NOT EXIST): ${RAW_FREQ_FILE_NAME_CONF}\nIF POINTING TO A DISTANT SERVER, CHECK THAT IT IS MOUNTED\n\n========\n\n"
    }else{
        RAW_FREQ_FILE_NAME_CONF_ch = Channel.fromPath("${RAW_INPUT_DIR_CONF}/${RAW_FREQ_FILE_NAME_CONF}", checkIfExists: false)
    }
   if( ! file(RAW_INPUT_DIR_CONF+"/"+RAW_MAP_FILE_NAME_CONF).exists()){
        error "\n\n========\n\nERROR IN NEXTFLOW EXECUTION\n\nINVALID RAW_MAP_FILE_NAME_CONF PARAMETER IN linkage.config FILE (DOES NOT EXIST): ${RAW_MAP_FILE_NAME_CONF}\nIF POINTING TO A DISTANT SERVER, CHECK THAT IT IS MOUNTED\n\n========\n\n"
    }else{
        RAW_MAP_FILE_NAME_CONF_ch = Channel.fromPath("${RAW_INPUT_DIR_CONF}/${RAW_MAP_FILE_NAME_CONF}", checkIfExists: false)
    }
   if( ! file(RAW_INPUT_DIR_CONF+"/"+RAW_PEDIGREE_FILE_NAME_CONF).exists()){
        error "\n\n========\n\nERROR IN NEXTFLOW EXECUTION\n\nINVALID RAW_PEDIGREE_FILE_NAME_CONF PARAMETER IN linkage.config FILE (DOES NOT EXIST): ${RAW_PEDIGREE_FILE_NAME_CONF}\nIF POINTING TO A DISTANT SERVER, CHECK THAT IT IS MOUNTED\n\n========\n\n"
    }else{
        RAW_PEDIGREE_FILE_NAME_CONF_ch = Channel.fromPath("${RAW_INPUT_DIR_CONF}/${RAW_PEDIGREE_FILE_NAME_CONF}", checkIfExists: false)
    }
   if( ! file(RAW_INPUT_DIR_CONF+"/"+human_chr_info).exists()){
        error "\n\n========\n\nERROR IN NEXTFLOW EXECUTION\n\nINVALID human_chr_info PARAMETER IN linkage.config FILE (DOES NOT EXIST): ${human_chr_info}\nIF POINTING TO A DISTANT SERVER, CHECK THAT IT IS MOUNTED\n\n========\n\n"
    }else{
        human_chr_info_ch = Channel.fromPath("${RAW_INPUT_DIR_CONF}/${human_chr_info}", checkIfExists: false)
    }
    if( ! IID_IN_GROUP_CONF in String){
        error "\n\n========\n\nERROR IN NEXTFLOW EXECUTION\n\nINVALID IID_IN_GROUP_CONF PARAMETER IN linkage.config FILE:\n${IID_IN_GROUP_CONF}\nMUST BE A STRING\n\n========\n\n"
    }
   if( ! file(BASH_FUNCTIONS_CONF).exists()){
        error "\n\n========\n\nERROR IN NEXTFLOW EXECUTION\n\nINVALID BASH_FUNCTIONS_CONF PARAMETER IN linkage.config FILE (DOES NOT EXIST): ${BASH_FUNCTIONS_CONF}\nIF POINTING TO A DISTANT SERVER, CHECK THAT IT IS MOUNTED\n\n========\n\n"
    }else{
        BASH_FUNCTIONS_CONF_ch = Channel.fromPath("${BASH_FUNCTIONS_CONF}", checkIfExists: false)
    }
   if( ! file(r_main_functions_conf).exists()){
        error "\n\n========\n\nERROR IN NEXTFLOW EXECUTION\n\nINVALID r_main_functions_conf PARAMETER IN linkage.config FILE (DOES NOT EXIST): ${r_main_functions_conf}\nIF POINTING TO A DISTANT SERVER, CHECK THAT IT IS MOUNTED\n\n========\n\n"
    }else{
        r_main_functions_conf_ch = Channel.fromPath("${r_main_functions_conf}", checkIfExists: false)
    }
   if( ! file(r_check_lod_gael_conf).exists()){
        error "\n\n========\n\nERROR IN NEXTFLOW EXECUTION\n\nINVALID r_check_lod_gael_conf PARAMETER IN linkage.config FILE (DOES NOT EXIST): ${r_check_lod_gael_conf}\nIF POINTING TO A DISTANT SERVER, CHECK THAT IT IS MOUNTED\n\n========\n\n"
    }else{
        r_check_lod_gael_conf_ch = Channel.fromPath("${r_check_lod_gael_conf}", checkIfExists: false)
    }
   if( ! file(r_clean_lod_gael_conf).exists()){
        error "\n\n========\n\nERROR IN NEXTFLOW EXECUTION\n\nINVALID r_clean_lod_gael_conf PARAMETER IN linkage.config FILE (DOES NOT EXIST): ${r_clean_lod_gael_conf}\nIF POINTING TO A DISTANT SERVER, CHECK THAT IT IS MOUNTED\n\n========\n\n"
    }else{
        r_clean_lod_gael_conf_ch = Channel.fromPath("${r_clean_lod_gael_conf}", checkIfExists: false)
    }
   if( ! file(r_lod_files_assembly_conf).exists()){
        error "\n\n========\n\nERROR IN NEXTFLOW EXECUTION\n\nINVALID r_lod_files_assembly_conf PARAMETER IN linkage.config FILE (DOES NOT EXIST): ${r_lod_files_assembly_conf}\nIF POINTING TO A DISTANT SERVER, CHECK THAT IT IS MOUNTED\n\n========\n\n"
    }else{
        r_lod_files_assembly_conf_ch = Channel.fromPath("${r_lod_files_assembly_conf}", checkIfExists: false)
    }
   if( ! file(r_custom_lod_graph_gael_conf).exists()){
        error "\n\n========\n\nERROR IN NEXTFLOW EXECUTION\n\nINVALID r_custom_lod_graph_gael_conf PARAMETER IN linkage.config FILE (DOES NOT EXIST): ${r_custom_lod_graph_gael_conf}\nIF POINTING TO A DISTANT SERVER, CHECK THAT IT IS MOUNTED\n\n========\n\n"
    }else{
        r_custom_lod_graph_gael_conf_ch = Channel.fromPath("${r_custom_lod_graph_gael_conf}", checkIfExists: false)
    }

   if( ! file(r_info_files_assembly_conf).exists()){
        error "\n\n========\n\nERROR IN NEXTFLOW EXECUTION\n\nINVALID r_info_files_assembly_conf PARAMETER IN linkage.config FILE (DOES NOT EXIST): ${r_info_files_assembly_conf}\nIF POINTING TO A DISTANT SERVER, CHECK THAT IT IS MOUNTED\n\n========\n\n"
    }else{
        r_info_files_assembly_conf_ch = Channel.fromPath("${r_info_files_assembly_conf}", checkIfExists: false)
    }
   if( ! file(r_custom_info_graph_gael_conf).exists()){
        error "\n\n========\n\nERROR IN NEXTFLOW EXECUTION\n\nINVALID r_custom_info_graph_gael_conf PARAMETER IN linkage.config FILE (DOES NOT EXIST): ${r_custom_info_graph_gael_conf}\nIF POINTING TO A DISTANT SERVER, CHECK THAT IT IS MOUNTED\n\n========\n\n"
    }else{
        r_custom_info_graph_gael_conf_ch = Channel.fromPath("${r_custom_info_graph_gael_conf}", checkIfExists: false)
    }
   if( ! file(alohomora_bch_conf).exists()){
        error "\n\n========\n\nERROR IN NEXTFLOW EXECUTION\n\nINVALID alohomora_bch_conf PARAMETER IN linkage.config FILE (DOES NOT EXIST): ${alohomora_bch_conf}\nIF POINTING TO A DISTANT SERVER, CHECK THAT IT IS MOUNTED\n\n========\n\n"
    }else{
        alohomora_bch_conf_ch = Channel.fromPath("${alohomora_bch_conf}", checkIfExists: false)
    }


    // below : those variable are already used in the config file. Thus, to late to check them. And not possible to check inside the config file
    // system_exec
    // out_ini
    print("\n\nRESULT DIRECTORY: ${out_path}")
    print("\n\nWARNING: PARAMETERS ALREADY INTERPRETED IN THE .config FILE:")
    print("    system_exec: ${system_exec}")
    print("    out_path: ${out_path_ini}")
    if("${system_exec}" != "local"){
        print("    queue: ${queue}")
        print("    qos: ${qos}")
        print("    add_options: ${add_options}")
    }
    print("\n\n")

    //////// end Checks


    //////// Variable modification


    //////// end Variable modification

    //////// Main

    workflowParam(
        modules
    )

    checking(
        RAW_GENOTYPE_FILE_NAME_CONF_ch, 
        RAW_FREQ_FILE_NAME_CONF_ch, 
        RAW_MAP_FILE_NAME_CONF_ch, 
        RAW_PEDIGREE_FILE_NAME_CONF_ch, 
        BASH_FUNCTIONS_CONF_ch,
        r_main_functions_conf_ch,
        r_check_lod_gael_conf_ch
    )

    cleaning(
        RAW_GENOTYPE_FILE_NAME_CONF_ch, 
        RAW_FREQ_FILE_NAME_CONF_ch, 
        RAW_MAP_FILE_NAME_CONF_ch, 
        RAW_PEDIGREE_FILE_NAME_CONF_ch, 
        r_main_functions_conf_ch,
        r_check_lod_gael_conf_ch,
        r_clean_lod_gael_conf_ch,
        checking.out.wait_ch
    )

    splitting(
        cleaning.out.genotype_ch, 
        cleaning.out.freq_ch, 
        cleaning.out.map_ch, 
        cleaning.out.pedigree_ch,  
        IID_IN_GROUP_CONF
    )

//splitting.out.group_dir_ch.flatten().view()

    alohomora(
        splitting.out.group_dir_ch.flatten(), // flatten split the list into several objects (required for parallelization)
        r_main_functions_conf_ch.first(),
        r_check_lod_gael_conf_ch.first(),
        alohomora_bch_conf_ch.first(),
    )

//alohomora.out.chr_dir_ch.transpose().view()

    pre_merlin(
        alohomora.out.chr_dir_ch.transpose(),
        bit_nb // transpose is used because chr_dir_ch is a single group_name associated with 23 path, three times (3 groups). Thus, transpose makes one group_name associated with 23 path, three times -> 69 channes
    )

//pre_merlin.out.chr_dir_ch2.view()

    merlin(
        pre_merlin.out.chr_dir_ch2, // 
        MERLIN_ANALYSE_OPTION_CONF,
        MERLIN_PARAM_CONF,
        bit_nb
    )

//merlin.out.group_name_ch.merge(merlin.out.lod_ch).view() // merge do [Group2, /mnt/c/Users/Gael/Documents/Git_projects/linkage_analysis/work/33/001c85880ea771d44900f6f094d64b/lod_Group2_c13_merlin-parametric.tbl]
//merlin.out.lod_ch.collect().view() //

    merlin.out.lod_ch.count().subscribe { n -> if ( n == 0 ){error "\n\n========\n\nERROR IN NEXTFLOW EXECUTION\n\n0 LODSCORE FILE RETURNED BY THE merlin PROCESS\n\n========\n\n"}}
    merlin.out.lod_ch.count().subscribe { n -> if ( n == 0 ){error "\n\n========\n\nERROR IN NEXTFLOW EXECUTION\n\n0 MAP FILE RETURNED BY THE merlin PROCESS\n\n========\n\n"}}

    lod_files_assembly(
        merlin.out.lod_ch.collect(), // collect is used to get the 69 channels made of path from lod.ch into a single list with 69 path
        merlin.out.map_ch.collect(),
        splitting.out.group_dir_ch.flatten().count(), // count the number of groups and return a single value. Flatten() used otherwise a single list and thus return 1
        r_main_functions_conf_ch,
        r_lod_files_assembly_conf
    )

    custom_lod_graph(
        lod_files_assembly.out.full_ch,
        r_custom_lod_graph_gael_conf,
        r_main_functions_conf_ch,
        human_chr_info_ch, 
        MERLIN_ANALYSE_OPTION_CONF,
        MERLIN_PARAM_CONF,
        MERLIN_DISPLAY_CHROMO_CONF,
        MERLIN_LOD_CUTOFF_CONF
    )

    merlin.out.info_ch.count().subscribe { n -> if ( n == 0 ){error "\n\n========\n\nERROR IN NEXTFLOW EXECUTION\n\n0 INFO FILE RETURNED BY THE merlin PROCESS\n\n========\n\n"}}

    info_files_assembly(
        merlin.out.info_ch.collect(), // collect is used to get the 69 channels made of path from lod.ch into a single list with 69 path
        merlin.out.map_ch.collect(),
        splitting.out.group_dir_ch.flatten().count(), // count the number of groups and return a single value. Flatten() used otherwise a single list and thus return 1
        r_main_functions_conf_ch,
        r_info_files_assembly_conf
    )

    custom_info_graph(
        info_files_assembly.out.full_info_ch,
        r_custom_info_graph_gael_conf,
        r_main_functions_conf_ch,
        human_chr_info_ch, 
        MERLIN_ANALYSE_OPTION_CONF,
        MERLIN_PARAM_CONF,
        MERLIN_DISPLAY_CHROMO_CONF,
        MERLIN_LOD_CUTOFF_CONF
    )

    backup(
        config_file, 
        log_file
    )
}

    //////// end Main


//////// end Processes
