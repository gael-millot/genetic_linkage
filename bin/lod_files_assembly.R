################################################################
##                                                            ##
##     lod_files_assembly.R                                    ##
##                                                            ##
##     Gael A. Millot                                         ##
##                                                            ##
##     Version v1                                             ##
##                                                            ##
################################################################


################################ Introduction


# Compatible with R v4.2.1


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
# may be convert arg[2] as numeric 
tempo.arg.names <- c("r_main_functions", "files", "map_files", "nb_of_groups", "path.out")




if(length(args) != length(tempo.arg.names)){
  tempo.cat <- paste0("======== ERROR: THE NUMBER OF ELEMENTS IN args (", length(args),") IS DIFFERENT FROM THE NUMBER OF ELEMENTS IN tempo.arg.names (", length(tempo.arg.names),")\nargs:", paste0(args, collapse = ","), "\ntempo.arg.names:", paste0(tempo.arg.names, collapse = ","))
  stop(tempo.cat)
}
for(i in 1:length(tempo.arg.names)){
    assign(tempo.arg.names[i], args[i])
}


################ Debug

# setwd("C:/Users/gael/Documents/Git_projects/linkage_analysis/work/0f/1a045ac056e10d8eceee3240c0fc2a/caca")
# r_main_functions <- "C:/Users/gael/Documents/Git_projects/linkage_analysis/bin/R_main_functions_gael_20180123.R"
# files <- 'lodscore_Group3_c15.tsv lodscore_Group3_c13.tsv lodscore_Group3_c08.tsv lodscore_Group3_c07.tsv lodscore_Group3_c16.tsv lodscore_Group3_c09.tsv lodscore_Group3_c14.tsv lodscore_Group3_c10.tsv lodscore_Group3_c06.tsv lodscore_Group3_c12.tsv lodscore_Group3_c03.tsv lodscore_Group3_c11.tsv lodscore_Group3_c01.tsv lodscore_Group3_c05.tsv lodscore_Group3_c04.tsv lodscore_Group3_c02.tsv lodscore_Group1_c06.tsv lodscore_Group1_c07.tsv lodscore_Group3_c17.tsv lodscore_Group3_c23.tsv lodscore_Group1_c01.tsv lodscore_Group3_c22.tsv lodscore_Group1_c05.tsv lodscore_Group1_c03.tsv lodscore_Group1_c08.tsv lodscore_Group3_c19.tsv lodscore_Group1_c02.tsv lodscore_Group1_c04.tsv lodscore_Group3_c20.tsv lodscore_Group3_c21.tsv lodscore_Group1_c09.tsv lodscore_Group3_c18.tsv lodscore_Group1_c10.tsv lodscore_Group1_c21.tsv lodscore_Group1_c18.tsv lodscore_Group1_c17.tsv lodscore_Group1_c16.tsv lodscore_Group1_c13.tsv lodscore_Group1_c19.tsv lodscore_Group2_c01.tsv lodscore_Group1_c22.tsv lodscore_Group1_c15.tsv lodscore_Group1_c14.tsv lodscore_Group1_c23.tsv lodscore_Group2_c02.tsv lodscore_Group1_c12.tsv lodscore_Group1_c11.tsv lodscore_Group1_c20.tsv lodscore_Group2_c10.tsv lodscore_Group2_c09.tsv lodscore_Group2_c04.tsv lodscore_Group2_c14.tsv lodscore_Group2_c18.tsv lodscore_Group2_c11.tsv lodscore_Group2_c07.tsv lodscore_Group2_c03.tsv lodscore_Group2_c06.tsv lodscore_Group2_c13.tsv lodscore_Group2_c08.tsv lodscore_Group2_c05.tsv lodscore_Group2_c15.tsv lodscore_Group2_c12.tsv lodscore_Group2_c16.tsv lodscore_Group2_c17.tsv lodscore_Group2_c23.tsv lodscore_Group2_c22.tsv lodscore_Group2_c20.tsv lodscore_Group2_c21.tsv lodscore_Group2_c19.tsv'
# map <- "map_Group2_c07.txt map_Group2_c13.txt map_Group2_c04.txt map_Group2_c10.txt map_Group2_c06.txt map_Group2_c05.txt map_Group2_c01.txt map_Group2_c02.txt map_Group2_c15.txt map_Group2_c08.txt map_Group2_c11.txt map_Group2_c16.txt map_Group2_c14.txt map_Group2_c03.txt map_Group2_c09.txt map_Group2_c12.txt map_Group2_c22.txt map_Group2_c17.txt map_Group2_c20.txt map_Group2_c19.txt map_Group2_c23.txt map_Group2_c18.txt map_Group1_c09.txt map_Group1_c02.txt map_Group1_c06.txt map_Group1_c08.txt map_Group1_c07.txt map_Group2_c21.txt map_Group1_c03.txt map_Group1_c05.txt map_Group1_c04.txt map_Group1_c01.txt map_Group1_c11.txt map_Group1_c15.txt map_Group1_c17.txt map_Group1_c12.txt map_Group1_c18.txt map_Group1_c14.txt map_Group1_c13.txt map_Group1_c19.txt map_Group1_c10.txt map_Group1_c16.txt map_Group1_c22.txt map_Group1_c20.txt map_Group1_c23.txt map_Group1_c21.txt map_Group3_c01.txt map_Group3_c02.txt map_Group3_c12.txt map_Group3_c07.txt map_Group3_c06.txt map_Group3_c16.txt map_Group3_c03.txt map_Group3_c11.txt map_Group3_c10.txt map_Group3_c14.txt map_Group3_c08.txt map_Group3_c09.txt map_Group3_c13.txt map_Group3_c04.txt map_Group3_c17.txt map_Group3_c18.txt map_Group3_c15.txt map_Group3_c05.txt map_Group3_c19.txt map_Group3_c20.txt map_Group3_c21.txt map_Group3_c22.txt map_Group3_c23.txt"
# nb_of_groups <- 3
# map_file <- "map.txt"
# path.out <- "."




################ end Debug



if( ! (is.character(files) & length(files) == 1)){
    tempo.cat <- paste0("======== ERROR: THE files ARGUMENT IN args (", files,") MUST BE A SINGLE CHARACTER STRING")
    stop(tempo.cat)
}else{
    files <- unlist(strsplit(files, ","))
}
nb_of_groups <- as.numeric(nb_of_groups)
if( ! is.numeric(nb_of_groups)){
    tempo.cat <- paste0("======== ERROR: THE nb_of_groups ARGUMENT IN args (", nb_of_groups,") MUST BE A SINGLE NUMERIC VALUE CORRESPONDING TO THE NUMBER OF FILE TO JOIN (LODSCORE SUM)")
    stop(tempo.cat)
}
if( ! (is.character(map_files) & length(map_files) == 1)){
    tempo.cat <- paste0("======== ERROR: THE map_file ARGUMENT IN args (", map_files,") MUST BE A SINGLE CHARACTER STRING")
    stop(tempo.cat)
}
if( ! (is.character(path.out) & length(path.out) == 1)){
    tempo.cat <- paste0("======== ERROR: THE path.out ARGUMENT IN args (", path.out,") MUST BE A SINGLE CHARACTER STRING")
    stop(tempo.cat)
}




################ Parameters


decimal.symbol <- "." # for argument dec of read.table function
chromo.nb <- c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23")
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

error_file_name <- paste0("r_lod_files_assembly.log") # error file
tempo.cat <- "################ LOD FILE ASSEMBLY PROCESS"
cat("\n\n", tempo.cat, "\n\n", sep ="")
fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
for(loop.chromo.nb in 1:length(chromo.nb)){ #big loop


################ Data import
    test.log <- rep(FALSE, nb_of_groups)
    for(i in 1:nb_of_groups){
        tempo.name <- paste0(path.out, "/lodscore_Group", i, "_c", chromo.nb[loop.chromo.nb], ".tsv")
        if( ! file.exists(tempo.name)){
            tempo.cat <- paste0("\nWARNING: THE ", tempo.name, " LODSCORE FILE IS MISSING")
            cat("\n\n", tempo.cat, "\n\n", sep ="")
            fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
            test.log[i] <- TRUE
        }else{
            tempo.lod.file <- paste0(path.out, "/lodscore_Group", i, "_c", chromo.nb[loop.chromo.nb], ".tsv")
            # cat(tempo.lod.file, "\n\n")
            assign(paste0("lod", i), read.table(tempo.lod.file, header = TRUE, na.strings = "NA", row.names = NULL, dec = decimal.symbol, stringsAsFactors = FALSE))
            if(any(names(get(paste0("lod", i))) %in% c("LABEL"))){
                assign(paste0("lod", i), {x <- get(paste0("lod", i)) ; names(x)[names(x) == "LABEL"] <- "SNP" ; x })
            } else if(any(names(get(paste0("lod", i))) %in% c("LOCATION"))){
                assign(paste0("lod", i), {x <- get(paste0("lod", i)) ; names(x)[names(x) == "LOCATION"] <- "SNP" ; x })
            } else{
                tempo.cat <- paste0("======== ERROR: PROBLEM WITH NAMES OF ", paste0("lod", i), ": ", tempo.lod.file, "\nSHOULD CONTAIN: \"LABEL\" OR \"LOCATION\" AND \"LOD\"")
                cat("\n\n", tempo.cat, "\n\n", sep ="")
                fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
            }
            if( ! all(c("SNP", "LOD") %in% names(get(paste0("lod", i))))){
                tempo.cat <- paste0("======== ERROR: PROBLEM WITH NAMES OF ", paste0("lod", i), ": ", tempo.lod.file, "\nSHOULD CONTAIN \"SNP\" AND \"LOD\"")
                cat("\n\n", tempo.cat, "\n\n", sep ="")
                fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
            }
            tempo.map.file <- paste0(path.out, "/map_Group", i, "_c", chromo.nb[loop.chromo.nb], ".txt")
            assign(paste0("map", i), read.table(tempo.map.file, header = TRUE, na.strings = "NA", dec = decimal.symbol, row.names = NULL, comment.char = "", stringsAsFactors = FALSE))
            if( ! all(names(get(paste0("map", i))) %in% c("X.Chr", "Genpos", "Marker", "Physpos", "Nr", "GROUP"))){
                tempo.cat <- paste0("======== ERROR: PROBLEM WITH NAMES OF map: ", tempo.map.file, "\nSHOULD BE: \"X.Chr\", \"Genpos\", \"Marker\", \"Physpos\", \"Nr\", \"GROUP\"")
                cat("\n\n", tempo.cat, "\n\n", sep ="")
                fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
            }
        }
    }
    if( ! (sum(test.log) == 0 | sum(test.log) == nb_of_groups)){
        tempo.cat <- paste0("======== ERROR: IN THE ", paste0(path.out, "/lodscore_GroupX_c", chromo.nb[loop.chromo.nb], ".tsv"), "\nALL GROUPS MUST BE PRESENT OR ABSENT.\nHERE, GROUPS PRESENT ARE:\n", paste(path.out, "/lodscore_Group", c(1:nb_of_groups)[test.log == FALSE], "_c", chromo.nb[loop.chromo.nb], ".tsv", collapse = "\n"), "GROUPS ABSENT ARE:\n", paste(path.out, "/lodscore_Group", c(1:nb_of_groups)[test.log == TRUE], "_c", chromo.nb[loop.chromo.nb], ".tsv", collapse = "\n"))
        stop(tempo.cat)
    }

################ Processing


    for(i in 1:(nb_of_groups - 1)){
        for(j in i:nb_of_groups){
            if( ! identical(get(paste0("lod", i))$SNP, get(paste0("lod", j))$SNP)){
                test.log <- FALSE
                tempo.cat <- paste0("\nPROBLEM WITH SNP ORDER IN lod" , i, " AND lod" , j, " IN CHROMO ", chromo.nb[loop.chromo.nb], "\nTHE FILES CONCERNED ARE:\nlod" , i, ": ", paste0(path.out, "/lodscore_Group", i, "_c", chromo.nb[loop.chromo.nb], ".tsv"), "\nlod" , j, ": ", paste0(path.out, "/lodscore_Group", j, "_c", chromo.nb[loop.chromo.nb], ".tsv"))
                if(nrow(get(paste0("lod", i))) == 0 & nrow(get(paste0("lod", j))) != 0){
                    test.log <- TRUE
                    tempo.cat <- paste0(tempo.cat, "\nTHIS IS BECAUSE NO ROWS IN lod" , i, " WHICH IS ", paste0(path.out, "/lodscore_Group", i, "_c", chromo.nb[loop.chromo.nb], ".tsv\nBEWARE: THE LODSCORE ADDITION WILL NOT TAKE THIS FILE INTO ACCOUNT (LODSCORE DECREASED FOR CHROMO ", chromo.nb[loop.chromo.nb], " COMPARED TO THE OTHER CHROMOSOMES)\nIF ON Chr23 (ChrX), NO ROWS COULD MEAN \"NO INFORMATIVE FAMILY\" BECAUSE ONLY MALES IN THE PEDIGREE"))
                }
                if(nrow(get(paste0("lod", i))) != 0 & nrow(get(paste0("lod", j))) == 0){
                    test.log <- TRUE
                    tempo.cat <- paste0(tempo.cat, "\nTHIS IS BECAUSE NO ROWS IN lod" , j, " WHICH IS ", paste0(path.out, "/lodscore_Group", j, "_c", chromo.nb[loop.chromo.nb], ".tsv\nBEWARE: THE LODSCORE ADDITION WILL NOT TAKE THIS FILE INTO ACCOUNT (LODSCORE DECREASED FOR CHROMO ", chromo.nb[loop.chromo.nb], " COMPARED TO THE OTHER CHROMOSOMES)\nIF ON Chr23 (ChrX), NO ROWS COULD MEAN \"NO INFORMATIVE FAMILY\" BECAUSE ONLY MALES IN THE PEDIGREE"))
                }
                fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
                if(test.log == TRUE){
                    cat(paste0("\n\n", tempo.cat, "\n\n", sep =""))
                }else{
                    cat(paste0("\n\n", tempo.cat, "\n\n", sep =""))
                }
            }
            if( ! identical(get(paste0("map", i))$Marker, get(paste0("map", j))$Marker)){
                tempo.cat <- paste0("\nPROBLEM WITH Marker ORDER IN map" , i, " AND map" , j, " IN CHROMO ", chromo.nb[loop.chromo.nb], "\nTHE FILES CONCERNED ARE:\nmap" , i, ": ", paste0(path.out, "/map_Group", i, "_c", chromo.nb[loop.chromo.nb], ".tsv"), "\nmap" , j, ": ", paste0(path.out, "/map_Group", j, "_c", chromo.nb[loop.chromo.nb], ".tsv"))
                fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
                stop(paste0("\n\n", tempo.cat, "\n\n", sep =""))
            }
        }
    }
    #sum of the lodscore for the different groups
    lodsum <- NULL
    for(i in 1:nb_of_groups){
        if( is.null(lodsum) & nrow(get(paste0("lod", i))) != 0){
            lodsum <- get(paste0("lod", i))$LOD
        }else if ( ( ! is.null(lodsum)) & nrow(get(paste0("lod", i))) != 0){
            lodsum <- lodsum + get(paste0("lod", i))$LOD
        }
    }
    if(is.null(lodsum)){
        tempo.cat <- paste0("\nPROBLEM: IT SEEMS THAT NO INFORMATIVE FAMILY WAS PRESENT IN CHROMO ", chromo.nb[loop.chromo.nb], ". NO LODSCORE COMPUTED FOR THIS CHROMOSOME")
        cat("\n\n", tempo.cat, "\n\n", sep ="")
        fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
        marker <- get("map1")$Marker # because all the maps among groups are identical
        phys.pos <- get("map1")$Physpos
        chr <- get("map1")$X.Chr
        lodscore <- rep(NA, length(get("map1")$Marker))
    }else{
        #check that ok between lodscore and map order
        if( ! identical(get("lod1")$SNP, get("map1")$Marker)){
            tempo.cat <- paste0("\nPROBLEM WITH SNP ORDER IN lod1 AND map1 IN CHROMO ", chromo.nb[loop.chromo.nb], "\nTHE FILES CONCERNED ARE:\nlod1: ", paste0(path.out, "/lodscore_Group1_c", chromo.nb[loop.chromo.nb], ".tsv"), "\nmap1: ", paste0(path.out, "/map_Group1_c", chromo.nb[loop.chromo.nb], ".txt"))
            cat("\n\n", tempo.cat, "\n\n", sep ="")
            fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
            tempo.map <- get("map1")[order(get("map1")$Marker), ]
            tempo.lod1 <- get("lod1")[order(get("lod1")$SNP), ]
            snp.rm <- NULL
            if( ! all(tempo.map$Marker %in% tempo.lod1$SNP)){
                snp.rm <- c(snp.rm, tempo.map$Marker[ ! tempo.map$Marker %in% tempo.lod1$SNP])
            }
            if( ! all(tempo.lod1$SNP %in% tempo.map$Marker)){
                snp.rm <- c(snp.rm, tempo.lod1$SNP[ ! tempo.lod1$SNP %in% tempo.map$Marker])
            }
            if( ! is.null(snp.rm)){
                marker <- get("map1")$Marker[ ! get("map1")$Marker %in% snp.rm]
                phys.pos <- get("map1")$Physpos[ !  get("map1")$Marker %in% snp.rm]
                chr <- get("map1")$X.Chr[ !  get("map1")$Marker %in% snp.rm]
                lodscore <- lodsum[ !  lod1$SNP %in% snp.rm]
                tempo.cat <- paste0("THE REMOVED SNP ARE:",  if(length(snp.rm) > 200){" see r_lod_files_assembly.log"}else{paste0(snp.rm, collapse = " ")})
                cat("\n\n", tempo.cat, "\n\n", sep ="")
                fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
            }else{
                tempo.cat <- paste0("\n======== ERROR: INCOMPREHENSIBLE PROBLEM WITH SNP NAMES IN lod1 AND map\nTHE FILES CONCERNED ARE:\nlod1: ", paste0(path.out, "/lodscore_Group1_c", chromo.nb[loop.chromo.nb], ".tsv"), "\nmap1: ", paste0(path.out, "/map_Group1_c", chromo.nb[loop.chromo.nb], ".txt"))
                cat("\n\n", tempo.cat, "\n\n", sep ="")
                fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
            }
        }else{
            marker <- get("map1")$Marker
            phys.pos <- get("map1")$Physpos
            chr <- get("map1")$X.Chr
            lodscore <- lodsum
        }
        tempo.data <- data.frame(Chr = chr, SNP = marker, Lodscore = lodscore, Physical.position = phys.pos)
        if(loop.chromo.nb == 1){
            output.data <- tempo.data
        }else{
            output.data <- rbind(output.data, tempo.data)
        }
    }
} # big loop end


if(all(is.na(output.data$Lodscore))){
    tempo.cat <- paste0("\nNO LODSCORE CAN BE SAVED OR DRAWN BECAUSE NA ONLY")
    cat("\n\n", tempo.cat, "\n\n", sep ="")
    fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
}else{
    if(any(is.na(output.data$Lodscore))){
        tempo.cat <- paste0("SOME ROWS OF THE FINAL DATAFILE CONTAIN NA IN LODSCORE VALUES. THESE ROWS WILL BE REMOVED IN SUBSEQUENT SAVINGS AND DRAWINGS.\nREMOVED ROWS WILL BE SAVED IN: ", path.out, "/rm.rows.", file.output.name)
        cat("\n\n", tempo.cat, "\n\n", sep ="")
        fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
        rm.data <- output.data[is.na(output.data$Lodscore), ]
        output.data <- output.data[ ! is.na(output.data$Lodscore), ]
        write.table(rm.data, file = paste0(path.out, "/rm.rows.", file.output.name), append = FALSE, quote = FALSE, sep = "\t", row.names = FALSE, col.names = TRUE)
    }else{
        tempo.cat <- paste0("NO NA IN LODSCORE VALUES. NO ROWS REMOVED")
        cat("\n\n", tempo.cat, "\n\n", sep ="")
        fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
    }

####### saving files

    tempo.cat <- paste0("THE FULL LODSCORE FILE IS SAVED IN: ", path.out, "/", file.output.name)
    cat("\n\n", tempo.cat, "\n\n", sep ="")
    write.table(output.data, file = paste0(path.out, "/", file.output.name), append = FALSE, quote = FALSE, sep = "\t", row.names = FALSE, col.names = TRUE)

}

tempo.cat <- "\n################ END OF LOD FILE ASSEMBLY PROCESS"
cat(tempo.cat, sep ="")
fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)

################################ End Main code
