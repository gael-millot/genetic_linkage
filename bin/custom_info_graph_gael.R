################################################################
##                                                            ##
##     COSEGREGATION FILES PRINTING                           ##
##                                                            ##
##     Gael A. Millot                                         ##
##                                                            ##
##     Version v1                                             ##
##                                                            ##
################################################################


################################ Introduction


# Compatible with R v3.4.1
# Running example in R:
    # lib.path="/pasteur/homes/gmillot/R/x86_64-pc-linux-gnu-library/3.4" ; nb.file="3" ; chromo.nb="16_._17_._18_._19" ; r_main_functions="/pasteur/homes/gmillot/dyslexia/code_gael/R_main_functions_gael_20180116.R" ; path.out="/pasteur/homes/gmillot/dyslexia/20180313_infor_results/initial_files_before_split_1520890374" ; group.path.out="Group1_._Group2_._Group3" ; jobid.path.out="1520890378" ; file.output.name="full_infor_1520890378.txt" ; lod.cutoff="2_._3" ; separator="_._" ; model="--model" ; optional.text="notxt"



################################ End Introduction





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
# may be convert arg[2] as numeric 
tempo.arg.names <- c("r_main_functions", "chr_info", "file", "chromo.nb.set", "lod.cutoff", "path.out", "model")

if(length(args) != length(tempo.arg.names)){
  tempo.cat <- paste0("======== ERROR: THE NUMBER OF ELEMENTS IN args (", length(args),") IS DIFFERENT FROM THE NUMBER OF ELEMENTS IN tempo.arg.names (", length(tempo.arg.names),")\nargs:", paste0(args, collapse = ","), "\ntempo.arg.names:", paste0(tempo.arg.names, collapse = ","))
  stop(tempo.cat)
}
for(i in 1:length(tempo.arg.names)){
    assign(tempo.arg.names[i], args[i])
}



################ Debug

# setwd("C:/Users/gael/Documents/Git_projects/genetic_linkage/work/27/f62331c49000113bbfff595cbe9444/caca")
# r_main_functions <- "C:/Users/gael/Documents/Git_projects/genetic_linkage/bin/R_main_functions_gael_20180123.R"
# chr_info <- "hg19_grch37p5_chr_size_cumul.txt"
# file <- 'complete_information.tsv'
# chromo.nb.set <- c("07")
# lod.cutoff <- c("2", "3")
# path.out <- "."
# model <- "caca"



################ end Debug






if( ! (is.character(r_main_functions) & length(r_main_functions) == 1)){
    tempo.cat <- paste0("======== ERROR: THE r_main_functions ARGUMENT IN args (", r_main_functions,") MUST BE A SINGLE CHARACTER STRING")
    stop(tempo.cat)
}
if( ! (is.character(path.out) & length(path.out) == 1)){
    tempo.cat <- paste0("======== ERROR: THE path.out ARGUMENT IN args (", path.out,") MUST BE A SINGLE CHARACTER STRING")
    stop(tempo.cat)
}



if( ! is.character(r_main_functions)){
    tempo.cat <- paste0("======== ERROR: THE r_main_functions ARGUMENT IN args (", r_main_functions,") MUST BE A SINGLE CHARACTER STRING")
    stop(tempo.cat)
}
if( ! is.character(file)){
    tempo.cat <- paste0("======== ERROR: THE file ARGUMENT IN args (", file,") MUST BE A SINGLE CHARACTER STRING")
    stop(tempo.cat)
}
if( ! is.character(chr_info)){
    tempo.cat <- paste0("======== ERROR: THE chr_info ARGUMENT IN args (", chr_info,") MUST BE A SINGLE CHARACTER STRING")
    stop(tempo.cat)
}
if( ! is.character(chromo.nb.set)){
    tempo.cat <- paste0("======== ERROR: THE chromo.nb.set ARGUMENT IN args (", chromo.nb.set,") MUST BE A SINGLE CHARACTER STRING")
    stop(tempo.cat)
}
if( ! is.character(lod.cutoff)){
    tempo.cat <- paste0("======== ERROR: THE lod.cutoff ARGUMENT IN args (", lod.cutoff,") MUST BE A SINGLE CHARACTER STRING")
    stop(tempo.cat)
}
if( ! is.character(path.out)){
    tempo.cat <- paste0("======== ERROR: THE path.out ARGUMENT IN args (", path.out,") MUST BE A SINGLE CHARACTER STRING")
    stop(tempo.cat)
}
if( ! is.character(model)){
    tempo.cat <- paste0("======== ERROR: THE model ARGUMENT IN args (", model,") MUST BE A SINGLE CHARACTER STRING")
    stop(tempo.cat)
}



lod.cutoff <- as.numeric(sort(unlist(strsplit(lod.cutoff, " "))))
# cat(lod.cutoff, "\n\n")
chromo.nb.set <- as.numeric(sort(unlist(strsplit(chromo.nb.set, " "))))




################ Parameters


decimal.symbol <- "." # for argument dec of read.table function
chromo.nb <- c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23")
chromo.nb <- as.numeric(unlist(strsplit(chromo.nb, " ")))
file.output.name <- "complete_info.tsv"


################################ Sourcing


source(r_main_functions)


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

error_file_name <- "custom_graph_error.log" # error file
tempo.cat <- "################ CUSTOM GRAPH PROCESS"
cat("\n\n", tempo.cat, "\n\n", sep ="")
fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)


################ Data import

output.data <- read.table(file, header = TRUE, na.strings = "NA", dec = decimal.symbol, row.names = NULL, comment.char = "", stringsAsFactors = FALSE)
chr.info <- read.table(chr_info, header = TRUE, na.strings = "NA", dec = decimal.symbol, row.names = NULL, comment.char = "", stringsAsFactors = FALSE)


if(all(is.na(output.data$Information))){
    tempo.cat <- paste0("\nNO INFOR CAN BE SAVED OR DRAWN BECAUSE NA ONLY")
    cat("\n\n", tempo.cat, "\n\n", sep ="")
    fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
}else{






    ####### printing files

    library(ggplot2)
    library(qqman)
    fun.open.window(pdf.disp = TRUE, path.fun = path.out, pdf.name.file = "infor_whole_genome", width.fun = 7, height.fun = 7, return.output = FALSE)
    # col = hsv(h = c(4,7)/8, s = 0.4, v = 0.8)
    for(loop.chromo.nb in 1:length(chromo.nb)){
        tempo.output.data <- output.data[output.data$Chr == chromo.nb[loop.chromo.nb], ]
        a <- ggplot(data = tempo.output.data, mapping = aes(x= Physical.position, y = Information, color = Group))
        b <- geom_point(size=1)
        # b <- geom_point(size=1)
        d <- theme_classic(base_size = 14)
        e <- xlab(paste0("Physical Position on chromosome ", chromo.nb[loop.chromo.nb]))
        g <- xlim(0, chr.info$BP_LENGTH[chr.info$CHR_NB == chromo.nb[loop.chromo.nb]])
        h <- ylim(min(output.data$Information, na.rm = TRUE), max(output.data$Information, na.rm = TRUE))
        i <- labs(title = paste0("CHROMOSOME ", chromo.nb[loop.chromo.nb], "\nX-AXIS RANGE: 0-", chr.info$BP_LENGTH[chr.info$CHR_NB == chromo.nb[loop.chromo.nb]]))
        print(a + b + d + e + g + h + i)
    }
}




graphics.off()

tempo.cat <- "\n################ END OF R PRINTING PROCESS"
cat(tempo.cat, sep ="")
fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)

################################ End Main code
