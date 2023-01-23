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
  # /cygdrive/c/Program Files/R/R-3.3.3/bin/R.exe $FILE_PATH/Hub\ projects\20170323\ Bourgeron\ Dislexya/check_pedigree_lod_gael\ 20171215.R $INPUT_DIR_PATH $OUTPUT $OUTPUT_ERROR $INPUT_DIR_PATH/map $INPUT_DIR_PATH/freq $INPUT_DIR_PATH/$INPUT_DIR_NAME.txt $INPUT_DIR_PATH/pedfile.pro $FILE_PATH/R\ source/R_main_gael_functions_20171119.R "notxt"
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


args <- commandArgs(trailingOnly = TRUE)  # recover arguments written after the call of the Rscript, ie after r_341_conf $check_pedigree_lod_gael_conf 
tempo.arg.names <- c("path.out", "output_file_name", "genotype", "freq", "map", "pedfile", "r_main_functions", "optional.text") # objects names exactly in the same order as in the bash code and recovered in args
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


################ Parameters


decimal.symbol <- "." # for argument dec of read.table function


################################ Sourcing


source(r_main_functions) #
# cat("TEST4")

################################ End Sourcing


################################ Functions


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


map <- read.table(map, header = TRUE, na.strings = "NA", sep = "\t", dec = decimal.symbol, stringsAsFactors = TRUE)
freq <- read.table(freq, header = TRUE, na.strings = "NA", sep = "\t", dec = decimal.symbol, stringsAsFactors = TRUE)
genotype <- read.table(genotype, header = TRUE, na.strings = "NA", sep = "\t", dec = decimal.symbol, stringsAsFactors = TRUE)
pedfile <- read.table(pedfile, header = FALSE, na.strings = "NA", sep = "\t", dec = decimal.symbol, stringsAsFactors = TRUE)


################ Cleaning

####### genotype file (Family.txt)

fun.export.data(path = path.out, data = paste0("################ Genotype FILE ################"), output = output_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("THE GENOTYPE FILE IS: ", args[tempo.arg.names == "genotype"]), output = output_file_name, sep = 2)
# removal of empty snp
if(any(apply(genotype[, -1] == "--", 1, all))){
    fun.export.data(path = path.out, data = paste0("NUMBER OF SNP NOT GENOTYPED AT ALL AND REMOVED: ", sum(as.numeric(apply(genotype[, -1] == "--", 1, all)))), output = output_file_name, sep = 1)
    genotype <- genotype[ ! apply(genotype[, -1] == "--", 1, all), ]
}else{
  fun.export.data(path = path.out, data = paste0("NO SNP NOT GENOTYPED. NO LINES REMOVED BECAUSE OF THIS"), output = output_file_name, sep = 2)
}
# removal of homozygous snp
if(any(apply(genotype[, -1] == "--" | genotype[, -1] == "AA", 1, all))){
    fun.export.data(path = path.out, data = paste0("NUMBER OF AA NON INFORMATIVE SNP REMOVED: ", sum(as.numeric(apply(genotype[, -1] == "--" | genotype[, -1] == "AA", 1, all)))), output = output_file_name, sep = 1)
    genotype <- genotype[ ! apply(genotype[, -1] == "--" | genotype[, -1] == "AA", 1, all), ]
}else{
    fun.export.data(path = path.out, data = paste0("NO AA NON INFORMATIVE SNP. NO LINES REMOVED BECAUSE OF THIS"), output = output_file_name, sep = 2)
}
if(any(apply(genotype[, -1] == "--" | genotype[, -1] == "BB", 1, all))){
    fun.export.data(path = path.out, data = paste0("NUMBER OF BB NON INFORMATIVE SNP REMOVED: ", sum(as.numeric(apply(genotype[, -1] == "--" | genotype[, -1] == "BB", 1, all)))), output = output_file_name, sep = 1)
    genotype <- genotype[ ! apply(genotype[, -1] == "--" | genotype[, -1] == "BB", 1, all), ]
}else{
  fun.export.data(path = path.out, data = paste0("NO BB NON INFORMATIVE SNP. NO LINES REMOVED BECAUSE OF THIS"), output = output_file_name, sep = 2)
}
if(any(apply(genotype[, -1] == "--" | genotype[, -1] == "AB", 1, all))){
    fun.export.data(path = path.out, data = paste0("NUMBER OF AB NON INFORMATIVE SNP REMOVED: ", sum(as.numeric(apply(genotype[, -1] == "--" | genotype[, -1] == "AB", 1, all)))), output = output_file_name, sep = 1)
    genotype <- genotype[ ! apply(genotype[, -1] == "--" | genotype[, -1] == "AB", 1, all), ]
}else{
  fun.export.data(path = path.out, data = paste0("NO AB NON INFORMATIVE SNP. NO LINES REMOVED BECAUSE OF THIS"), output = output_file_name, sep = 2)
}

# header renamed
geno.names <- names(genotype)[-1]
geno.file.nb <- substr(geno.names, nchar(geno.names) - 2, nchar(geno.names))
geno.file.nb <- sub(x = geno.file.nb, pattern = "^0+", replacement = "") # remove the leading zeros
geno.file.nb <- sub(x = geno.file.nb, pattern = "$", replacement = "_Call") # add _Call at the end of tecah column name
names(genotype)[-1] <- geno.file.nb
fun.export.data(path = path.out, data = paste0("COLUMN NAME REPLACEMENT:"), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = data.frame(NAME_INI = geno.names[order(geno.file.nb)], FINAL_NAME = sort(geno.file.nb)), output = output_file_name, sep = 1)

# -- replaced by NoCall
tempo.class <- lapply(genotype, class)
for(i in 1:length(tempo.class)){
    if(all(tempo.class[[i]] == "factor")){
        if(any(levels(genotype[, i]) == "--")){
            levels(genotype[, i])[levels(genotype[, i]) == "--"] <- "NoCall"
        }
    }
}

####### Allele frequency file (freq)

fun.export.data(path = path.out, data = paste0("################ Freq FILE ################"), output = output_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("THE FREQ FILE IS: ", args[tempo.arg.names == "freq"]), output = output_file_name, sep = 2)


####### map file (map)

fun.export.data(path = path.out, data = paste0("################ Map FILE ################"), output = output_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("THE MAP FILE IS: ", args[tempo.arg.names == "map"]), output = output_file_name, sep = 2)
# add a leading zero to chromo name 1-9 and replace X by 23
ini.chr.levels <- levels(map$Chr)
for(i in 1:length(levels(map$Chr))){
    if(any(levels(map$Chr)[i] %in% as.character(1:9))){
        levels(map$Chr)[i] <- paste0("0", levels(map$Chr)[i])
    }
    if(any(levels(map$Chr)[i] == "X")){
        levels(map$Chr)[i] <- "23"
    }
}
final.chr.levels <- levels(map$Chr)
fun.export.data(path = path.out, data = paste0("CHROMO LEVELS REPLACEMENT:"), output = output_file_name, sep = 1)
fun.export.data(path = path.out, data = data.frame(NAME_INI = ini.chr.levels, FINAL_NAME = final.chr.levels), output = output_file_name, sep = 2)
# sorting the file according to Chromo then cM values
map <- map[order(map$Chr, map$deCODE.cM), ]

####### removal of snp that are not common genotype freq and map files:

fun.export.data(path = path.out, data = paste0("################ SNP MANAGEMENT ################"), output = output_file_name, sep = 2)
tempo.common.snp <- Reduce(intersect, list(genotype$SNP_ID, freq$Name, map$Name))
if(length(tempo.common.snp) < length(unique(genotype$SNP_ID))){
    fun.export.data(path = path.out, data = paste0(length(unique(genotype$SNP_ID)) - length(tempo.common.snp), " SNP WILL BE REMOVED IN THE GENOTYPE FILE"), output = output_file_name, sep = 1)
}
if(length(tempo.common.snp) < length(unique(freq$SNP_ID))){
    fun.export.data(path = path.out, data = paste0(length(unique(freq$SNP_ID)) - length(tempo.common.snp), " SNP WILL BE REMOVED IN THE FREQ FILE"), output = output_file_name, sep = 1)
}
if(length(tempo.common.snp) < length(unique(map$SNP_ID))){
    fun.export.data(path = path.out, data = paste0(length(unique(map$SNP_ID)) - length(tempo.common.snp), " SNP WILL BE REMOVED IN THE MAP FILE"), output = output_file_name, sep = 2)
}
genotype <- genotype[genotype$SNP_ID %in% tempo.common.snp, ]
freq <- freq[freq$Name %in% tempo.common.snp, ]
map <- map[map$Name %in% tempo.common.snp, ]

####### pedigree file (pedfile)

fun.export.data(path = path.out, data = paste0("################ pedfile FILE ################"), output = output_file_name, sep = 2)
fun.export.data(path = path.out, data = paste0("THE PEDIGREE FILE IS: ", args[tempo.arg.names == "pedfile"]), output = output_file_name, sep = 2)

geno.names <- names(genotype)[-1]
geno.names <- sub(x = geno.names, pattern = "_Call$", replacement = "") # remove _Call at the end of tecah column name
pedfile.names <- pedfile[, 2]
if(length(geno.names) != length(pedfile.names)){
    fun.export.data(path = path.out, data = paste0("### PROBLEM: THE COLUMN NAME NUMBER OF genotype (", length(geno.names), ") IS DIFFERENT FROM THE COLUMN NAME NUMBER OF pedigree (", length(pedfile.names), ")"), output = output_file_name, sep = 2)
}else{
    fun.export.data(path = path.out, data = paste0("THE COLUMN NAME NUMBER OF genotype (", length(geno.names), ") IS EQUAL TO THE COLUMN NAME NUMBER OF pedigree (", length(pedfile.names), ")"), output = output_file_name, sep = 2)
}
if(all(geno.names %in% pedfile.names) & all(pedfile.names %in% geno.names)){
    fun.export.data(path = path.out, data = paste0("THE IND NUMBERS OF pedfile ARE ALL IN THE genotype COLUMN NAMES, AND VICE-VERSA"), output = output_file_name, sep = 2)
}else{
    fun.export.data(path = path.out, data = paste0("### PROBLEM: THE IND NUMBERS OF pedfile ARE NOT ALL IN THE genotype COLUMN NAMES, OR VICE-VERSA"), output = output_file_name, sep = 1)
    fun.export.data(path = path.out, data = data.frame(GENOTYPE_NAME = sort(geno.names), PEDIGREE_NAME = sort(pedfile.names)), output = output_file_name, sep = 2)
}

####### factor actualization

genotype <- refactorization_fun(genotype)
fun.export.data(path = path.out, data = paste0("THE FINAL NUMBER OF genotype ROWS IS:", formatC(nrow(genotype), format="fg", big.mark=',')), output = output_file_name, sep = 1)
freq <- refactorization_fun(freq)
fun.export.data(path = path.out, data = paste0("THE FINAL NUMBER OF freq ROWS IS:", formatC(nrow(freq), format="fg", big.mark=',')), output = output_file_name, sep = 1)
map <- refactorization_fun(map)
fun.export.data(path = path.out, data = paste0("THE FINAL NUMBER OF map ROWS IS:", formatC(nrow(map), format="fg", big.mark=',')), output = output_file_name, sep = 2)

####### saving files

fun.export.data(path = path.out, data = paste0("BEWARE: THE genotype, freq AND map FILES ARE REPLACED BY THE MODIFIED FILES"), output = output_file_name, sep = 2)
write.table(genotype, file = paste0(args[tempo.arg.names == "genotype"]), append = FALSE, quote = FALSE, sep = "\t", row.names = FALSE, col.names = TRUE)
write.table(freq, file = paste0(args[tempo.arg.names == "freq"]), append = FALSE, quote = FALSE, sep = "\t", row.names = FALSE, col.names = TRUE)
write.table(map, file = paste0(args[tempo.arg.names == "map"]), append = FALSE, quote = FALSE, sep = "\t", row.names = FALSE, col.names = TRUE)

fun.export.data(path = path.out, data = paste0("################ END OF PROCESS"), output = output_file_name, sep = 2)


################################ End Main code
