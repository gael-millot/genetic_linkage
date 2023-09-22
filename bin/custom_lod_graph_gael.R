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
    # lib.path="/pasteur/homes/gmillot/R/x86_64-pc-linux-gnu-library/3.4" ; nb.file="3" ; chromo.nb="16_._17_._18_._19" ; r_main_functions="/pasteur/homes/gmillot/dyslexia/code_gael/R_main_functions_gael_20180116.R" ; path.out="/pasteur/homes/gmillot/dyslexia/20180313_lodscore_results/initial_files_before_split_1520890374" ; group.path.out="Group1_._Group2_._Group3" ; jobid.path.out="1520890378" ; file.output.name="full_lodscore_1520890378.txt" ; lod.cutoff="2_._3" ; separator="_._" ; model="--model" ; optional.text="notxt"



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

# setwd("C:/Users/gael/Documents/Git_projects/genetic_linkage/work/e8/74db8409f6daa3c2202f108ee8fc08/caca")
# r_main_functions <- "C:/Users/gael/Documents/Git_projects/genetic_linkage/bin/R_main_functions_gael_20180123.R"
# chr_info <- "hg19_grch37p5_chr_size_cumul.txt"
# file <- 'complete_lodscore.tsv'
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
}else{
    chromo.nb.set <- as.numeric(sort(unlist(strsplit(chromo.nb.set, "_;_"))))
}
if( ! is.character(lod.cutoff)){
    tempo.cat <- paste0("======== ERROR: THE lod.cutoff ARGUMENT IN args (", lod.cutoff,") MUST BE A SINGLE CHARACTER STRING")
    stop(tempo.cat)
}else{
    lod.cutoff <- as.numeric(sort(unlist(strsplit(lod.cutoff, "_;_"))))
}
if( ! is.character(path.out)){
    tempo.cat <- paste0("======== ERROR: THE path.out ARGUMENT IN args (", path.out,") MUST BE A SINGLE CHARACTER STRING")
    stop(tempo.cat)
}
if( ! is.character(model)){
    tempo.cat <- paste0("======== ERROR: THE model ARGUMENT IN args (", model,") MUST BE A SINGLE CHARACTER STRING")
    stop(tempo.cat)
}else{
    model <- gsub(model, "_;_", " ")
} # here replace _;_ by space





################ Parameters


decimal.symbol <- "." # for argument dec of read.table function
chromo.nb <- c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23")
chromo.nb <- as.numeric(unlist(strsplit(chromo.nb, " ")))
file.output.name <- "complete_lodscore.tsv"


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

error_file_name <- "custom_lod_graph_error.log" # error file
tempo.cat <- "################ CUSTOM LOD GRAPH PROCESS"
cat("\n\n", tempo.cat, "\n\n", sep ="")
fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)


################ Data import

output.data <- read.table(file, header = TRUE, na.strings = "NA", dec = decimal.symbol, row.names = NULL, comment.char = "", stringsAsFactors = FALSE)
chr.info <- read.table(chr_info, header = TRUE, na.strings = "NA", dec = decimal.symbol, row.names = NULL, comment.char = "", stringsAsFactors = FALSE)


if(all(is.na(output.data$Lodscore))){
    tempo.cat <- paste0("\nNO LODSCORE CAN BE SAVED OR DRAWN BECAUSE NA ONLY")
    cat("\n\n", tempo.cat, "\n\n", sep ="")
    fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
}else{






    ####### printing files

    library(ggplot2)
    library(qqman)
    fun.open.window(pdf.disp = TRUE, path.fun = path.out, pdf.name.file = "lodscore_whole_genome", width.fun = 7, height.fun = 7, return.output = FALSE)
    manhattan(
        output.data, 
        chr = "Chr", 
        snp = "SNP", 
        bp = "Physical.position", 
        p = "Lodscore", 
        logp = FALSE, 
        ylab = "LODSCORE", 
        genomewideline = 3, 
        suggestiveline = FALSE, 
        main = paste0("WHOLE GENOME\nMODEL: ", model, "\nX-AXIS RANGE: ", min(chr.info$LENGTH_CUMUL_TO_ADD), "-", max(chr.info$LENGTH_CUMUL)), 
        xlim = c(min(chr.info$LENGTH_CUMUL_TO_ADD), max(chr.info$LENGTH_CUMUL)), 
        ylim = range(output.data$Lodscore, na.rm = TRUE), 
        cex = 0.6, 
        cex.main = 0.5
    )
    # col = hsv(h = c(4,7)/8, s = 0.4, v = 0.8)
    for(loop.chromo.nb in 1:length(chromo.nb)){
        tempo.output.data <- output.data[output.data$Chr == chromo.nb[loop.chromo.nb], ]
        if(nrow(tempo.output.data) == 0){
            tempo.cat <- paste0("\nWARNING: THE ", chromo.nb[loop.chromo.nb], " CHR IS MISSING")
            cat("\n\n", tempo.cat, "\n\n", sep ="")
            fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
        }else{
            manhattan(
                tempo.output.data, 
                chr = "Chr", 
                snp = "SNP", 
                bp = "Physical.position", 
                p = "Lodscore", 
                logp = FALSE, 
                ylab = "LODSCORE", 
                genomewideline = 3, 
                suggestiveline = FALSE, 
                main = paste0("CHROMOSOME ", chromo.nb[loop.chromo.nb], "\nX-AXIS RANGE: 0-", chr.info$BP_LENGTH[chr.info$CHR_NB == chromo.nb[loop.chromo.nb]]), 
                xlim = range(c(0, chr.info$BP_LENGTH[chr.info$CHR_NB == chromo.nb[loop.chromo.nb]])), 
                ylim = c(min(output.data$Lodscore, na.rm = TRUE), max(output.data$Lodscore, na.rm = TRUE)), 
                cex = 0.6, 
                cex.main = 0.5
            )
            a <- ggplot(data = tempo.output.data, mapping = aes(x= Physical.position, y = Lodscore))
            b <- geom_line(size=1)
            # b <- geom_point(size=1)
            d <- theme_classic(base_size = 14)
            e <- xlab(paste0("Physical Position on chromosome ", chromo.nb[loop.chromo.nb]))
            f <- geom_hline(yintercept = 3, color = "red", alpha = 1, size = 1)
            g <- xlim(0, chr.info$BP_LENGTH[chr.info$CHR_NB == chromo.nb[loop.chromo.nb]])
            h <- ylim(min(output.data$Lodscore, na.rm = TRUE), max(output.data$Lodscore, na.rm = TRUE))
            i <- labs(title = paste0("CHROMOSOME ", chromo.nb[loop.chromo.nb]))
            print(a + b + d + e + f + g + h + i)
        }
    }

    fun.open.window(pdf.disp = TRUE, path.fun = path.out, pdf.name.file = "lodscore_settings", width.fun = 7, height.fun = 7, return.output = FALSE)

    for(i in 1:length(lod.cutoff)){
        if( (! all(is.na(output.data$Lodscore))) & any(output.data$Lodscore >= lod.cutoff[i])){
            assign(paste0("output.data.cut", lod.cutoff[i]), output.data[output.data$Lodscore >= lod.cutoff[i], ])
            # assign(paste0("output.data.cut", lod.cutoff[i]), refactorization_fun(get(paste0("output.data.cut", lod.cutoff[i]))))
            write.table(get(paste0("output.data.cut", lod.cutoff[i])), file = paste0(path.out, "/cutoff", lod.cutoff[i], file.output.name), append = FALSE, quote = FALSE, sep = "\t", row.names = FALSE, col.names = TRUE)

            for(loop.chromo.nb.set in 1:length(chromo.nb.set)){
                if(any(output.data$Lodscore >= lod.cutoff[i])){
                    tempo <- get(paste0("output.data.cut", lod.cutoff[i]))
                    if(any(tempo$Chr == chromo.nb.set[loop.chromo.nb.set])){
                        manhattan(
                            subset(tempo, Chr == chromo.nb.set[loop.chromo.nb.set]), 
                            chr = "Chr", 
                            snp = "SNP", 
                            bp = "Physical.position", 
                            p = "Lodscore", 
                            logp = FALSE, 
                            ylab = "LODSCORE", 
                            genomewideline = 3, 
                            suggestiveline = FALSE, 
                            main = paste0("CHROMOSOME ", chromo.nb.set[loop.chromo.nb.set] , " | LOD SCORE CUT-OFF ", lod.cutoff[i], "\n\nX-AXIS RANGE: 0-", chr.info$BP_LENGTH[chr.info$CHR_NB == chromo.nb[loop.chromo.nb.set]]), 
                            xlim = range(c(0, chr.info$BP_LENGTH[chr.info$CHR_NB == chromo.nb.set[loop.chromo.nb.set]])),
                            ylim = c(min(output.data$Lodscore, na.rm = TRUE), max(output.data$Lodscore, na.rm = TRUE)), 
                            cex = 0.6, 
                            cex.main = 0.5
                        )
                        a <- ggplot(data = subset(tempo, Chr == chromo.nb.set[loop.chromo.nb.set]), mapping = aes(x= Physical.position, y = Lodscore))
                        b <- geom_line(size=1)
                        # b <- geom_point(size=1)
                        d <- theme_classic(base_size = 14)
                        e <- xlab(paste0("Physical Position on chromosome ", chromo.nb.set[loop.chromo.nb.set]))
                        f <- geom_hline(yintercept = 3, color = "red", alpha = 1, size = 1)
                        g <- xlim(0, chr.info$BP_LENGTH[chr.info$CHR_NB == chromo.nb.set[loop.chromo.nb.set]])
                        h <- ylim(min(output.data$Lodscore, na.rm = TRUE), max(output.data$Lodscore, na.rm = TRUE))
                        i <- labs(title = paste0("CHROMOSOME ", chromo.nb.set[loop.chromo.nb.set]))
                        print(a + b + d + e + f + g + h + i)
                    }
                }
            }

        }else{
            cat(paste0("NO LODSCORE VALUES ABOVE CUT-OFF ", lod.cutoff[i], " : NO ", paste0(path.out, "/cutoff", lod.cutoff[i], file.output.name), " FILE SAVED AND PLOTTED\n"), sep ="")
        }
    }


}

save(list = ls(), file = paste0(path.out, "/lod_data.RData"))


graphics.off()

tempo.cat <- "\n################ END OF R PRINTING PROCESS"
cat(tempo.cat, sep ="")
fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)

################################ End Main code
