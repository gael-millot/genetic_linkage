#!/bin/bash -uel # shebang

################################################################
##                                                            ##
##     LITTLE BASH FUNCTIONS v2.0                             ##
##                                                            ##
##     Gael A. Millot                                         ##
##                                                            ##
##                                                            ##
##                                                            ##
################################################################



function show_time_fun () {
    # DESCRIPTION
        # convert delay in seconds into secondes, minutes, hours, etc., depending of the number of seconds
    # ARGUMENTS
        # $0: name of the function
        # $1: first argument, ie, delay as number
    # RETURN OUTPUT
        # 0: converted delay
        # 1: error in $1
    # OUTPUT
        # converted delay
    # EXAMPLES
        # show_time_fun 125648
    # argument checking
    if [[ -z $1 ]]; then
        echo -e "\n### ERROR ###  ARGUMENT 1 REQUIRED\n"
        return 1
        exit 1
    fi
    # main code
    local num=$1 #to set the variable as local, otherwise global
    local min=0
    local hour=0
    local day=0
    if((num>59));then
        ((sec=num%60))
        ((num=num/60))
        if((num>59));then
            ((min=num%60))
            ((num=num/60))
            if((num>23));then
                ((hour=num%24))
                ((day=num/24))
            else
                ((hour=num))
            fi
        else
            ((min=num))
        fi
    else
        ((sec=num))
    fi
    echo "$day"d "$hour"h "$min"m "$sec"s
    return 0
}



function test_tab_in_file_fun () {
    # DESCRIPTION
        # test if tabulations are present in a file
    # WARNING
        # I had to use a global variable file_pattern_detection_fun_RETURN and not a local one to be able to deal with the check.sh file in genetic_linkage project
    # ARGUMENTS
        # $0: name of the function
        # $1: first argument, ie file name and path
    # RETURN OUTPUT
        # test_tab_in_file_fun_RETURN=0: tabulation detected
        # test_tab_in_file_fun_RETURN=1: error in $1
        # test_tab_in_file_fun_RETURN=2: no tabulation detected
    # EXAMPLES
        # test_tab_in_file_fun /cygdrive/c/Users/Gael/Desktop/Archive_Guillaume/Group1/freq
        # test_tab_in_file_fun /cygdrive/c/Users/Gael/Desktop/Archive_Guillaume/Group1/pedfile1.pro
    # argument checking
    if [[ -z $1 ]]; then
        echo -e "\n### test_tab_in_file_fun ERROR ###  ARGUMENT 1 REQUIRED\n"
        test_tab_in_file_fun_RETURN=1
        return 0
    fi
    if [[ ! -f $1 ]]; then
        echo -e "\n### test_tab_in_file_fun ERROR ###  $1 FILE NOT PRESENT IN `dirname $1`\n"
        test_tab_in_file_fun_RETURN=1
        return 0
    fi
    # main code
    local TEMPO_TAB_COUNT=$(grep -o $'\t' $1 | wc -l) # for tabulation problem in bash and grep, see https://askubuntu.com/questions/53071/how-to-grep-for-tabs-without-using-literal-tabs-and-why-does-t-not-work
    if [[ $TEMPO_TAB_COUNT == 0 ]] ; then
        echo -e "\n### test_tab_in_file_fun ERROR: NO TABULATIONS DETECTED IN $1\n"
        test_tab_in_file_fun_RETURN=2
        return 0
    else
        echo -e "\ntest_tab_in_file_fun MESSAGE: TABULATIONS DETECTED IN $1 AS EXPECTED\n"
        test_tab_in_file_fun_RETURN=0
        return 0
    fi
}



function test_space_in_file_fun () {
    # DESCRIPTION
        # test if spaces are present in a file
    # WARNING
        # I had to use a global variable file_pattern_detection_fun_RETURN and not a local one to be able to deal with the check.sh file in genetic_linkage project
    # ARGUMENTS
        # $0: name of the function
        # $1: first argument, ie file name and path
    # RETURN OUTPUT
        # test_space_in_file_fun_RETURN=0: space detected
        # test_space_in_file_fun_RETURN=1: error in $1
        # test_space_in_file_fun_RETURN=2: no space detected
    # EXAMPLES
        # test_space_in_file_fun /cygdrive/c/Users/Gael/Desktop/Archive_Guillaume/Group1/freq
        # test_space_in_file_fun /cygdrive/c/Users/Gael/Desktop/Archive_Guillaume/Group1/pedfile1.pro
    # argument checking
    if [[ -z $1 ]]; then
        echo -e "\n### test_space_in_file_fun ERROR ###  ARGUMENT 1 REQUIRED\n"
        test_space_in_file_fun_RETURN=1
        return 0
    fi
    if [[ ! -f $1 ]]; then
        echo -e "\n### test_space_in_file_fun ERROR ###  $1 FILE NOT PRESENT IN `dirname $1`\n"
        test_space_in_file_fun_RETURN=1
        return 0
    fi
    # main code
    local TEMPO_SPACE_COUNT=$(grep -o ' ' $1 | wc -l)
    if [[ $TEMPO_SPACE_COUNT == 0 ]] ; then
        echo -e "\ntest_space_in_file_fun MESSAGE: NO SPACE DETECTED IN $1\n"
        test_space_in_file_fun_RETURN=2
        return 0
    else
        echo -e "\ntest_space_in_file_fun MESSAGE: ${TEMPO_SPACE_COUNT} SPACES DETECTED IN $1\n"
        test_space_in_file_fun_RETURN=0
        return 0
    fi
}



function space_replacement_in_file_fun () {
    # DESCRIPTION
        # replace each block of succesive spaces by a single character string (default: _._) and save in -o (by default $1_replace)
    # WARNING
        # I had to use a global variable file_pattern_detection_fun_RETURN and not a local one to be able to deal with the check.sh file in genetic_linkage project
    # ARGUMENTS
        # $0: name of the function
        # -i or --input:   file name and path
        # -o or --output:  output file in which problematic lines are printed or message saying OK. If -o specified, the file must not exists.
        #                  IF -o not specified, the file name is -i_replace and must not already exists in -i location
        # -r or --replace: character string replacement (default "_._" if not specified)
    # RETURN OUTPUT
        # space_replacement_in_file_fun_RETURN=0: -i saved in -o then spaces replaced in -o
        # space_replacement_in_file_fun_RETURN=1: error in options
        # space_replacement_in_file_fun_RETURN=2: no space detected 
    # EXAMPLES
        # space_replacement_in_file_fun -i /cygdrive/c/Users/Gael/Desktop/Archive_Guillaume/Group1/freq
        # space_replacement_in_file_fun -i /cygdrive/c/Users/Gael/Desktop/Archive_Guillaume/Group1/Group1.txt
        # space_replacement_in_file_fun -i /cygdrive/c/Users/Gael/Desktop/Archive_Guillaume/Group1/pedfile1.pro
    # argument checking
    function verif {
    # ??? if the element start by -, then go one step before. It is to deal with options with and without arguments
        if [[ $1 = -* ]] ; then
            ((OPTIND--)) # or ((OPTIND-1)) ?
        fi
    }
    local OPTIND OPTION i o r INPUT_FUN OUTPUT_FUN REPLACE_FUN
    while getopts ":i:o:r:" OPTION ; do
        # add : after the option name to specify that something is required (-h has nothing required after)
        # the first : before h is to induce getopts switching to "silent error reporting mode" (disable annoying messages).
        case $OPTION in 
            i)    verif $OPTARG ; INPUT_FUN=$OPTARG ;;
            o)    verif $OPTARG ; OUTPUT_FUN=$OPTARG  ;;
            r)    verif $OPTARG ; REPLACE_FUN=$OPTARG  ;;
            \?)  echo -e "\n### space_replacement_in_file_fun ERROR ### INVALID OPTION\n" ; return 1 ;;
            :)  echo -e "\n### space_replacement_in_file_fun ERROR ### OPTION -${OPTARG} REQUIRES AN ARGUMENT\n" ; return 1 ;;
        esac
    done
    shift $((OPTIND-1))

    if [[ -z $INPUT_FUN ]]; then
        echo -e "\n### space_replacement_in_file_fun ERROR ###  OPTION -i REQUIRED\n"
        space_replacement_in_file_fun_RETURN=1
        return 0
    elif [[ ! -f $INPUT_FUN ]]; then
        echo -e "\n### space_replacement_in_file_fun ERROR ###  ${INPUT_FUN} FILE NOT PRESENT IN `dirname $INPUT_FUN`\n"
        space_replacement_in_file_fun_RETURN=1
        return 0
    fi
    if [[ -z $OUTPUT_FUN ]]; then
        local OUTPUT_FUN=${INPUT_FUN}_replace
    fi
    if [[ -f $OUTPUT_FUN ]]; then
        echo -e "\n### space_replacement_in_file_fun ERROR ### ${OUTPUT_FUN} FILE ALREADY EXISTS\n"
        space_replacement_in_file_fun_RETURN=1
        return 0
    fi
    if [[ -z $REPLACE_FUN ]]; then
        local REPLACE_FUN="_._"
    fi
    # main code
    local TEMPO_SPACE_COUNT=$(grep -o ' \+' $INPUT_FUN | wc -l) # \ \+ from 1 to n spaces. Beware: \ * is from 0 to n
    if [[ $TEMPO_SPACE_COUNT == 0 ]] ; then
        echo -e "\nspace_replacement_in_file_fun MESSAGE: NO SPACE REPLACED SINCE NO SPACE DETECTED IN ${INPUT_FUN}\n"
        space_replacement_in_file_fun_RETURN=2
        return 0
    else
        echo -e "\nspace_replacement_in_file_fun MESSAGE: ${INPUT_FUN} SAVED IN ${OUTPUT_FUN} AND ${TEMPO_SPACE_COUNT} SPACES REPLACED BY ${REPLACE_FUN} IN ${OUTPUT_FUN}\n"
        cat $INPUT_FUN > $OUTPUT_FUN # save the initial file
        sed -i "s/\ \+/$REPLACE_FUN/g" $OUTPUT_FUN # space replacement by _._ in file
        space_replacement_in_file_fun_RETURN=0
        return 0
    fi
}



function file_pattern_detection_fun () {
    # DESCRIPTION
        # identify the lines of a file that contain a pattern
    # WARNING
        # I had to use a global variable file_pattern_detection_fun_RETURN and not a local one to be able to deal with the check.sh file in genetic_linkage project
    # ARGUMENTS
        # $0: name of the function
        # -i or --input:            file name and path
        # -o or --patternoutput:    output file containing the lines with the pattern. The first column is the line number of -i
        #                           If -o specified, the file must not exists.
        #                           IF -o not specified, the file name is -i_pattern and must not already exists at -i location
        # -c or --cleanoutput:      output file containing the lines without the pattern.
        #                           If -c specified, the file must not exists.
        #                           IF -c not specified, the file name is -i_wo_pattern and must not already exists at -i location
        # -d or --detect:           pattern (default "^#" if not specified, meaning detection of lines starting by #). Any regex between quotes
    # RETURN OUTPUT
        # file_pattern_detection_fun_RETURN=0: at least one line contains the pattern -> saved in -o
        # file_pattern_detection_fun_RETURN=1: error in options
        # file_pattern_detection_fun_RETURN=2: no pattern detected 
    # EXAMPLES
        # file_pattern_detection_fun -i /cygdrive/c/Users/Gael/Desktop/Archive_Guillaume/Group1/pedfile1.pro -d "^#|^$" # line starting by #or empty line
    # argument checking
    function verif {
        if [[ $1 = -* ]] ; then
            ((OPTIND--)) # or ((OPTIND-1)) ?
        fi
    }
    local OPTIND OPTION i o c d INPUT_FUN OUTPUT_FUN OUTPUT_WOPATTERN_FUN CHARACTER_FUN RETURN
    while getopts ":i:o:c:d:" OPTION ; do
        # add : after the option name to specify that something is required (-h has nothing required after)
        # the first : before h is to induce getopts switching to "silent error reporting mode" (disable annoying messages).
        case $OPTION in 
            i)    verif $OPTARG ; INPUT_FUN=$OPTARG ;;
            o)    verif $OPTARG ; OUTPUT_FUN=$OPTARG  ;;
            c)    verif $OPTARG ; OUTPUT_WOPATTERN_FUN=$OPTARG  ;;
            d)    verif $OPTARG ; CHARACTER_FUN=$OPTARG  ;;
            \?)  echo -e "\n### file_pattern_detection_fun ERROR ### INVALID OPTION\n" ; RETURN=1 ; return 0 ;;
            :)  echo -e "\n### file_pattern_detection_fun ERROR ### OPTION -${OPTARG} REQUIRES AN ARGUMENT\n" ; RETURN=1 ; return 0 ;;
        esac
    done
    shift $((OPTIND-1))

    if [[ -z $INPUT_FUN ]]; then
        echo -e "\n### file_pattern_detection_fun ERROR ###  OPTION -i REQUIRED\n"
        file_pattern_detection_fun_RETURN=1
        return 0
    elif [[ ! -f $INPUT_FUN ]]; then
        echo -e "\n### file_pattern_detection_fun ERROR ###  ${INPUT_FUN} FILE NOT PRESENT IN `dirname $INPUT_FUN`\n"
        file_pattern_detection_fun_RETURN=1
        return 0
    fi
    if [[ -z $OUTPUT_FUN ]]; then
        local OUTPUT_FUN=${INPUT_FUN}_pattern
    fi
    if [[ -f $OUTPUT_FUN ]]; then
        echo -e "\n### file_pattern_detection_fun ERROR ### ${OUTPUT_FUN} FILE ALREADY EXISTS\n"
        file_pattern_detection_fun_RETURN=1
        return 0
    fi
    if [[ -z $OUTPUT_WOPATTERN_FUN ]]; then
        local OUTPUT_WOPATTERN_FUN=${INPUT_FUN}_wo_pattern
    fi
    if [[ -f $OUTPUT_WOPATTERN_FUN ]]; then
        echo -e "\n### file_pattern_detection_fun ERROR ### ${OUTPUT_WOPATTERN_FUN} FILE ALREADY EXISTS\n"
        file_pattern_detection_fun_RETURN=1
        return 0
    fi
    if [[ -z $CHARACTER_FUN ]]; then
        local CHARACTER_FUN="^#"
    fi
    # main code
    awk -F '\t' -v var1=$CHARACTER_FUN 'BEGIN{OFS="\t"} {if($0 ~ var1){print NR, $0}}' $INPUT_FUN >> $OUTPUT_FUN
    awk -F '\t' -v var1=$CHARACTER_FUN 'BEGIN{OFS="\t"} {if($0 !~ var1){print $0}}' $INPUT_FUN >> $OUTPUT_WOPATTERN_FUN
    # sed -r "/$CHARACTER_FUN}/d" $INPUT_FUN > $OUTPUT_WOPATTERN_FUN # do note work with empty lines grrr. use -r for extended regex, otherwise, do not work
    if [[ ! -s $OUTPUT_FUN ]] ; then # -s is non empty file
        rm $OUTPUT_FUN
        rm $OUTPUT_WOPATTERN_FUN
        echo -e "\nfile_pattern_detection_fun MESSAGE: NO $CHARACTER_FUN PATTERN DETECTED IN $INPUT_FUN\n"
        file_pattern_detection_fun_RETURN=2
        return 0
    else
        echo -e "\nfile_pattern_detection_fun MESSAGE: PATTERN $CHARACTER_FUN DETECTED IN $INPUT_FUN\n"
        file_pattern_detection_fun_RETURN=0
        return 0
    fi
}



function test_column_nb_perline_in_file_fun () {
    # DESCRIPTION
        # test if the number of column is identical for each line of a file
    # WARNING
        # I had to use a global variable file_pattern_detection_fun_RETURN and not a local one to be able to deal with the check.sh file in genetic_linkage project
    # ARGUMENTS
        # $0: name of the function
        # -i or --input:            file name and path. Must be tab delimited
        # -o or --output:           output file in which problematic lines are printed (lines with different number of columns than non empty first line).
        #                           If -o specified, the file must not exists.
        #                           IF -o not specified, by default, the file name is -i_error_line and must not already exists at -i location
        # -c or --cleanoutput:      output file containing the lines without the problematic lines.
        #                           If -c specified, the file must not exists.
        #                           IF -c not specified, the file name is -i_wo_error_line and must not already exists at -i location
        # -d or --detect:           file separator pattern to count the number of columns (default "\t" if not specified). Any regex between quotes
    # RETURN OUTPUT
        # test_column_nb_perline_in_file_fun_RETURN=0: no difference in column number for each line of -i
        # test_column_nb_perline_in_file_fun_RETURN=1: error in options
        # test_column_nb_perline_in_file_fun_RETURN=2: error: empty first line
        # test_column_nb_perline_in_file_fun_RETURN=3: only the first line has a different column number from the rest of the $1 file
        # test_column_nb_perline_in_file_fun_RETURN=4: error lines (difference in column number in -i lines compared to 1st line of -i)  -> printed in -o. First column is line number of -i. No error lines printed in -c
    # EXAMPLE
        # test_column_nb_perline_in_file_fun -i /cygdrive/c/Users/Gael/Desktop/Archive_Guillaume/Group1/freq
        # test_column_nb_perline_in_file_fun -i /cygdrive/c/Users/Gael/Desktop/Archive_Guillaume/Group1/pedfile1.pro_wo_pattern
    # argument checking
    function verif {
        if [[ $1 = -* ]] ; then
            ((OPTIND--)) # or ((OPTIND-1)) ?
        fi
    }
    local OPTIND OPTION i o d l INPUT_FUN OUTPUT_ERROR_FUN OUTPUT_WO_ERROR_FUN CHARACTER_FUN
    while getopts ":i:o:c:d:" OPTION ; do
        # add : after the option name to specify that something is required (-h has nothing required after)
        # the first : before h is to induce getopts switching to "silent error reporting mode" (disable annoying messages).
        case $OPTION in 
            i)    verif $OPTARG ; INPUT_FUN=$OPTARG ;;
            o)    verif $OPTARG ; OUTPUT_ERROR_FUN=$OPTARG  ;;
            c)    verif $OPTARG ; OUTPUT_WO_ERROR_FUN=$OPTARG  ;;
            d)    verif $OPTARG ; CHARACTER_FUN=$OPTARG  ;;
            \?)  echo -e "\n### test_column_nb_perline_in_file_fun ERROR ### INVALID OPTION\n" ; return 1 ;;
            :)  echo -e "\n### test_column_nb_perline_in_file_fun ERROR ### OPTION -${OPTARG} REQUIRES AN ARGUMENT\n" ; return 1 ;;
        esac
    done
    shift $((OPTIND-1))

    if [[ -z $INPUT_FUN ]]; then
        echo -e "\n### test_column_nb_perline_in_file_fun ERROR ###  OPTION -i REQUIRED\n"
        test_column_nb_perline_in_file_fun_RETURN=1
        return 0
    elif [[ ! -f $INPUT_FUN ]]; then
        echo -e "\n### test_column_nb_perline_in_file_fun ERROR ###  ${INPUT_FUN} FILE NOT PRESENT IN `dirname $INPUT_FUN`\n"
        test_column_nb_perline_in_file_fun_RETURN=1
        return 0
    fi
    if [[ -z $OUTPUT_ERROR_FUN ]]; then
        local OUTPUT_ERROR_FUN=${INPUT_FUN}_error_line
    fi
    if [[ -f $OUTPUT_ERROR_FUN ]]; then
        echo -e "\n### test_column_nb_perline_in_file_fun ERROR ### ${OUTPUT_ERROR_FUN} FILE ALREADY EXISTS\n"
        test_column_nb_perline_in_file_fun_RETURN=1
        return 0
    fi
    if [[ -z $OUTPUT_WO_ERROR_FUN ]]; then
        local OUTPUT_WO_ERROR_FUN=${INPUT_FUN}_wo_error_line
    fi
    if [[ -f $OUTPUT_WO_ERROR_FUN ]]; then
        echo -e "\n### test_column_nb_perline_in_file_fun ERROR ### ${OUTPUT_WO_ERROR_FUN} FILE ALREADY EXISTS\n"
        test_column_nb_perline_in_file_fun_RETURN=1
        return 0
    fi
    if [[ -z $CHARACTER_FUN ]]; then
        local CHARACTER_FUN="\t"
    fi
    # if [[ ! $(type -t test_tab_in_file_fun) == "function" ]]; then
    #     echo -e "\n### ERROR ###  test_tab_in_file_fun NOT AVAILABLE IN THE GLOBAL ENVIRONMENT\n"
    #    return 2
    # fi
    # main code
        echo -e "\ntest_column_nb_perline_in_file_fun MESSAGE: THE FIELD SEPARATOR IS $CHARACTER_FUN\n"
        echo -e "\ntest_column_nb_perline_in_file_fun MESSAGE: THE FIRST LINE OF THE $INPUT_FUN FILE IS:"
        head -1 $INPUT_FUN
        # echo -e "\n"
        local TOTAL_NB_LINES=$(wc -l < "$INPUT_FUN") # total number of lines
        local NB_COL_FIRSTLINE=$(awk -F "$CHARACTER_FUN" 'NR==1{print NF ; exit}' $INPUT_FUN) # recover the number of columns of the first line of a file. NR is the row number (for number of record), NF is the number of columns. $() can be replaced by ``
        # echo -e "NB_COL_FIRSTLINE: $NB_COL_FIRSTLINE\n"
        if [[ -z $NB_COL_FIRSTLINE || $NB_COL_FIRSTLINE == 0 ]] ; then
            echo -e "\n### test_column_nb_perline_in_file_fun ERROR ### THE FIRST LINE OF $INPUT_FUN IS EMPTY: USE file_pattern_detection_fun TO REMOVE EMPTY LINES\n"
            test_column_nb_perline_in_file_fun_RETURN=2
            return 0
        fi
        awk -F "$CHARACTER_FUN" -v var1=$NB_COL_FIRSTLINE 'NF!=var1{print NR, $0}' $INPUT_FUN > ${OUTPUT_ERROR_FUN} # recover the error lines
        awk -F "$CHARACTER_FUN" -v var1=$NB_COL_FIRSTLINE 'NF==var1{print $0}' $INPUT_FUN > $OUTPUT_WO_ERROR_FUN
        # rm $INPUT_FUN
        local NB_ERROR_LINES=$(wc -l < "${OUTPUT_ERROR_FUN}") # number of error lines
        if [[ $NB_ERROR_LINES == 0 ]] ; then
            echo -e "\ntest_column_nb_perline_in_file_fun MESSAGE: NO DIFFERENT COLUMN NUMBER FOUND IN LINES OF ${INPUT_FUN} HAVING $NB_COL_FIRSTLINE COLUMNS IN THE FIRST LINE\n"
            rm ${OUTPUT_ERROR_FUN}
            rm ${OUTPUT_WO_ERROR_FUN}
            test_column_nb_perline_in_file_fun_RETURN=0
            return 0
        elif [[ $NB_ERROR_LINES == $(( ${TOTAL_NB_LINES} - 1 )) ]]; then
            echo -e "\ntest_column_nb_perline_in_file_fun MESSAGE: ONLY THE FIRST LINE HAS A DIFFERENT COLUMN NUMBER FROM THE REST OF THE ${INPUT_FUN} FILE\nTHE FIRST LINE IS:\n$(head -n 1 $INPUT_FUN)"
            rm ${OUTPUT_ERROR_FUN}
            rm ${OUTPUT_WO_ERROR_FUN}
            test_column_nb_perline_in_file_fun_RETURN=3
            return 0
        else
            echo -e "test_column_nb_perline_in_file_fun MESSAGE: ${NB_ERROR_LINES} LINES FOUND IN ${INPUT_FUN} SHOWING A NUMBER OF COLUMN DIFFERENT FROM $NB_COL_FIRSTLINE COLUMNS AS FOUND IN THE FIRST LINE\n" # | tee -a $OUTPUT_ERROR_FUN
            # echo -e "THE PROBLEMATIC LINES ARE:\n" >> $OUTPUT_ERROR_FUN
            if(( ${NB_ERROR_LINES} <= 200 )) ; then # display if less than 200
                echo -e "\ntest_column_nb_perline_in_file_fun MESSAGE: THE PROBLEMATIC LINES ARE:\n"
                cat ${OUTPUT_ERROR_FUN}
                echo -e "\n\n"
            else
                echo -e "\ntest_column_nb_perline_in_file_fun MESSAGE: THE PROBLEMATIC LINES ARE MORE THAN 200 -> ONLY PRINTED IN THE $OUTPUT_ERROR_FUN FILE:\n"
            fi
            test_column_nb_perline_in_file_fun_RETURN=4
            return 0
        fi
}

function single_path_with_regex_fun { # comes from little_bash_functions-v1.0.0/little_bash_functions-v1.0.0.sh
    # DESCRIPTION
        # check that $1 path exists and is single 
    # WARNING
        # do not use set -e !
        # I had to use a global variable file_pattern_detection_fun_RETURN and not a local one to be able to deal with the check.sh file in genetic_linkage project
    # ARGUMENTS
        # $0: name of the function
        # $1: first argument, ie path with regex
    # RETURN OUTPUT
        # single_path_with_regex_fun_RETURN=0: single path detected is valid
        # single_path_with_regex_fun_RETURN=1: error: $1 not provided
        # single_path_with_regex_fun_RETURN=2: error: $2 provided or more than one path detected
        # single_path_with_regex_fun_RETURN=3: single url detected does not exist
        # single_path_with_regex_fun_RETURN=4: single path detected does not exist
    # EXAMPLES
        # single_path_with_regex_fun /cygdrive/c/Users/Gael/Desktop/config_tars_lodscore_gael_2017121[[:digit:]].conf
        # single_path_with_regex_fun /pasteur/homes/gmillot/dyslexia/code_gael/config_tars_lodscore_gael_2017121[[:digit:]].conf
    # argument checking
    if [[ -z $1 ]] ; then
        echo -e "\n### ERROR ###  ARGUMENT 1 REQUIRED IN single_path_with_regex_fun\n"
        single_path_with_regex_fun_RETURN=1
        return 0
    fi
    # main code
    if [[ ! -z $2 ]] ; then
        echo -e "\n### ERROR ###\n1) AT LEAST ARGUMENT 2 PRESENT IN single_path_with_regex_fun WHILE ONLY ONE REQUIRED OR\n2) REGEX PATH RESULT IN SEVERAL RESULTS:\n$@\n"
        single_path_with_regex_fun_RETURN=2
        return 0
    fi
    local ARG1="$1"
    # echo $ARG1 # print ARG1
    local ARG1_ARR=("$ARG1") # conversion to array (split acccording to space). If no corresponding regexp, keep $1 with regexp and length = 1
    # echo ${ARG1_ARR[@]} # print the array
    local ARG1_ARR_LENGTH=$(( ${#ARG1_ARR[@]} - 1 )) # total number of elements in the array
    # echo "LENGTH: $ARG1_ARR_LENGTH" # print the length of the array
    if [[ $ARG1_ARR_LENGTH != 0 ]] ; then
        echo -e "\n### ERROR ### SPECIFIED REGEXP PATH IN single_path_with_regex_fun CORRESPOND TO MORE THAN ONE PATH: ${ARG1_ARR_LENGTH[@]}\n";
        single_path_with_regex_fun_RETURN=2
        return 0
    else
        shopt -s extglob # -s unable global extention, ie the recognition of special global pattern in path, like [[:digit:]]
        if [[  $(echo ${ARG1_ARR[0]} | grep -cE '^http' ) == 1 ]] ; then # -cE to specify extended and -c to return the number of match (here 0 or one only)
            if [[ $(wget ${ARG1_ARR[0]} >/dev/null 2>&1 ; echo $?) != 0 ]] ; then # check the valid url. wget $url >/dev/null 2>&1 prevent any action and print. echo $? print the result of the last command (0 = success, other number = failure)
                echo -e "\n### ERROR ### SPECIFIED URL IN single_path_with_regex_fun DOES NOT EXISTS: ${ARG1_ARR[0]}\n";
                shopt -u extglob # -u disable global extention, ie the recognition of special global pattern in path, like [[:digit:]]
                single_path_with_regex_fun_RETURN=3
                return 0
            fi
        elif [[ ! ( -d ${ARG1_ARR[0]} || -f ${ARG1_ARR[0]} ) ]] ; then
            echo -e "\n### ERROR ### SPECIFIED PATH IN single_path_with_regex_fun DOES NOT EXISTS: ${ARG1_ARR[0]}\n";
            shopt -u extglob # -u disable global extention, ie the recognition of special global pattern in path, like [[:digit:]]
            single_path_with_regex_fun_RETURN=4
            return 0
        else
            shopt -u extglob # -u disable global extention, ie the recognition of special global pattern in path, like [[:digit:]]
            single_path_with_regex_fun_RETURN=0
            return 0
        fi
    fi
}

function var_existence_check_fun {
    # DESCRIPTION
        # check that $1 variable exists
        # $0: name of the function
        # $1: first argument, ie variable name without $
    # WARNING
        # do not use set -e !
        # I had to use a global variable file_pattern_detection_fun_RETURN and not a local one to be able to deal with the check.sh file in genetic_linkage project
    # RETURN OUTPUT
        # var_existence_check_fun_RETURN=0: variable is detected in the environment
        # var_existence_check_fun_RETURN=1: error: $1 not provided
        # var_existence_check_fun_RETURN=2: error: $2 provided or more than one path detected
        # var_existence_check_fun_RETURN=3: variable does not exist
    # EXAMPLES
        #
    # argument checking
    if [[ -z $1 ]] ; then
        echo -e "\n### ERROR ###  ARGUMENT 1 REQUIRED IN var_existence_check_fun\n"
        var_existence_check_fun_RETURN=1
        return 0
    fi
    # main code
    if [[ ! -z $2 ]] ; then
        echo -e "\n### ERROR ###\n1) AT LEAST ARGUMENT 2 PRESENT IN var_existence_check_fun WHILE ONLY ONE REQUIRED OR\n2) REGEX PATH RESULT IN SEVERAL RESULTS:\n$@\n"
        var_existence_check_fun_RETURN=2
        return 0
    fi
    ARG1=$(echo $1) 
    ARG2=$(echo ${!ARG1}) # double because I need to know if the content of $(echo $1) is "" (echo return "" when does not exist)
    if [[ -z "$ARG2" ]] ; then # test if $ARG1 is ""
    var_existence_check_fun_RETURN=3
        return 0
    else
        var_existence_check_fun_RETURN=0
        return 0
    fi
}


function file_exten_verif_name_recov_fun () {
    # DESCRIPTION
        # check the file extension and recover the name of the file without extension
        # See https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
    # WARNING
        # I had to use a global variable file_pattern_detection_fun_RETURN and not a local one to be able to deal with the check.sh file in genetic_linkage project
    # ARGUMENTS
        # $0: name of the function
        # -i or --input:            file name, with or without the path
        # -e or --extensionpattern: character string of the extension, including dot (default ".txt" if not specified). Example: .txt
    # RETURN OUTPUT
        # file_exten_verif_name_recov_fun_RETURN=0: pattern detected and name of the file without the extension printed
        # file_exten_verif_name_recov_fun_RETURN=1: error in options
        # file_exten_verif_name_recov_fun_RETURN=2: extension pattern not detected at the end of the file name
    # EXAMPLES
        # file_exten_verif_name_recov_fun -i /cygdrive/c/Users/Gael/Desktop/Archive_Guillaume_split_initial_data/Famille1/pedfile.pro -e ".pro"
        # VAR1=$(file_exten_verif_name_recov_fun -i /cygdrive/c/Users/Gael/Desktop/Archive_Guillaume_split_initial_data/Famille1/pedfile.pro -e ".pro") ; echo $VAR1
    # argument checking
    function verif {
        if [[ $1 = -* ]] ; then
            ((OPTIND--)) # or ((OPTIND-1)) ?
        fi
    }
    local OPTIND OPTION i e INPUT_FUN PATTERN_FUN
    while getopts ":i:e:" OPTION ; do
        # add : after the option name to specify that something is required (-h has nothing required after)
        # the first : before h is to induce getopts switching to "silent error reporting mode" (disable annoying messages).
        case $OPTION in 
            i)    verif $OPTARG ; INPUT_FUN=$OPTARG ;;
            e)    verif $OPTARG ; PATTERN_FUN=$OPTARG  ;;
            \?)  echo -e "\n### file_exten_verif_name_recov_fun ERROR ### INVALID OPTION\n" ; return 1 ;;
            :)  echo -e "\n### file_exten_verif_name_recov_fun ERROR ### OPTION -${OPTARG} REQUIRES AN ARGUMENT\n" ; return 1 ;;
        esac
    done
    shift $((OPTIND-1))

    if [[ -z $INPUT_FUN ]]; then
        echo -e "\n### file_exten_verif_name_recov_fun ERROR ###  OPTION -i REQUIRED\n"
        file_exten_verif_name_recov_fun_RETURN=1
        return 0
    fi
    if [[ -z $PATTERN_FUN ]]; then
        local PATTERN_FUN=".txt"
    fi

    # main code
    local FILENAME=$(basename -- "${INPUT_FUN}") # recover a file name without path
    local PATTERN_FUN_NCHAR=$(echo ${#PATTERN_FUN}) # recover the number of character of PATTERN_FUN
    if [[ ${FILENAME: -$PATTERN_FUN_NCHAR} != ${PATTERN_FUN} ]] ; then
        echo -e "\nfile_exten_verif_name_recov_fun MESSAGE: NO $PATTERN_FUN EXTENSION PATTERN DETECTED AT THE END OF $INPUT_FUN\n"
        file_exten_verif_name_recov_fun_RETURN=2
        return 0
    else
        # do not write this because print output is assigned to a variable echo -e "\nfile_exten_verif_name_recov_fun MESSAGE: $PATTERN_FUN EXTENSION PATTERN CORRECTLY DETECTED AT THE END OF $INPUT_FUN\n"
        echo ${FILENAME%${PATTERN_FUN}}
        file_exten_verif_name_recov_fun_RETURN=0
        return 0
    fi
}