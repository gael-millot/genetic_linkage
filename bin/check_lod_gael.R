################################################################
##                                                            ##
##     COSEGREGATION FILES CHECKING                           ##
##                                                            ##
##     Gael A. Millot                                         ##
##                                                            ##
##     Version v1                                             ##
##                                                            ##
################################################################


################################ Introduction


# Compatible with R v3.4.1
# Running example in TARS:
  # FILE_PATH=/cygdrive/c/Users/Gael/Documents
  # INPUT_DIR_PATH=/cygdrive/c/Users/Gael/Desktop/Family1_Files_modified_for_R
  # OUTPUT=$INPUT_DIR_PATH/R_file_checking_report.txt ;
  # OUTPUT_ERROR=$INPUT_DIR_PATH/R_file_checking_error.txt ;
  # /cygdrive/c/Program Files/R/R-3.3.3/bin/R.exe $FILE_PATH/Hub\ projects\20170323\ Bourgeron\ Dislexya/check_lod_gael\ 20171215.R $INPUT_DIR_PATH $OUTPUT $OUTPUT_ERROR $INPUT_DIR_PATH/map $INPUT_DIR_PATH/freq $INPUT_DIR_PATH/$INPUT_DIR_NAME.txt $INPUT_DIR_PATH/pedfile.pro $FILE_PATH/R\ source/R_main_gael_functions_20171119.R "notxt"
# Running example in R:
  # FILE_PATH="C:/Users/Gael/Documents"
  # INPUT_DIR_PATH="C:/Users/Gael/Desktop/Family1_Files_modified_for_R"
  # OUTPUT="R_file_checking_report.txt"
  # OUTPUT_ERROR="R_file_checking_error.txt"
  # args <- c(INPUT_DIR_PATH, OUTPUT, OUTPUT_ERROR, paste0(INPUT_DIR_PATH, "/map_clean"), paste0(INPUT_DIR_PATH, "/freq_order"), paste0(INPUT_DIR_PATH, "/genotyping1.txt"), paste0(INPUT_DIR_PATH, "/pedfile1.pro"), paste0(FILE_PATH, "/R source/R_main_gael_functions_20171119.R"), "notxt")




################################ End Introduction


################################ Parameters that need to be set by the user


################ Reinitialization


# cat("TEST")
erase.objects = TRUE # write TRUE to erase all the existing objects in R before starting the algorithm and FALSE otherwise. Beginners should use TRUE
if(erase.objects == TRUE){
  rm(list=ls())
}
erase.graphs = TRUE # write TRUE to erase all the graphic windows in R before starting the algorithm and FALSE otherwise
# cat("TEST2")

################ Import


args <- commandArgs(trailingOnly = TRUE)  # recover arguments written after the call of the Rscript, ie after r_341_conf $check_lod_gael_conf 
tempo.arg.names <- c("path.out", "output_file_name", "output_error_file_name", "genotype", "freq", "map", "pedfile", "r_main_functions", "kind", "optional.text") # objects names exactly in the same order as in the bash code and recovered in args
if(length(args) != length(tempo.arg.names)){
  tempo.cat <- paste0("======== ERROR: THE NUMBER OF ELEMENTS IN args (", length(args),") IS DIFFERENT FROM THE NUMBER OF ELEMENTS IN tempo.arg.names (", length(tempo.arg.names),")\nargs:", paste0(args, collapse = ","), "\ntempo.arg.names:", paste0(tempo.arg.names, collapse = ","))
  stop(tempo.cat)
}
for(i in 1:length(tempo.arg.names)){
  assign(tempo.arg.names[i], args[i])
  # stopifnot(!is.na(file))
}
# dir_path <- dirname(path.vcf.file) # recover the path of path.vcf.file
# filename <- basename(path.vcf.file) # recover the name of the file (end of path.vcf.file)
if(optional.text == "notxt"){
  optional.text <- ""
}
if( ! (kind %in% c("raw", "postclean", "postsplit") & length(kind) == 1) ){
    tempo.cat <- paste0("======== ERROR: THE kind ARGUMENT IN args (", kind,") MUST BE A SINGLE CHARACTER VALUE, EITHER raw, postclean OR postsplit")
    stop(tempo.cat)
}



################ Parameters


decimal.symbol <- "." # for argument dec of read.table function


################################ Sourcing


source(r_main_functions) #
# cat("TEST4")

################################ End Sourcing


################################ Functions

snp_name_in_two_files_fun <- function(snp_data, data1, file_name1, file_name2, txt_output_file_name, table_output_file_name, output_path = path.out, kind_fun = kind, table_limit = 300){
    # AIM:
        # check that snp name are present in two different data frames
    # REQUIRED FUNCTIONS
        # fun.export.data()
    # ARGUMENTS
        # snp_data: data frame containing the rows of data1 (ie, file_name1) that are not in file_name2
        # data1: data frame analyzed
        # file_name1: name of the 1st data frame
        # file_name2: name of the 2nd data fram
        # txt_output_file_name: name of print file
        # table_output_file_name: name of the snp_data saved
        # output_path: directory in which txt_output_file_name and table_output_file_name are saved
        # table_limit: max number of rows of snp_data for printing only 
    # RETURN
        # print messages and write table
    # EXAMPLES
        #
    # argument checking
    # end argument checking
    if(nrow(snp_data) == 0){ # BEWARE: work because snp_data still a data frame. If file_name1 has a single column, snp_data is a vector
        fun.export.data(path = output_path, data = paste0("NO SNP IN THE ", file_name1, " ABSENT IN THE ", file_name2, " FILE"), output = txt_output_file_name, sep = 2)
    }else{
        fun.export.data(path = output_path, data = paste0("NUMBER OF SNP IN THE ", file_name1, " ABSENT IN THE ", file_name2, " FILE: ", nrow(snp_data)), output = txt_output_file_name, sep = 1)
        fun.export.data(path = output_path, data = paste0("PROPORTION OF SNP IN THE ", file_name1, " ABSENT IN THE ", file_name2, " FILE: ", nrow(snp_data) / nrow(data1)), output = txt_output_file_name, sep = 1)
    }
    if(nrow(snp_data) > 0 & nrow(snp_data) <= table_limit){
        fun.export.data(path = output_path, data = paste0("SNP IN THE THE ", file_name1, " ABSENT IN THE ", file_name2, " FILE:"), output = txt_output_file_name, sep = 1)
        fun.export.data(path = output_path, data = snp_data, output = txt_output_file_name, sep = 2) # 
    }else if(nrow(snp_data) > table_limit){
        fun.export.data(path = output_path, data = paste0("SEE THE ", table_output_file_name, " FILE TO HAVE THE SNP IN THE ", file_name1, " ABSENT IN THE ", file_name2, " FILE"), output = txt_output_file_name, sep = 2)
        write.table(snp_data, file = paste0(output_path, "/", kind_fun, "_", table_output_file_name), append = FALSE, quote = FALSE, sep = "\t")
    }
}





################################ End Functions


################################ Main code


################ Ignition


options(scipen = 7)
if(erase.graphs == TRUE){
  graphics.off()
  # par.ini<-par(no.readonly=TRUE) # to recover the initial graphical parameters if required (reset)
  graphics.off()
}


################ Data import


map <- read.table(map, header = TRUE, na.strings = "NA", sep = "\t", dec = decimal.symbol, stringsAsFactors = TRUE, colClasses = c("character", NA, NA ,NA))
freq <- read.table(freq, header = TRUE, na.strings = "NA", sep = "\t", dec = decimal.symbol, stringsAsFactors = TRUE)
genotype <- read.table(genotype, header = TRUE, na.strings = "NA", sep = "\t", dec = decimal.symbol, check.names = FALSE, stringsAsFactors = TRUE) # check.names = FALSE to do not modify column names starting by a number
pedfile <- read.table(pedfile, header = FALSE, na.strings = "NA", sep = "\t", dec = decimal.symbol, stringsAsFactors = TRUE)

if(kind == "raw"){
    empty.geno <- "--"
}else {
   empty.geno <- "NoCall"
}


################ Checking

####### Allele frequency file (freq)

fun.export.data(path = path.out, data = paste0("################ FREQ FILE ################"), output = output_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("################ FREQ FILE ################"), output = output_error_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("THE freq FILE IS: ", args[tempo.arg.names == "freq"]), output = output_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("THE freq FILE IS: ", args[tempo.arg.names == "freq"]), output = output_error_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("######## SCAN:"), output = output_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("INITIAL COLUMN NAMES:"), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = names(freq), output = output_file_name, sep=1)
if(is.null(names(freq)) | identical(names(freq), paste0("X", 1:ncol(freq))) | identical(names(freq), paste0("V", 1:ncol(freq)))){
    tempo <- paste0("### raw_check_lod_gael ERROR ### MANDATORY COLUMN NAMES NOT DETECTED IN FREQ FILE")
    fun.export.data(path = path.out, data = tempo, output = output_file_name, sep = 1)
    fun.export.data(path = path.out, data = tempo, output = output_error_file_name, sep = 1)
    stop(tempo)
}
# Check
tempo <- param_check_fun(data = freq, print = FALSE, class = "data.frame")
if(tempo$problem == TRUE){
    fun.export.data(path = path.out, data = tempo$text, output = output_file_name, sep = 2)
    fun.export.data(path = path.out, data = tempo$text, output = output_error_file_name, sep = 2)
}else{
    fun.export.data(path = path.out, data = paste0(tempo$text, "\nCLASS: \"data.frame\" & NUMBER OF COLUMNS: ", length(freq)), output = output_file_name, sep = 2)
}
for (i in 1:length(freq)){
    if(names(freq)[i] == "Name"){
        tempo <- param_check_fun(data = freq[, i], data.name = paste0(names(freq[i]), "_of_freq"), print = FALSE, class = "factor")
        if(tempo$problem == TRUE){
            fun.export.data(path = path.out, data = tempo$text, output = output_file_name, sep = 2)
            fun.export.data(path = path.out, data = tempo$text, output = output_error_file_name, sep = 2)
        }else{
            fun.export.data(path = path.out, data = paste0(tempo$text, "\nCOLUMN ", i, " MADE OF FACTORS"), output = output_file_name, sep = 2)
        }
    }else if(names(freq)[i] == "Chr"){
        tempo <- param_check_fun(data = freq[, i], data.name = paste0(names(freq[i]), "_of_freq"), print = FALSE, options = c(1:22, "X"))
        if(tempo$problem == TRUE){
            fun.export.data(path = path.out, data = tempo$text, output = output_file_name, sep = 2)
            fun.export.data(path = path.out, data = tempo$text, output = output_error_file_name, sep = 2)
        }else{
            fun.export.data(path = path.out, data = paste0(tempo$text, "\nCOLUMN ", i, " MADE OF SOME OF 1-22 NUMBERS AND X"), output = output_file_name, sep = 2)
        }
    }else if(names(freq)[i] == "Pos"){
        tempo <- param_check_fun(data = freq[, i], data.name = paste0(names(freq[i]), "_of_freq"), print = FALSE, typeof = "integer")
        if(tempo$problem == TRUE){
            fun.export.data(path = path.out, data = tempo$text, output = output_file_name, sep = 2)
            fun.export.data(path = path.out, data = tempo$text, output = output_error_file_name, sep = 2)
        }else{
            fun.export.data(path = path.out, data = paste0(tempo$text, "\nCOLUMN ", i, " MADE OF INTEGERS"), output = output_file_name, sep = 2)
        }
    }else {
        tempo <- param_check_fun(data = freq[, i], data.name = paste0(names(freq[i]), "_of_freq"), print = FALSE, typeof = "double")
        if(tempo$problem == TRUE){
            fun.export.data(path = path.out, data = tempo$text, output = output_file_name, sep = 2)
            fun.export.data(path = path.out, data = tempo$text, output = output_error_file_name, sep = 2)
        }else{
            fun.export.data(path = path.out, data = paste0(tempo$text, "\nCOLUMN ", i, " MADE OF DECIMAL NUMBERS"), output = output_file_name, sep = 2)
        }
    }
}
#end check
tempo <- object_info_fun(data = freq)
fun.export.data(path = path.out, data = paste0("######## BASIC INFORMATION:"), output = output_file_name, sep = 2)
fun.export.data(path = path.out, data = tempo, output = output_file_name, sep = 0)
fun.export.data(path = path.out, data = paste0("NUMBER OF SNP ON CHROMO X: ", length(which(freq[, "Chr"] == "X"))), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = paste0("NUMBER OF SNP ON AUTOSOMES: ", length(which(freq[, "Chr"] != "X"))), output = output_file_name, sep = 2)
# cat("TEST7")

####### map file (map)

fun.export.data(path = path.out, data = paste0("################ map FILE ################"), output = output_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("################ map FILE ################"), output = output_error_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("THE MAP FILE IS: ", args[tempo.arg.names == "map"]), output = output_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("THE MAP FILE IS: ", args[tempo.arg.names == "map"]), output = output_error_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("######## SCAN:"), output = output_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("INITIAL COLUMN NAMES:"), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = names(map), output = output_file_name, sep=1)
if(is.null(names(map)) | identical(names(map), paste0("X", 1:ncol(map))) | identical(names(map), paste0("V", 1:ncol(map)))){
    tempo <- paste0("### raw_check_lod_gael ERROR ### MANDATORY COLUMN NAMES NOT DETECTED IN MAP FILE")
    fun.export.data(path = path.out, data = tempo, output = output_file_name, sep = 1)
    fun.export.data(path = path.out, data = tempo, output = output_error_file_name, sep = 1)
    stop(tempo)
}

# Check
tempo <- param_check_fun(data = map, print = FALSE, class = "data.frame")
if(tempo$problem == TRUE){
    fun.export.data(path = path.out, data = tempo$text, output = output_file_name, sep = 2)
    fun.export.data(path = path.out, data = tempo$text, output = output_error_file_name, sep = 2)
}else{
    fun.export.data(path = path.out, data = paste0(tempo$text, "\nCLASS: \"data.frame\" & NUMBER OF COLUMNS: ", length(map)), output = output_file_name, sep = 2)
}
for (i in 1:length(map)){
    if(names(map)[i] == "Name"){
        tempo <- param_check_fun(data = map[, i], data.name = paste0(names(map[i]), "_of_map"), print = FALSE, class = "factor")
        if(tempo$problem == TRUE){
            fun.export.data(path = path.out, data = tempo$text, output = output_file_name, sep = 2)
            fun.export.data(path = path.out, data = tempo$text, output = output_error_file_name, sep = 2)
        }else{
            fun.export.data(path = path.out, data = paste0(tempo$text, "\nCOLUMN ", i, " MADE OF FACTORS"), output = output_file_name, sep = 2)
        }
    } else if(names(map)[i] == "Chr"){
        tempo <- param_check_fun(data = map[, i], data.name = paste0(names(map[i]), "_of_map"), print = FALSE, options = c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"))
        if(tempo$problem == TRUE){
            fun.export.data(path = path.out, data = tempo$text, output = output_file_name, sep = 2)
            fun.export.data(path = path.out, data = tempo$text, output = output_error_file_name, sep = 2)
        }else{
            fun.export.data(path = path.out, data = paste0(tempo$text, "\nCOLUMN ", i, " MADE OF SOME OF 1-23 NUMBERS"), output = output_file_name, sep = 2)
        }
    } else if(names(map)[i] == "MapInfo"){
        tempo <- param_check_fun(data = map[, i], data.name = paste0(names(map[i]), "_of_map"), print = FALSE, typeof = "integer")
        if(tempo$problem == TRUE){
            fun.export.data(path = path.out, data = tempo$text, output = output_file_name, sep = 2)
            fun.export.data(path = path.out, data = tempo$text, output = output_error_file_name, sep = 2)
        }else{
            fun.export.data(path = path.out, data = paste0(tempo$text, "\nCOLUMN ", i, " MADE OF INTEGERS"), output = output_file_name, sep = 2)
        }
    } else if(names(map)[i] == "deCODE.cM"){
        tempo <- param_check_fun(data = map[, i], data.name = paste0(names(map[i]), "_of_map"), print = FALSE, typeof = "double")
        if(tempo$problem == TRUE){
            fun.export.data(path = path.out, data = tempo$text, output = output_file_name, sep = 2)
            fun.export.data(path = path.out, data = tempo$text, output = output_error_file_name, sep = 2)
        }else{
            fun.export.data(path = path.out, data = paste0(tempo$text, "\nCOLUMN ", i, " MADE OF DECIMAL NUMBERS"), output = output_file_name, sep = 2)
        }
    } else{
        tempo <- paste0("### raw_check_lod_gael ERROR ### IMPROPER COLUMN NAME IN MAP FILE: ", paste(names(map), collapse = " "))
        fun.export.data(path = path.out, data = tempo, output = output_file_name, sep = 2)
        fun.export.data(path = path.out, data = tempo$text, output = output_error_file_name, sep = 2)
        stop(tempo)
    }
}
# end check
tempo <- object_info_fun(data = map)
fun.export.data(path = path.out, data = paste0("######## BASIC INFORMATION:"), output = output_file_name, sep = 2)
fun.export.data(path = path.out, data = tempo, output = output_file_name, sep = 2)

# SNP in map present in freq
fun.export.data(path = path.out, data = paste0("######## COMPARISONS:"), output = output_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("NUMBER OF SNP IN THE genetic map file (map) THAT ARE PRESENT (TRUE) OR NOT (FALSE) IN THE allele freq file (freq):"), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = addmargins(table(map[, "Name"] %in% freq[, "Name"])), output = output_file_name, sep = 2) # 
tempo2 <- map[ ! map[, "Name"] %in% freq[, "Name"], ]
data1 <- map
tempo.name1 <- "genetic map file (map)"
tempo.name2 <- "allele freq file (freq)"
tempo.name3 <- "snp.map.absent.in.freq.txt"
snp_name_in_two_files_fun(snp_data = tempo2, data1 = data1, file_name1 = tempo.name1, file_name2 = tempo.name2, txt_output_file_name = output_file_name, table_output_file_name = tempo.name3, output_path = path.out, table_limit = 300)
# SNP in freq present in map
fun.export.data(path = path.out, data = paste0("NUMBER OF SNP IN THE allele freq file (freq) THAT ARE PRESENT (TRUE) OR NOT (FALSE) IN THE genetic map file (map):"), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = addmargins(table(freq[, "Name"] %in% map[, "Name"])), output = output_file_name, sep = 2) # 
tempo2 <- freq[ ! freq[, "Name"] %in% map[, "Name"], ]
data1 <- freq
tempo.name1 <- "allele freq file (freq)"
tempo.name2 <- "genetic map file (map)"
tempo.name3 <- "snp.freq.absent.in.map.txt"
snp_name_in_two_files_fun(snp_data = tempo2, data1 = data1, file_name1 = tempo.name1, file_name2 = tempo.name2, txt_output_file_name = output_file_name, table_output_file_name = tempo.name3, output_path = path.out, table_limit = 300)
# SNP chromo coordinates in freq and map
map.snp <- as.character(map$Name[map[, "Name"] %in% freq[, "Name"]])
map.snp.coord <- map$MapInfo[map[, "Name"] %in% freq[, "Name"]]
freq.snp <- as.character(freq$Name[freq[, "Name"] %in% map[, "Name"]])
freq.snp.coord <- freq$Pos[freq[, "Name"] %in% map[, "Name"]]
if(identical(sort(map.snp), sort(freq.snp))){
 	if( ! all(map.snp.coord[order(map.snp)] == freq.snp.coord[order(freq.snp)])){
 		snp.name.problem <- sort(map.snp)[which( ! map.snp.coord[order(map.snp)] == freq.snp.coord[order(freq.snp)])] # this should give the  same sort(freq.snp)[which( ! map.snp.coord[order(map.snp)] == freq.snp.coord[order(freq.snp)])]
 		tempo <- "PROBLEM: SOME OF THE freq AND map COMMON SNP DO NOT HAVE THE SAME COORDINATES"
 		fun.export.data(path = path.out, data = tempo, output = output_file_name, sep = 1)
		fun.export.data(path = path.out, data = tempo, output = output_error_file_name, sep = 1)
		tempo <- "THE PROBLEMATIC SNP IN freq ARE:"
 		fun.export.data(path = path.out, data = tempo, output = output_file_name, sep = 1)
		fun.export.data(path = path.out, data = tempo, output = output_error_file_name, sep = 1)
		fun.export.data(path = path.out, data = freq[freq$Name %in% snp.name.problem, ], output = output_file_name, sep = 1)
		fun.export.data(path = path.out, data = freq[freq$Name %in% snp.name.problem, ], output = output_error_file_name, sep = 1)
		tempo <- "THE PROBLEMATIC SNP IN map ARE:"
 		fun.export.data(path = path.out, data = tempo, output = output_file_name, sep = 1)
		fun.export.data(path = path.out, data = tempo, output = output_error_file_name, sep = 1)
		fun.export.data(path = path.out, data = map[map$Name %in% snp.name.problem, ], output = output_file_name, sep = 2)
		fun.export.data(path = path.out, data = map[map$Name %in% snp.name.problem, ], output = output_error_file_name, sep = 2)
 	}else{
		tempo <- "ALL THE SNP FROM freq AND map HAVE THE SAME CHROMO COORDINATES"
 		fun.export.data(path = path.out, data = tempo, output = output_file_name, sep = 2)
 	}
 }else{
 	tempo <- "### raw_check_lod_gael ERROR ### map.snp AND freq.snp SHOULD HAVE IDENTICAL SNP NAMES"
 	fun.export.data(path = path.out, data = tempo, output = output_file_name, sep = 2)
	fun.export.data(path = path.out, data = tempo, output = output_error_file_name, sep = 2)
 }


####### genotype file (Family.txt)

fun.export.data(path = path.out, data = paste0("################ Genotype FILE ################"), output = output_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("################ Genotype FILE ################"), output = output_error_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("THE GENOTYPE FILE IS: ", args[tempo.arg.names == "genotype"]), output = output_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("THE GENOTYPE FILE IS: ", args[tempo.arg.names == "genotype"]), output = output_error_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("######## SCAN:"), output = output_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("INITIAL COLUMN NAMES:"), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = names(genotype), output = output_file_name, sep=1)
if(is.null(names(genotype)) | identical(names(genotype), paste0("X", 1:ncol(genotype))) | identical(names(genotype), paste0("V", 1:ncol(genotype)))){
    tempo <- paste0("### raw_check_lod_gael ERROR ### MANDATORY COLUMN NAMES NOT DETECTED IN GENOTYPE FILE")
    fun.export.data(path = path.out, data = tempo, output = output_file_name, sep = 1)
    fun.export.data(path = path.out, data = tempo, output = output_error_file_name, sep = 1)
    stop(tempo)
}
# Check
tempo <- param_check_fun(data = genotype, print = FALSE, class = "data.frame")
if(tempo$problem == TRUE){
    fun.export.data(path = path.out, data = tempo$text, output = output_file_name, sep = 2)
    fun.export.data(path = path.out, data = tempo$text, output = output_error_file_name, sep = 2)
}else{
    fun.export.data(path = path.out, data = paste0(tempo$text, "\nCLASS: \"data.frame\" & NUMBER OF COLUMNS: ", length(genotype)), output = output_file_name, sep = 2)
}
for(i in 1:ncol(genotype)){
  tempo <- param_check_fun(data = genotype[, i], data.name = paste0(names(genotype[i]), "_of_genotype"), print = FALSE, class = "factor")
  if(tempo$problem == TRUE){
      fun.export.data(path = path.out, data = paste0("COLUMN ", i , "OF genotype: ", tempo$text), output = output_file_name, sep = 2)
      fun.export.data(path = path.out, data = tempo$text, output = output_error_file_name, sep = 2)
  }else{
      fun.export.data(path = path.out, data = paste0(tempo$text, "\nCOLUMN ", i," MADE OF FACTORS"), output = output_file_name, sep = 2)
  }
}
# end check
tempo <- object_info_fun(data = genotype)
fun.export.data(path = path.out, data = paste0("######## BASIC INFORMATION:"), output = output_file_name, sep = 2)
fun.export.data(path = path.out, data = tempo, output = output_file_name, sep = 2)
# comparison
fun.export.data(path = path.out, data = paste0("######## COMPARISONS:"), output = output_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("NUMBER OF SNP IN THE genotype file (genotype) THAT ARE PRESENT (TRUE) OR NOT (FALSE) IN THE allele freq file (freq):"), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = addmargins(table(genotype[, "SNP_ID"] %in% freq[, "Name"])), output = output_file_name, sep = 2) # 
tempo2 <- genotype[ ! genotype[, "SNP_ID"] %in% freq[, "Name"], ]
data1 <- genotype
tempo.name1 <- "genotype file (genotype)"
tempo.name2 <- "allele freq file (freq)"
tempo.name3 <- "snp.genotype.absent.in.freq.txt"
snp_name_in_two_files_fun(snp_data = tempo2, data1 = data1, file_name1 = tempo.name1, file_name2 = tempo.name2, txt_output_file_name = output_file_name, table_output_file_name = tempo.name3, output_path = path.out, table_limit = 300)
fun.export.data(path = path.out, data = paste0("NUMBER OF SNP IN THE allele freq FILE (freq) THAT ARE PRESENT (TRUE) OR NOT (FALSE) IN THE genotype FILE (genotype):"), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = addmargins(table(freq[, "Name"] %in% genotype[, "SNP_ID"])), output = output_file_name, sep = 2)
tempo2 <- freq[ ! freq[, "Name"] %in% genotype[, "SNP_ID"], ]
data1 <- freq
tempo.name1 <- "allele freq file (freq)"
tempo.name2 <- "genotype file (genotype)"
tempo.name3 <- "snp.freq.absent.in.genotype.txt"
snp_name_in_two_files_fun(snp_data = tempo2, data1 = data1, file_name1 = tempo.name1, file_name2 = tempo.name2, txt_output_file_name = output_file_name, table_output_file_name = tempo.name3, output_path = path.out, table_limit = 300)
fun.export.data(path = path.out, data = paste0("NUMBER OF SNP IN THE genetic map FILE (map) THAT ARE PRESENT (TRUE) OR NOT (FALSE) IN THE genotype FILE (genotype):"), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = addmargins(table(map[, "Name"] %in% genotype[, "SNP_ID"])), output = output_file_name, sep = 2) # 
tempo2 <- map[ ! map[, "Name"] %in% genotype[, "SNP_ID"], ]
data1 <- map
tempo.name1 <- "genetic map file (map)"
tempo.name2 <- "genotype file (genotype)"
tempo.name3 <- "snp.map.absent.in.genotype.txt"
snp_name_in_two_files_fun(snp_data = tempo2, data1 = data1, file_name1 = tempo.name1, file_name2 = tempo.name2, txt_output_file_name = output_file_name, table_output_file_name = tempo.name3, output_path = path.out, table_limit = 300)

fun.export.data(path = path.out, data = paste0("NUMBER OF SNP IN THE genotype FILE (genotype) THAT ARE PRESENT (TRUE) OR NOT (FALSE) IN THE genetic map FILE (map):"), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = addmargins(table(genotype[, "SNP_ID"] %in% map[, "Name"])), output = output_file_name, sep = 2) # 
tempo2 <- genotype[ ! genotype[, "SNP_ID"] %in% map[, "Name"], ]
data1 <- genotype
tempo.name1 <- "genotype file (genotype)"
tempo.name2 <- "genetic map file (map)"
tempo.name3 <- "snp.genotype.absent.in.map.txt"
snp_name_in_two_files_fun(snp_data = tempo2, data1 = data1, file_name1 = tempo.name1, file_name2 = tempo.name2, txt_output_file_name = output_file_name, table_output_file_name = tempo.name3, output_path = path.out, table_limit = 300)

tempo.common.snp <- Reduce(intersect, list(genotype$SNP_ID, freq$Name, map$Name))
if(length(tempo.common.snp) != length(unique(tempo.common.snp))){
    tempo <- "### raw_check_lod_gael ERROR ### DUPLICATED SNP NAMES AMONG THE genotype, freq, map COMMON SNP"
    fun.export.data(path = path.out, data = tempo, output = output_file_name, sep = 2)
    fun.export.data(path = path.out, data = tempo, output = output_error_file_name, sep = 1)
    fun.export.data(path = path.out, data = tempo.common.snp[duplicated(tempo.common.snp)], output = output_error_file_name, sep = 2)
}

fun.export.data(path = path.out, data = paste0("NUMBER OF SNP THAT ARE COMMON AMONG THE genotype, freq AND map FILES:", length(tempo.common.snp)), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = paste0("PROPORTION OF COMMON SNP IN THE genotype FILE:", length(tempo.common.snp) / nrow(genotype)), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = paste0("PROPORTION OF COMMON SNP IN THE freq FILE:", length(tempo.common.snp) / nrow(freq)), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = paste0("PROPORTION OF COMMON SNP IN THE map FILE:", length(tempo.common.snp) / nrow(map)), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = paste0("THE LIST OF COMMON SNP IS PROVIDED IN THE " , path.out, "/common_snp_among_geno_freq_map FILE"), output = output_file_name, sep = 1)
write.table(tempo.common.snp, file = paste0(path.out, "/", kind, "_common_snp_among_geno_freq_map"), append = FALSE, quote = FALSE, sep = "\t")

# check the correct genotypes in each line
if( ! all(genotype[, -1] == "AA" | genotype[, -1] == "AB" | genotype[, -1] == "BB" | genotype[, -1] == empty.geno)){
  fun.export.data(path = path.out, data = paste0("PROBLEM: GENOTYPE DIFFERENT FROM AA, AB, BB OR -- IN LINES:"), output = output_file_name, sep = 1)
  fun.export.data(path = path.out, data = genotype[which( ! (genotype[, -1] == "AA" | genotype[, -1] == "AB" | genotype[, -1] == "BB" | genotype[, -1] == empty.geno), arr.ind = TRUE)[, 1],], output = output_file_name, sep = 2) # 
  fun.export.data(path = path.out, data = paste0("PROBLEM: GENOTYPE DIFFERENT FROM AA, AB, BB OR -- IN LINES:"), output = output_error_file_name, sep = 1)
  fun.export.data(path = path.out, data = genotype[which( ! (genotype[, -1] == "AA" | genotype[, -1] == "AB" | genotype[, -1] == "BB" | genotype[, -1] == empty.geno), arr.ind = TRUE)[, 1],], output = output_error_file_name, sep = 2) # 
}else{
  fun.export.data(path = path.out, data = paste0("GENOTYPES AA, AB, BB OR -- IN ALL LINES"), output = output_file_name, sep = 2)
}
# define if individuals no genotyped at all
if(any(apply(genotype[, -1] == empty.geno, 2, all))){
  fun.export.data(path = path.out, data = paste0("INDIVIDUALS NOT GENOTYPED AT ALL:"), output = output_file_name, sep = 1)
  fun.export.data(path = path.out, data = names(genotype[, -1])[apply(genotype[, -1] == empty.geno, 2, all)], output = output_file_name, sep = 2)
}else{
  fun.export.data(path = path.out, data = paste0("NO INDIVIDUAL NOT GENOTYPED AT ALL (WITH ONLY --)"), output = output_file_name, sep = 2)
}
fun.export.data(path = path.out, data = paste0("PROPORTION OF -- PER INDIVIDUAL:"), output = output_file_name, sep = 1)
tempo <- sapply(lapply(lapply(c(genotype[, -1]), FUN = "==", empty.geno), as.numeric), sum) / nrow(genotype[, -1])
names(tempo) <- names(genotype[, -1])
fun.export.data(path = path.out, data = tempo, output = output_file_name, sep = 2)
 # SNP not genotyped
if(any(apply(genotype[, -1] == empty.geno, 1, all))){
  fun.export.data(path = path.out, data = paste0("NUMBER OF SNP NOT GENOTYPED AT ALL: ", sum(as.numeric(apply(genotype[, -1] == empty.geno, 1, all)))), output = output_file_name, sep = 1)
  fun.export.data(path = path.out, data = paste0("PROPORTION OF SNP NOT GENOTYPED AT ALL: ", sum(as.numeric(apply(genotype[, -1] == empty.geno, 1, all))) / nrow(genotype[, -1])), output = output_file_name, sep = 1)
  fun.export.data(path = path.out, data = paste0("SEE THE snp.not.geno.atall.in.genotype FILE TO HAVE THE SNP NOT GENOTYPED AT ALL"), output = output_file_name, sep = 2)
  write.table(genotype[apply(genotype[, -1] == empty.geno, 1, all), ], file = paste0(path.out, "/", kind, "_snp.not.geno.atall.in.genotype"), append = FALSE, quote = FALSE, sep = "\t")
}else{
  fun.export.data(path = path.out, data = paste0("NO SNP NOT GENOTYPED AT ALL"), output = output_file_name, sep = 2)
}
if(any(apply(genotype[, -1] == empty.geno | genotype[, -1] == "AA", 1, all)  & ! apply(genotype[, -1] == empty.geno, 1, all))){
  AA.sum <- sum(as.numeric(apply(genotype[, -1] == empty.geno | genotype[, -1] == "AA", 1, all)  & ! apply(genotype[, -1] == empty.geno, 1, all)))
  fun.export.data(path = path.out, data = paste0("NUMBER OF AA NON INFORMATIVE SNP (CONTAINING AA ONLY OPTIONALY WITH --): ", AA.sum), output = output_file_name, sep = 1)
  fun.export.data(path = path.out, data = paste0("PROPORTION OF AA NON INFORMATIVE SNP: ", AA.sum / nrow(genotype[, -1])), output = output_file_name, sep = 1)
  fun.export.data(path = path.out, data = paste0("SEE THE non.info.snp.in.genotype FILE TO HAVE THE AA NON INFORMATIVE SNP"), output = output_file_name, sep = 2)
  if(any(list.files(path.out) == "non.info.snp.in.genotype")){
  	write.table(genotype[apply(genotype[, -1] == empty.geno | genotype[, -1] == "AA", 1, all) & ! apply(genotype[, -1] == empty.geno, 1, all), ], file = paste0(path.out, "/", kind, "_non.info.snp.in.genotype"), col.names = FALSE, append = TRUE, quote = FALSE, sep = "\t")
  }else{
  	write.table(genotype[apply(genotype[, -1] == empty.geno | genotype[, -1] == "AA", 1, all) & ! apply(genotype[, -1] == empty.geno, 1, all), ], file = paste0(path.out, "/", kind, "_non.info.snp.in.genotype"), col.names = TRUE, append = FALSE, quote = FALSE, sep = "\t")
  }
}else{
  AA.sum <- 0
  fun.export.data(path = path.out, data = paste0("NO AA NON INFORMATIVE SNP"), output = output_file_name, sep = 2)
}
if(any(apply(genotype[, -1] == empty.geno | genotype[, -1] == "BB", 1, all) & ! apply(genotype[, -1] == empty.geno, 1, all))){
  BB.sum <- sum(as.numeric(apply(genotype[, -1] == empty.geno | genotype[, -1] == "BB", 1, all) & ! apply(genotype[, -1] == empty.geno, 1, all)))
  fun.export.data(path = path.out, data = paste0("NUMBER OF BB NON INFORMATIVE SNP (CONTAINING BB ONLY OPTIONALY WITH --): ", BB.sum), output = output_file_name, sep = 1)
  fun.export.data(path = path.out, data = paste0("PROPORTION OF BB NON INFORMATIVE SNP: ", BB.sum / nrow(genotype[, -1])), output = output_file_name, sep = 1)
  fun.export.data(path = path.out, data = paste0("SEE THE non.info.snp.in.genotype FILE TO HAVE THE BB NON INFORMATIVE SNP"), output = output_file_name, sep = 2)
  if(any(list.files(path.out) == "non.info.snp.in.genotype")){
  	write.table(genotype[apply(genotype[, -1] == empty.geno | genotype[, -1] == "BB", 1, all) & ! apply(genotype[, -1] == empty.geno, 1, all), ], file = paste0(path.out, "/", kind, "_non.info.snp.in.genotype"), col.names = FALSE, append = TRUE, quote = FALSE, sep = "\t")
  }else{
  	write.table(genotype[apply(genotype[, -1] == empty.geno | genotype[, -1] == "BB", 1, all) & ! apply(genotype[, -1] == empty.geno, 1, all), ], file = paste0(path.out, "/", kind, "_non.info.snp.in.genotype"), col.names = TRUE, append = FALSE, quote = FALSE, sep = "\t")
  }
}else{
  BB.sum <- 0
  fun.export.data(path = path.out, data = paste0("NO BB NON INFORMATIVE SNP"), output = output_file_name, sep = 2)
}
if(any(apply(genotype[, -1] == empty.geno | genotype[, -1] == "AB", 1, all) & ! apply(genotype[, -1] == empty.geno, 1, all))){
  AB.sum <- sum(as.numeric(apply(genotype[, -1] == empty.geno | genotype[, -1] == "AB", 1, all) & ! apply(genotype[, -1] == empty.geno, 1, all)))
  fun.export.data(path = path.out, data = paste0("NUMBER OF AB NON INFORMATIVE SNP (CONTAINING AB ONLY OPTIONALY WITH --): ", AB.sum), output = output_file_name, sep = 1)
  fun.export.data(path = path.out, data = paste0("PROPORTION OF AB NON INFORMATIVE SNP: ", AB.sum / nrow(genotype[, -1])), output = output_file_name, sep = 1)
  fun.export.data(path = path.out, data = paste0("SEE THE non.info.snp.in.genotype FILE TO HAVE THE AB NON INFORMATIVE SNP"), output = output_file_name, sep = 2)
  if(any(list.files(path.out) == "non.info.snp.in.genotype")){
    write.table(genotype[apply(genotype[, -1] == empty.geno | genotype[, -1] == "AB", 1, all) & ! apply(genotype[, -1] == empty.geno, 1, all), ], file = paste0(path.out, "/", kind, "_non.info.snp.in.genotype"), col.names = FALSE, append = TRUE, quote = FALSE, sep = "\t")
  }else{
    write.table(genotype[apply(genotype[, -1] == empty.geno | genotype[, -1] == "AB", 1, all) & ! apply(genotype[, -1] == empty.geno, 1, all), ], file = paste0(path.out, "/", kind, "_non.info.snp.in.genotype"), col.names = TRUE, append = FALSE, quote = FALSE, sep = "\t")
  }
}else{
  AB.sum <- 0
  fun.export.data(path = path.out, data = paste0("NO AB NON INFORMATIVE SNP"), output = output_file_name, sep = 2)
}
fun.export.data(path = path.out, data = paste0("TOTAL NUMBER OF AA, BB AND AB NON INFORMATIVE SNP:", AA.sum + BB.sum + AB.sum), output = output_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("TOTAL PROPORTION OF AA, BB AND AB NON INFORMATIVE SNP:", (AA.sum + BB.sum + AB.sum) / nrow(genotype[, -1])), output = output_file_name, sep = 2)

####### pedigree file (pedfile.pro)

fun.export.data(path = path.out, data = paste0("################ pedfile FILE ################"), output = output_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("################ pedfile FILE ################"), output = output_error_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("THE PEDIGREE FILE IS: ", args[tempo.arg.names == "pedfile"]), output = output_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("THE PEDIGREE FILE IS: ", args[tempo.arg.names == "pedfile"]), output = output_error_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("######## SCAN:"), output = output_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("INITIAL COLUMN NAMES:"), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = names(pedfile), output = output_file_name, sep=1)
if(is.null(names(pedfile)) | identical(names(pedfile), paste0("X", 1:ncol(pedfile))) | identical(names(pedfile), paste0("V", 1:ncol(pedfile)))){
    fun.export.data(path = path.out, data = paste0("NO COLUMN NAMES DETECTED. COLUMN NAMES ADDED JUST FOR THIS ANALYSIS:"), output = output_file_name, sep = 2)
    names(pedfile) <- c("genotype_ID", "ind_ID", "father_ID", "mother_ID", "sex", "status")
    fun.export.data(path = path.out, data = names(pedfile), output = output_file_name, sep=1)
}else{
    fun.export.data(path = path.out, data = paste0("FILE SHOULD NOT HAVE COLUMN NAMES"), output = output_file_name, sep = 2)
    fun.export.data(path = path.out, data = paste0("FILE SHOULD NOT HAVE COLUMN NAMES"), output = output_error_file_name, sep = 2)
}
# Check
tempo <- param_check_fun(data = pedfile, print = FALSE, class = "data.frame", length = 6)
if(tempo$problem == TRUE){
    fun.export.data(path = path.out, data = tempo$text, output = output_file_name, sep = 2)
    fun.export.data(path = path.out, data = tempo$text, output = output_error_file_name, sep = 2)
}else{
    fun.export.data(path = path.out, data = paste0(tempo$text, "\nCLASS: \"data.frame\" & NUMBER OF COLUMNS: 6"), output = output_file_name, sep = 2)
}
if( ! all(sapply(pedfile, typeof) == "integer")){
  fun.export.data(path = path.out, data = paste0("FILE SHOULD BE MADE OF INTEGER ONLY"), output = output_file_name, sep = 2)
  fun.export.data(path = path.out, data = paste0("FILE SHOULD BE MADE OF INTEGER ONLY"), output = output_error_file_name, sep = 2)
}else{
    fun.export.data(path = path.out, data = paste0(tempo$text, "\nFILE MADE OF INTEGER ONLY"), output = output_file_name, sep = 2)
}
for(i in 5:6){
  tempo <- param_check_fun(data = pedfile[, i], print = FALSE, options = 0:2)
  if(tempo$problem == TRUE){
    fun.export.data(path = path.out, data = tempo$text, output = output_file_name, sep = 2)
    fun.export.data(path = path.out, data = tempo$text, output = output_error_file_name, sep = 2)
  }else{
    fun.export.data(path = path.out, data = paste0(tempo$text, "\nCOLUMN ", i, " MADE OF 0-2 ONLY"), output = output_file_name, sep = 2)
  }
}
for(i in 3:4){
  if(i == 3){
    tempo.name <- "FATHER"
  }else{
    tempo.name <- "MOTHER"
  }
  tempo <- pedfile[, 3] %in% c(pedfile[, 2], 0)
  if( ! all(tempo)){
    fun.export.data(path = path.out, data = paste0("PROBLEM: ", tempo.name," ID (", paste(pedfile[ ! tempo, 3], collapse = " "), "IN COLUMN ", i, ") NOT IN COLUM 2"), output = output_file_name, sep = 2)
    fun.export.data(path = path.out, data = paste0("PROBLEM: ", tempo.name," ID (", paste(pedfile[ ! tempo, 3], collapse = " "), "IN COLUMN ", i, ") NOT IN COLUM 2"), output = output_error_file_name, sep = 2)
  }else{
    fun.export.data(path = path.out, data = paste0("ALL ", tempo.name," ID (COLUMN ", i, ") PRESENT IN COLUM 2"), output = output_file_name, sep = 2)
  }
}
if(nrow(pedfile) != (ncol(genotype) - 1)){
    tempo <- paste0("BEWARE: THE NUMBER OF INDIVIDUALS IS NOT THE SAME IN THE GENOTYPE (", (ncol(genotype) - 1), ") AND PEDIGREE (", nrow(pedfile), ") FILES")
    fun.export.data(path = path.out, data = tempo, output = output_file_name, sep = 1)
    fun.export.data(path = path.out, data = tempo, output = output_error_file_name, sep = 1)
}else{
    fun.export.data(path = path.out, data = paste0("THE NUMBER OF INDIVIDUALS IS THE SAME IN THE GENOTYPE AND PEDIGREE FILES: ", nrow(pedfile)), output = output_file_name, sep = 1)
}

geno.names <- names(genotype)[-1]
if(kind == "postclean" | kind == "postsplit"){
    geno.file.nb <- gsub("_Call", "", geno.names)
}else {
    # geno.file.nb <- substr(geno.names, nchar(geno.names) - 2, nchar(geno.names))
    geno.file.nb <- geno.names
    tempo <- paste0("BEWARE: THE CODE CANNOT WORK IF THE COLUMN NAME OF THE GENOTYPE FILE ARE NOT: \"3 LAST CHARACTERS CORRESPONDING TO THE ID INDIVIDUAL NUMBER IN THE pedfile.pro FILE (WITH LEADING ZERO, LIKE FINISHING BY 001 FOR INDIVIDUAL 1, etc.)\"")
    fun.export.data(path = path.out, data = tempo, output = output_file_name, sep = 1)
    fun.export.data(path = path.out, data = tempo, output = output_error_file_name, sep = 1)
    geno.file.nb <- sub(x = geno.file.nb, pattern = "^0+", replacement = "") # remove the leading zeros
}

if( ! (all(geno.file.nb %in% pedfile$ind_ID) & all(pedfile$ind_ID %in% geno.file.nb))){
    tempo <- paste0("BEWARE: THE INDIVIDUALS ID ARE NOT THE SAME IN THE GENOTYPE AND PEDIGREE FILES")
    fun.export.data(path = path.out, data = tempo, output = output_file_name, sep = 1)
    fun.export.data(path = path.out, data = tempo, output = output_error_file_name, sep = 1)
    if( ! all(geno.file.nb %in% pedfile$ind_ID)){
        tempo2 <- paste0("ID OF GENOTYPE FILE NOT PRESENT IN PEDIGREE ", paste0(geno.names[ ! geno.file.nb %in% pedfile$ind_ID], collapse = " "))
        fun.export.data(path = path.out, data = tempo2, output = output_file_name, sep = 1)
        fun.export.data(path = path.out, data = tempo2, output = output_error_file_name, sep = 1)
    }
    if( ! all(pedfile$ind_ID %in% geno.file.nb)){
        tempo2 <- paste0("ID OF PEDIGREE FILE NOT PRESENT IN GENOTYPE ", paste0(pedfile[ ! pedfile$ind_ID %in% geno.file.nb], collapse = " "))
        fun.export.data(path = path.out, data = tempo2, output = output_file_name, sep = 1)
        fun.export.data(path = path.out, data = tempo2, output = output_error_file_name, sep = 1)
    }
}else{
    tempo <- paste0("THE INDIVIDUALS ID ARE THE SAME IN THE GENOTYPE AND PEDIGREE FILES")
    fun.export.data(path = path.out, data = tempo, output = output_file_name, sep = 1)
}
#end check
tempo <- object_info_fun(data = pedfile)
fun.export.data(path = path.out, data = paste0("######## BASIC INFORMATION:"), output = output_file_name, sep = 2)
fun.export.data(path = path.out, data = tempo, output = output_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("NUMBER OF FAMILIES: ", length(table(pedfile[, 1]))), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = paste0("NUMBER OF INDIVIDUALS: ", length(table(pedfile[, 2]))), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = paste0("NUMBER OF FATHERS: ", length(table(pedfile[, 3]))), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = paste0("NUMBER OF MOTHERS: ", length(table(pedfile[, 3]))), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = paste0("NUMBER OF UNKNOWN SEX: ", length(which(pedfile[, 5] == 0))), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = paste0("NUMBER OF MALES: ", length(which(pedfile[, 5] == 1))), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = paste0("NUMBER OF FEMALES: ", length(which(pedfile[, 5] == 2))), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = paste0("NUMBER OF UNKNOWN STATUS: ", length(which(pedfile[, 6] == 0))), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = paste0("NUMBER OF UNAFFECTED: ", length(which(pedfile[, 6] == 1))), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = paste0("NUMBER OF AFFECTED: ", length(which(pedfile[, 6] == 2))), output = output_file_name, sep = 1)

fun.export.data(path = path.out, data = paste0("################ END OF PROCESS"), output = output_file_name, sep = 2)

################################ End Main code


