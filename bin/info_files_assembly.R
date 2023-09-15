################################################################
##                                                            ##
##     info_files_assembly.R                                    ##
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


args <- commandArgs(trailingOnly = TRUE)  # recover arguments written after the call of the Rscript, ie after r_341_conf $check_pedigree_info_gael_conf 
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

# setwd("C:/Users/gael/Documents/Git_projects/genetic_linkage/work/1c/409526e2898024300c61444fdaa3ea/caca")
# r_main_functions <- "C:/Users/gael/Documents/Git_projects/genetic_linkage/bin/R_main_functions_gael_20180123.R"
# files <- 'info_Group3_c15.tsv info_Group3_c13.tsv info_Group3_c08.tsv info_Group3_c07.tsv info_Group3_c16.tsv info_Group3_c09.tsv info_Group3_c14.tsv info_Group3_c10.tsv info_Group3_c06.tsv info_Group3_c12.tsv info_Group3_c03.tsv info_Group3_c11.tsv info_Group3_c01.tsv info_Group3_c05.tsv info_Group3_c04.tsv info_Group3_c02.tsv info_Group1_c06.tsv info_Group1_c07.tsv info_Group3_c17.tsv info_Group3_c23.tsv info_Group1_c01.tsv info_Group3_c22.tsv info_Group1_c05.tsv info_Group1_c03.tsv info_Group1_c08.tsv info_Group3_c19.tsv info_Group1_c02.tsv info_Group1_c04.tsv info_Group3_c20.tsv info_Group3_c21.tsv info_Group1_c09.tsv info_Group3_c18.tsv info_Group1_c10.tsv info_Group1_c21.tsv info_Group1_c18.tsv info_Group1_c17.tsv info_Group1_c16.tsv info_Group1_c13.tsv info_Group1_c19.tsv info_Group2_c01.tsv info_Group1_c22.tsv info_Group1_c15.tsv info_Group1_c14.tsv info_Group1_c23.tsv info_Group2_c02.tsv info_Group1_c12.tsv info_Group1_c11.tsv info_Group1_c20.tsv info_Group2_c10.tsv info_Group2_c09.tsv info_Group2_c04.tsv info_Group2_c14.tsv info_Group2_c18.tsv info_Group2_c11.tsv info_Group2_c07.tsv info_Group2_c03.tsv info_Group2_c06.tsv info_Group2_c13.tsv info_Group2_c08.tsv info_Group2_c05.tsv info_Group2_c15.tsv info_Group2_c12.tsv info_Group2_c16.tsv info_Group2_c17.tsv info_Group2_c23.tsv info_Group2_c22.tsv info_Group2_c20.tsv info_Group2_c21.tsv info_Group2_c19.tsv'
# map <- "map_Group2_c07.txt map_Group2_c13.txt map_Group2_c04.txt map_Group2_c10.txt map_Group2_c06.txt map_Group2_c05.txt map_Group2_c01.txt map_Group2_c02.txt map_Group2_c15.txt map_Group2_c08.txt map_Group2_c11.txt map_Group2_c16.txt map_Group2_c14.txt map_Group2_c03.txt map_Group2_c09.txt map_Group2_c12.txt map_Group2_c22.txt map_Group2_c17.txt map_Group2_c20.txt map_Group2_c19.txt map_Group2_c23.txt map_Group2_c18.txt map_Group1_c09.txt map_Group1_c02.txt map_Group1_c06.txt map_Group1_c08.txt map_Group1_c07.txt map_Group2_c21.txt map_Group1_c03.txt map_Group1_c05.txt map_Group1_c04.txt map_Group1_c01.txt map_Group1_c11.txt map_Group1_c15.txt map_Group1_c17.txt map_Group1_c12.txt map_Group1_c18.txt map_Group1_c14.txt map_Group1_c13.txt map_Group1_c19.txt map_Group1_c10.txt map_Group1_c16.txt map_Group1_c22.txt map_Group1_c20.txt map_Group1_c23.txt map_Group1_c21.txt map_Group3_c01.txt map_Group3_c02.txt map_Group3_c12.txt map_Group3_c07.txt map_Group3_c06.txt map_Group3_c16.txt map_Group3_c03.txt map_Group3_c11.txt map_Group3_c10.txt map_Group3_c14.txt map_Group3_c08.txt map_Group3_c09.txt map_Group3_c13.txt map_Group3_c04.txt map_Group3_c17.txt map_Group3_c18.txt map_Group3_c15.txt map_Group3_c05.txt map_Group3_c19.txt map_Group3_c20.txt map_Group3_c21.txt map_Group3_c22.txt map_Group3_c23.txt"
# nb_of_groups <- 3
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
    tempo.cat <- paste0("======== ERROR: THE nb_of_groups ARGUMENT IN args (", nb_of_groups,") MUST BE A SINGLE NUMERIC VALUE CORRESPONDING TO THE NUMBER OF FILE TO JOIN (INFORMATION SUM)")
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

error_file_name <- paste0("r_info_files_assembly.log") # error file
tempo.cat <- "################ INFO FILE ASSEMBLY PROCESS"
cat("\n\n", tempo.cat, "\n\n", sep ="")
fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
for(loop.chromo.nb in 1:length(chromo.nb)){ #big loop


################ Data import


    for(i in 1:nb_of_groups){
        tempo.info.file <- paste0(path.out, "/info_Group", i, "_c", chromo.nb[loop.chromo.nb], ".tsv")
        # cat(tempo.info.file, "\n\n")
        assign(paste0("info", i), read.table(tempo.info.file, header = TRUE, na.strings = "NA", row.names = NULL, dec = decimal.symbol, stringsAsFactors = FALSE))
        if(any(names(get(paste0("info", i))) %in% c("LABEL"))){
            assign(paste0("info", i), {x <- get(paste0("info", i)) ; names(x)[names(x) == "LABEL"] <- "SNP" ; x })
        } else if(any(names(get(paste0("info", i))) %in% c("LOCATION"))){
            assign(paste0("info", i), {x <- get(paste0("info", i)) ; names(x)[names(x) == "LOCATION"] <- "SNP" ; x })
        } else{
            tempo.cat <- paste0("======== ERROR: PROBLEM WITH NAMES OF ", paste0("info", i), ": ", tempo.info.file, "\nSHOULD CONTAIN: \"LABEL\" OR \"LOCATION\" AND \"INFO\"")
            cat("\n\n", tempo.cat, "\n\n", sep ="")
            fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
        }
        if( ! all(c("SNP", "INFO") %in% names(get(paste0("info", i))))){
            tempo.cat <- paste0("======== ERROR: PROBLEM WITH NAMES OF ", paste0("info", i), ": ", tempo.info.file, "\nSHOULD CONTAIN \"SNP\" AND \"iNFO\"")
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

################ Processing


    for(i in 1:(nb_of_groups - 1)){
        for(j in i:nb_of_groups){
            if( ! identical(get(paste0("info", i))$SNP, get(paste0("info", j))$SNP)){
                tempo.cat <- paste0("\nPROBLEM WITH SNP ORDER IN info" , i, " AND info" , j, " IN CHROMO ", chromo.nb[loop.chromo.nb], "\nTHE FILES CONCERNED ARE:\ninfo" , i, ": ", paste0(path.out, "/info_Group", i, "_c", chromo.nb[loop.chromo.nb], ".tsv"), "\ninfo" , j, ": ", paste0(path.out, "/info_Group", j, "_c", chromo.nb[loop.chromo.nb], ".tsv"))
                if(nrow(get(paste0("info", i))) == 0){
                    tempo.cat <- paste0(tempo.cat, "\nTHIS IS BECAUSE NO ROWS IN info" , i, " WHICH IS ", paste0(path.out, "/info_Group", i, "_c", chromo.nb[loop.chromo.nb], ".tsv\n"))
                }
                if(nrow(get(paste0("info", j))) == 0){
                    tempo.cat <- paste0(tempo.cat, "\nTHIS IS BECAUSE NO ROWS IN info" , j, " WHICH IS ", paste0(path.out, "/info_Group", i, "_c", chromo.nb[loop.chromo.nb], ".tsv\n"))
                }
                fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
                stop(paste0("\n\n", tempo.cat, "\n\n", sep =""))
            }
            if( ! identical(get(paste0("map", i))$Marker, get(paste0("map", j))$Marker)){
                tempo.cat <- paste0("\nPROBLEM WITH Marker ORDER IN map" , i, " AND map" , j, " IN CHROMO ", chromo.nb[loop.chromo.nb], "\nTHE FILES CONCERNED ARE:\nmap" , i, ": ", paste0(path.out, "/map_Group", i, "_c", chromo.nb[loop.chromo.nb], ".tsv"), "\nmap" , j, ": ", paste0(path.out, "/map_Group", j, "_c", chromo.nb[loop.chromo.nb], ".tsv"))
                fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
                stop(paste0("\n\n", tempo.cat, "\n\n", sep =""))
            }
        }
    }


    for(i in 1:nb_of_groups){
        #check that ok between information and map order
        if( ! identical(get(paste0("info", i))$SNP, get(paste0("map", i))$Marker)){
            tempo.cat <- paste0("\nPROBLEM WITH SNP ORDER IN info", i, " AND map", i, " IN CHROMO ", chromo.nb[loop.chromo.nb], "\nTHE FILES CONCERNED ARE:\ninfo", i, ": ", paste0(path.out, "/info_Group", i, "_c", chromo.nb[loop.chromo.nb], ".tsv"), "\nmap", i, ": ", paste0(path.out, "/map_Group", i, "_c", chromo.nb[loop.chromo.nb], ".txt"))
            cat("\n\n", tempo.cat, "\n\n", sep ="")
            fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
            tempo.map <- get(paste0("map", i))[order(get(paste0("map", i))$Marker), ]
            tempo.info <- get(paste0("info", i))[order(get(paste0("info", i))$SNP), ]
            snp.rm <- NULL
            if( ! all(tempo.map$Marker %in% tempo.info$SNP)){
                snp.rm <- c(snp.rm, tempo.map$Marker[ ! tempo.map$Marker %in% tempo.info$SNP])
            }
            if( ! all(tempo.info$SNP %in% tempo.map$Marker)){
                snp.rm <- c(snp.rm, tempo.info$SNP[ ! tempo.info$SNP %in% tempo.map$Marker])
            }
            if( ! is.null(snp.rm)){
                marker <- get(paste0("map", i))$Marker[ ! get(paste0("map", i))$Marker %in% snp.rm]
                phys.pos <- get(paste0("map", i))$Physpos[ !  get(paste0("map", i))$Marker %in% snp.rm]
                chr <- get(paste0("map", i))$X.Chr[ !  get(paste0("map", i))$Marker %in% snp.rm]
                assign(paste0("tempo_information_Group", i), get(paste0("info", i))[ !  get(paste0("info", i))$SNP %in% snp.rm, ])
                tempo.cat <- paste0("THE REMOVED SNP ARE:", paste0(snp.rm, collapse = " "))
                cat("\n\n", tempo.cat, "\n\n", sep ="")
                fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
            }else{
                tempo.cat <- paste0("\n======== ERROR: INCOMPREHENSIBLE PROBLEM WITH SNP NAMES IN lod", i, " AND map\nTHE FILES CONCERNED ARE:\nlod", i, ": ", paste0(path.out, "/info_Group", i, "_c", chromo.nb[loop.chromo.nb], ".tsv"), "\nmap", i, ": ", paste0(path.out, "/map_Group", i, "_c", chromo.nb[loop.chromo.nb], ".txt"))
                cat("\n\n", tempo.cat, "\n\n", sep ="")
                fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
            }
        }else{
            marker <- get(paste0("map", i))$Marker
            phys.pos <- get(paste0("map", i))$Physpos
            chr <- get(paste0("map", i))$X.Chr
            assign(paste0("tempo_information_Group", i), get(paste0("info", i)))
        }
        assign(paste0("tempo.data", i), data.frame(Chr = chr, SNP = marker, Information = get(paste0("tempo_information_Group", i))$INFO, Physical.position = phys.pos, Group = get(paste0("tempo_information_Group", i))$GROUP))
        if(loop.chromo.nb == 1 & i == 1){
            output.data <- get(paste0("tempo.data", i))
        }else{
            output.data <- rbind(output.data, get(paste0("tempo.data", i)))
        }
    }

} # big loop end


if(all(is.na(output.data$Information))){
    tempo.cat <- paste0("\nNO INFORMATION CAN BE SAVED OR DRAWN BECAUSE NA ONLY")
    cat("\n\n", tempo.cat, "\n\n", sep ="")
    fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
}else{
    if(any(is.na(output.data$Information))){
        tempo.cat <- paste0("SOME ROWS OF THE FINAL DATAFILE CONTAIN NA IN INFORMATION VALUES. THESE ROWS WILL BE REMOVED IN SUBSEQUENT SAVINGS AND DRAWINGS.\nREMOVED ROWS WILL BE SAVED IN: ", path.out, "/rm.rows.", paste0("complete_information_group", i, ".tsv"))
        cat("\n\n", tempo.cat, "\n\n", sep ="")
        fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
        rm.data <- output.data[is.na(output.data$Information), ]
        output.data <- output.data[ ! is.na(output.data$Information), ]
        write.table(rm.data, file = paste0(path.out, "/rm.rows.", paste0("complete_information.tsv")), append = FALSE, quote = FALSE, sep = "\t", row.names = FALSE, col.names = TRUE)
    }else{
        tempo.cat <- paste0("NO NA IN INFORMATION VALUES. NO ROWS REMOVED")
        cat("\n\n", tempo.cat, "\n\n", sep ="")
        fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)
    }

####### saving files

    tempo.cat <- paste0("THE FULL INFORMATION FILE IS SAVED IN: ", path.out, "/complete_information.tsv")
    cat("\n\n", tempo.cat, "\n\n", sep ="")
    write.table(output.data, file = paste0(path.out, "/complete_information.tsv"), append = FALSE, quote = FALSE, sep = "\t", row.names = FALSE, col.names = TRUE)
}





tempo.cat <- "\n################ END OF INFO FILE ASSEMBLY PROCESS"
cat(tempo.cat, sep ="")
fun.export.data(path = path.out, data = tempo.cat, output = error_file_name, sep = 2)

################################ End Main code
