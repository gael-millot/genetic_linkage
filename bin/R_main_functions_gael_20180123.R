################################################################
##                                                            ##
##     MAIN FUNCTIONS                                         ##
##                                                            ##
##     Gael A. Millot                                         ##
##     Version v1                                             ##
##     Compatible with R v3.2.2                               ##
##                                                            ##
################################################################


# BEWARE: do not forget to save the modifications also as .txt file and .R file

################################ Outline ################################


# make insersion of internal rows, colum, compartiments, or elements in objects. See chromo.painting code tempo.code <- tempo.phasing[1, ]

################ Exporting results (text & tables)  1
################ Recovering object information  2
################ Checking the class, type, mode and length of parameter 3
################ checking row & col names, and dimensions of 2D dataset 6
################ flipping data to have column name as a qualitative column and vice-versa   11
################ Refactorization (remove classes that are not anymore present)  12
################ Rounding number if decimal present 13
################ Matrix flip for colorization   14
################ Matrix colorization and color scale    14
################ Standard Matrix    14
################ Matrix plot Gradient color (raster)    16
################ Conversion of a numeric matrix into hexadecimal color matrix   24
################ Graphic window size & margins  26
################ standard plots 26
################ Matrix plots keeping same matrix sizes 26
################ Matrix plots keeping same window sizes 30
################ Open graph windows in R or pdf 35
################ Graphical parameters prior plotting    35
################ Plot   37
################ Matrix plot for fixed windows (raster) 37
################ Matrix plot (raster)   41
################ Matrix plot    45
################ Graphical features post plotting   48
################ Standard plot  48
################ Matrix plot    53
################ Matrix scale post plotting 55
################ Closing all the pdf files (but not the R windows)  56
################ Colors of the variant names in the stripcharts and boxplots    56
################ Stripcharts in waterfall   56
################ iteration plotting 57
################ stat plotting  59
################ Flat Pedigree Drawing  63
################ Manhattan plot 65


# This is the order for plottings (all are mandatory functions):
# fun.window.size()
# fun.open.window()
# fun.graph.param() or fun.graph.param.prior.axis()
# plot()
# fun.axis.bg.feature() if fun.graph.param.prior.axis() has been used
# fun.close.pdf()


################ Exporting results (text & tables)


fun.export.data <- function(data, output, path = "C:/Users/Gael/Desktop", no.overwrite = TRUE, rownames.kept = FALSE, vector.cat = FALSE, sep = 2){
# AIM:
# print a string or a data object into a txt file
# REQUIRED FUNCTIONS
# none
# ARGUMENTS
# data: object to print in the .txt. file
# output: name of the output file
# path: location of the output file
# no.overwrite: (logical) if output file already exists, defines if the printing is appended (default TRUE) or if the output file content is erased before printing (FALSE)
# rownames.kept: (logical) defines whether row names have to be removed or not in small tables (less than length.rows rows)
# vector.cat (logical). If TRUE print a vector of length > 1 using cat() instead of capture.output(). Otherwise (default FALSE) the opposite
# sep: number of separating lines after printed data (must be integer)
# RETURN
# nothing returned
# EXAMPLES
# 
if(all(class(data) %in% c("matrix", "data.frame"))){
if(rownames.kept == FALSE & nrow(data) != 0 & nrow(data) <= 4){
rownames.output.tables <- ""
length.rows <- nrow(data)
for(i in 1:length.rows){ # suppress the rownames of the first 4 rows. This method cannot be extended to more rows as the printed table is shifted on the right because of "big empty rownames"
rownames.output.tables <- c(rownames.output.tables, paste0(rownames.output.tables[i]," ", collapse=""))
}
row.names(data) <- rownames.output.tables[1:length.rows]
}
capture.output(data, file=paste0(path, "/", output), append = no.overwrite)
}else if(is.vector(data) & all(class(data) != "list") & (length(data) == 1 | vector.cat == TRUE)){
cat(data, file= paste0(path, "/", output), append = no.overwrite)
}else{ # other (array, table, list, factor or vector with vector.cat = FALSE)
capture.output(data, file=paste0(path, "/", output), append = no.overwrite)
}
sep.final <- paste0(rep("\n", sep), collapse = "")
write(sep.final, file= paste0(path, "/", output), append = TRUE)
}


################ Recovering object information


object_info_fun <- function(data){
# AIM:
# provide info for a single object
# REQUIRED FUNCTIONS
# none
# ARGUMENTS
# data: object to test
# RETURN
# a list containing the info
# EXAMPLES
# data = data.frame(a = 1:3) ;
data.name <- deparse(substitute(data))
output <- list("FILE_NAME" = data.name)
tempo <- list("FILE_HEAD" = head(data))
output <- c(output, tempo)
tempo <- list("FILE_TAIL" = tail(data))
output <- c(output, tempo)
tempo <- list("FILE_DIMENSION" = dim(data))
names(tempo[[1]]) <- c("NROW", "NCOL")
output <- c(output, tempo)
tempo <- list("STRUCTURE" = ls.str(data))
output <- c(output, tempo)
tempo <- list("SUMMARY" = summary(data))
output <- c(output, tempo)
if(class(data) == "data.frame" | class(data) == "matrix"){
tempo <- list("COLUM_NAMES" = names(data))
output <- c(output, tempo)
}
if(class(data) == "data.frame"){
tempo <- list("COLUMN_TYPE" = sapply(data, FUN = "class"))
output <- c(output, tempo)
}
if(class(data) == "list"){
tempo <- list("COMPARTMENT_NAMES" = names(data))
output <- c(output, tempo)
}
return(output)
}


################ Checking the class, type, mode and length of parameter


param_check_fun <- function(data, data.name = NULL, print = TRUE, options = NULL, all.options.in.data = FALSE, class = NULL, typeof = NULL, mode = NULL, prop = NULL, double.but.integer = FALSE, length = NULL){
# AIM:
# check the options, or class, type, mode and length of the parameter data
# If options is null, then at least class, type, mode or length must be non null
# If options is non null, then class, type and mode must be NULL, and length can be NULL or specified
# REQUIRED FUNCTIONS
# none
# ARGUMENTS
# data: object to test
# data.name: name of the object to test
# print: print the error message if $problem is TRUE ?
# options: a vector of possible values for data
# all.options.in.data: If TRUE, all of the options must be present at least once in data, and nothing else. If FALSE, some of the options must be present in data, and nothing else
# class: one of the class() result
# typeof: one of the typeof() result
# mode: one of the mode() result (for non vector object)
# prop: logical, is the numeric value between 0 and 1 (proportion)?
# double.but.integer: logical. If TRUE, no error is reported if argument is set to typeof = "integer" or class = "integer", while the reality is typeof = "double" or class = "numeric" but the numbers have a zero as modulo (remainder of a division). This means that i<-1 , which is typeof(i) -> "double" is considered as integer with double.but.integer = TRUE
# length: length of the object
# RETURN
# a list containing:
# $problem: logical. Is there any problem detected ?
# $text: the problem detected
# EXAMPLES
# test <- 1:3 ; param_check_fun(data = test, data.name = NULL, print = TRUE, options = NULL, all.options.in.data = FALSE, class = NULL, typeof = NULL, mode = NULL, prop = TRUE, double.but.integer = FALSE, length = NULL)
# test <- 1:3 ; param_check_fun(data = test, print = TRUE, class = "numeric", typeof = NULL, double.but.integer = FALSE)
# data = 1:3 ; data.name = NULL ; print = TRUE; options = NULL ; all.options.in.data = FALSE ; class = "numeric" ; typeof = NULL ; mode = NULL ; prop = NULL ; double.but.integer = TRUE ; length = NULL
# argument checking
if( ! (all(class(print) == "logical") & length(print) == 1)){
tempo.cat <- paste0("\n\n================\n\nERROR: THE print ARGUMENT MUST BE TRUE OR FALSE\n\n================\n\n")
stop(tempo.cat, "\n\n")
}
if( ! is.null(data.name)){
if( ! (length(data.name) == 1 & class(data.name) == "character")){
tempo.cat <- paste0("\n\n================\n\nERROR: data.name ARGUMENT MUST BE A SINGLE CHARACTER ELEMENT AND NOT ", paste(data.name, collapse = " "), "\n\n================\n\n")
stop(tempo.cat, "\n\n")
}
}
if(is.null(options) & is.null(class) & is.null(typeof) & is.null(mode) & is.null(prop) & is.null(length)){
tempo.cat <- paste0("\n\n================\n\nERROR: AT LEAST ONE OF THE options, class, typeof, mode prop, OR length ARGUMENT MUST BE SPECIFIED\n\n================\n\n")
stop(tempo.cat, "\n\n")
}
if( ! is.null(options) & ( ! is.null(class) | ! is.null(typeof) | ! is.null(mode) | ! is.null(prop))){
tempo.cat <- paste0("\n\n================\n\nERROR: THE class, typeof, mode AND prop ARGUMENTS MUST BE NULL IF THE option ARGUMENT IS SPECIFIED\nTHE option ARGUMENT MUST BE NULL IF THE class AND/OR typeof AND/OR mode  AND/OR prop ARGUMENT IS SPECIFIED\n\n================\n\n")
stop(tempo.cat, "\n\n")
}
if( ! is.null(class)){
if( ! all(class %in% c("logical", "integer", "numeric", "complex", "character", "matrix", "array", "data.frame", "list", "factor", "table", "expression", "name", "symbol", "function"))){
tempo.cat <- paste0("\n\n================\n\nERROR: class ARGUMENT MUST BE ONE OF THESE VALUE:\n\"logical\", \"integer\", \"numeric\", \"complex\", \"character\", \"matrix\", \"array\", \"data.frame\", \"list\", \"factor\", \"table\", \"expression\", \"name\", \"symbol\", \"function\" \n\n================\n\n")
stop(tempo.cat, "\n\n")
}
}
if( ! is.null(typeof)){
if( ! (all(typeof %in% c("logical", "integer", "double", "complex", "character", "list", "expression", "name", "symbol", "closure", "special", "builtin")) & length(typeof) == 1)){
tempo.cat <- paste0("\n\n================\n\nERROR: typeof ARGUMENT MUST BE ONE OF THESE VALUE:\n\"logical\", \"integer\", \"double\", \"complex\", \"character\", \"list\", \"expression\", \"name\", \"symbol\", \"closure\", \"special\", \"builtin\" \n\n================\n\n")
stop(tempo.cat, "\n\n")
}
}
if( ! is.null(mode)){
if( ! (all(mode %in% c("logical", "numeric", "complex", "character", "list", "expression", "name", "symbol", "function")) & length(mode) == 1)){
tempo.cat <- paste0("\n\n================\n\nERROR: mode ARGUMENT MUST BE ONE OF THESE VALUE:\n\"logical\", \"numeric\", \"complex\", \"character\", \"list\", \"expression\", \"name\", \"symbol\", \"function\"\n\n================\n\n")
stop(tempo.cat, "\n\n")
}
}
if( ! is.null(prop)){
if( ! (is.logical(prop) | length(prop) == 1)){
tempo.cat <- paste0("\n\n================\n\nERROR: prop ARGUMENT MUST BE A SINGLE LOGICAL VALUE\n\n================\n\n")
stop(tempo.cat, "\n\n")
}else if(prop == TRUE){
if( ! is.null(class)){
if(class != "numeric"){
tempo.cat <- paste0("\n\n================\n\nERROR: class ARGUMENT CANNOT BE OTHER THAN \"numeric\" IF prop ARGUMENT IS TRUE\n\n================\n\n")
stop(tempo.cat, "\n\n")
}
}
if( ! is.null(mode)){
if(mode != "numeric"){
tempo.cat <- paste0("\n\n================\n\nERROR: mode ARGUMENT CANNOT BE OTHER THAN \"numeric\" IF prop ARGUMENT IS TRUE\n\n================\n\n")
stop(tempo.cat, "\n\n")
}
}
if( ! is.null(typeof)){
if(typeof != "double"){
tempo.cat <- paste0("\n\n================\n\nERROR: typeof ARGUMENT CANNOT BE OTHER THAN \"double\" IF prop ARGUMENT IS TRUE\n\n================\n\n")
stop(tempo.cat, "\n\n")
}
}
}
}
if( ! (all(class(double.but.integer) == "logical") & length(double.but.integer) == 1)){
tempo.cat <- paste0("\n\n================\n\nERROR: THE double.but.integer ARGUMENT MUST BE TRUE OR FALSE\n\n================\n\n")
stop(tempo.cat, "\n\n")
}
if( ! is.null(length)){
if( ! (is.numeric(length) & length(length) == 1 & ! grepl(length, pattern = "\\."))){
tempo.cat <- paste0("\n\n================\n\nERROR: length ARGUMENT MUST BE A SINGLE INTEGER VALUE\n\n================\n\n")
stop(tempo.cat, "\n\n")
}
}
if( ! (is.logical(all.options.in.data) & length(all.options.in.data) == 1)){
tempo.cat <- paste0("\n\n================\n\nERROR: all.options.in.data ARGUMENT MUST BE A SINGLE LOGICAL VALUE (TRUE OR FALSE)\n\n================\n\n")
stop(tempo.cat, "\n\n")
}
# end argument checking
if(is.null(data.name)){
data.name <- deparse(substitute(data))
}
problem <- FALSE
text <- paste0("NO PROBLEM DETECTED FOR THE ", data.name, " PARAMETER")
if( ! is.null(options)){
text <- ""
if( ! all(data %in% options)){
problem <- TRUE
text <- paste0("PROBLEM: THE ", data.name, " PARAMETER MUST BE SOME OF THESE OPTIONS: ", paste(options, collapse = " "), "\nTHE PROBLEMATIC ELEMENTS OF ", data.name, " ARE: ", unique(data[ ! (data %in% options)]))
}
if(all.options.in.data == TRUE){
if( ! all(options %in% data)){
problem <- TRUE
if(text == ""){
text <- paste0("PROBLEM: THE ", data.name, " PARAMETER MUST BE SOME OF THESE OPTIONS: ", paste(options, collapse = " "), "\nTHE PROBLEMATIC ELEMENTS OF ", data.name, " ARE: ", unique(data[ ! (data %in% options)]))
}else{
text <- paste0(text, "\nPROBLEM: THE ", data.name, " PARAMETER MUST BE SOME OF THESE OPTIONS: ", paste(options, collapse = " "), "\nTHE PROBLEMATIC ELEMENTS OF ", data.name, " ARE: ", unique(data[ ! (data %in% options)]))
}
}
}
if( ! is.null(length)){
if(length(data) != length){
problem <- TRUE
if(text == ""){
text <- paste0("PROBLEM: THE LENGTH OF ", data.name, " MUST BE ", length, " AND NOT ", length(data))
}else{
text <- paste0(text, "\nPROBLEM: THE LENGTH OF ", data.name, " MUST BE ", length, " AND NOT ", length(data))
}
}
}
if(text == ""){
text <- paste0("NO PROBLEM DETECTED FOR THE ", data.name, " PARAMETER")
}
}
arg.names <- c("class", "typeof", "mode", "length")
if(is.null(options)){
for(i2 in 1:length(arg.names)){
if( ! is.null(get(arg.names[i2]))){
# script to execute
tempo.script <- '
problem <- TRUE ;
if(identical(text, paste0("NO PROBLEM DETECTED FOR THE ", data.name, " PARAMETER"))){
text <- paste0("PROBLEM: THE ", data.name, " PARAMETER MUST BE ") ;
}else{
text <- paste0(text, " AND "); 
}
text <- paste0(text, toupper(arg.names[i2]), " ", get(arg.names[i2]))
'
if(typeof(data) == "double" & double.but.integer == TRUE & ((arg.names[i2] == "class" & get(arg.names[i2]) == "integer") | (arg.names[i2] == "typeof" & get(arg.names[i2]) == "integer"))){
if(! all(data%%1 == 0)){ # to check integers (use %%, meaning the remaining of a division): see the precedent line
eval(parse(text = tempo.script)) # execute tempo.script
}
}else if(eval(parse(text = paste0(arg.names[i2], "(data)"))) != get(arg.names[i2])){
eval(parse(text = tempo.script)) # execute tempo.script
}
}
}
}
if( ! is.null(prop)){
if(prop == TRUE){
if(any(data < 0 | data > 1, na.rm = TRUE)){
problem <- TRUE
if(identical(text, paste0("NO PROBLEM DETECTED FOR THE ", data.name, " PARAMETER"))){
text <- paste0("PROBLEM: ")
}else{
text <- paste0(text, " AND ")
}
text <- paste0(text, "THE ", data.name, " PARAMETER MUST BE DECIMAL VALUES BETWEEN 0 AND 1")
}
}
}
if(print == TRUE & problem == TRUE){
cat(paste0("\n\n================\n\n", text, "\n\n================\n\n"))
}
output <- list(problem = problem, text = text)
return(output)
}


################ checking row & col names, and dimensions of 2D dataset


info_2D_dataset_fun <- function(data1, data2){
# AIM:
# compare two 2D dataset of the same class. Check and report in a list if the 2 datasets have:
# same row names
# same column names
# same row number
# same column number
# potential identical rows between the 2 datasets
# potential identical columns between the 2 datasets
# REQUIRED FUNCTIONS
# none
# ARGUMENTS
# data1: matrix, data frame or table
# data2: matrix, data frame or table
# RETURN
# a list containing:
# $same.class: logical. Are class identical ?
# $class: classes of the 2 datasets (NULL otherwise)
# $same.dim: logical. Are dimension identical ?
# $dim: dimension of the 2 datasets (NULL otherwise)
# $same.row.nb: logical. Are number of rows identical ?
# $row.nb: nb of rows of the 2 datasets if identical (NULL otherwise)
# $same.col.nb: logical. Are number of columns identical ?
# $col.nb: nb of columns of the 2 datasets if identical (NULL otherwise)
# $same.row.name: logical. Are number of rows identical ?
# $row.name: name of rows of the 2 datasets if identical (NULL otherwise)
# $same.col.name: logical. Are number of columns identical ?
# $col.name: name of columns of the 2 datasets if identical (NULL otherwise)
# $any.id.row: logical. is there identical rows ?
# $same.row.pos1: position, in data1, of the rows identical in data2
# $same.row.pos2: position, in data2, of the rows identical in data1
# $any.id.col: logical. is there identical columns ?
# $same.col.pos1: position in data1 of the cols identical in data2
# $same.col.pos2: position in data2 of the cols identical in data1
# $identical.object: logical. Are objects identical (including row & column names)?
# $identical.content: logical. Are content objects identical (identical excluding row & column names)?
# EXAMPLES
# data1 = matrix(1:10, ncol = 5) ; data2 = matrix(1:10, ncol = 5)
# data1 = matrix(1:10, ncol = 5, dimnames = list(letters[1:2], LETTERS[1:5])) ; data2 = matrix(1:10, ncol = 5, dimnames = list(letters[1:2], LETTERS[1:5]))
# data1 = matrix(1:15, byrow = TRUE, ncol = 5, dimnames = list(letters[1:3], LETTERS[1:5])) ; data2 = matrix(1:10, byrow = TRUE, ncol = 5, dimnames = list(letters[1:2], LETTERS[1:5]))
# data1 = matrix(1:15, ncol = 5, dimnames = list(letters[1:3], LETTERS[1:5])) ; data2 = matrix(1:10, ncol = 5, dimnames = list(letters[1:2], LETTERS[1:5]))
# data1 = matrix(1:15, ncol = 5, dimnames = list(paste0("A", letters[1:3]), LETTERS[1:5])) ; data2 = matrix(1:10, ncol = 5, dimnames = list(letters[1:2], LETTERS[1:5]))
# data1 = matrix(1:15, ncol = 5, dimnames = list(letters[1:3], LETTERS[1:5])) ; data2 = matrix(1:12, ncol = 4, dimnames = list(letters[1:3], LETTERS[1:4]))
# data1 = matrix(1:10, ncol = 5, dimnames = list(letters[1:2], LETTERS[1:5])) ; data2 = matrix(101:110, ncol = 5, dimnames = list(letters[1:2], LETTERS[1:5]))
# data1 = data.frame(a = 1:3, b= letters[1:3], row.names = LETTERS[1:3]) ; data2 = data.frame(A = 1:3, B= letters[1:3])
# data1 = table(Exp1 = c("A", "A", "A", "B", "B", "B"), Exp2 = c("A1", "B1", "A1", "C1", "C1", "B1")) ; data2 = data.frame(A = 1:3, B= letters[1:3])
# data1 <- phasing1 ; data2 <- phasing1[, -c(4:6)]
same.class <- NULL
class <- NULL
same.dim <- NULL
dim <- NULL
same.row.nb <- NULL
row.nb <- NULL
same.col.nb <- NULL
col.nb <- NULL
same.row.name <- NULL
row.name <- NULL
same.col.name <- NULL
col.name <- NULL
any.id.row <- NULL
same.row.pos1 <- NULL
same.row.pos2 <- NULL
any.id.col <- NULL
same.col.pos1 <- NULL
same.col.pos2 <- NULL
identical.object <- NULL
identical.content <- NULL
if(identical(data1, data2) & any(class(data1) %in% c("matrix", "data.frame", "table"))){
same.class <- TRUE
class <- class(data1)
same.dim <- TRUE
dim <- dim(data1)
same.row.nb <- TRUE
row.nb <- nrow(data1)
same.col.nb <- TRUE
col.nb <- ncol(data1)
same.row.name <- TRUE
row.name <- dimnames(data1)[[1]]
same.col.name <- TRUE
col.name <- dimnames(data1)[[2]]
any.id.row <- TRUE
same.row.pos1 <- 1:row.nb
same.row.pos2 <- 1:row.nb
any.id.col <- TRUE
same.col.pos1 <- 1:col.nb
same.col.pos2 <- 1:col.nb
identical.object <- TRUE
identical.content <- TRUE
}else{
identical.object <- FALSE
if(all(class(data1) == "table") & length(dim(data1)) == 1){
tempo.cat <- paste0("\n\n================\n\nERROR: THE data1 ARGUMENT IS A 1D TABLE. USE THE info_1D_dataset_fun FUNCTION\n\n================\n\n")
stop(tempo.cat, "\n\n")
}
if(all(class(data2) == "table") & length(dim(data2)) == 1){
tempo.cat <- paste0("\n\n================\n\nERROR: THE data2 ARGUMENT IS A 1D TABLE. USE THE info_1D_dataset_fun FUNCTION\n\n================\n\n")
stop(tempo.cat, "\n\n")
}
if( ! identical(class(data1), class(data2))){
same.class <- FALSE
}else if( ! any(class(data1) %in% c("matrix", "data.frame", "table"))){
tempo.cat <- paste0("\n\n================\n\nERROR: THE data1 AND data2 ARGUMENTS MUST BE EITHER MATRIX, DATA FRAME OR TABLE\n\n================\n\n")
stop(tempo.cat, "\n\n")
}else{
same.class <- TRUE
class <- class(data1)
}
if( ! identical(dim(data1), dim(data2))){
same.dim <- FALSE
}else{
same.dim <- TRUE
dim <- dim(data1)
}
if( ! identical(nrow(data1), nrow(data2))){
same.row.nb <- FALSE
}else{
same.row.nb <- TRUE
row.nb <- nrow(data1)
}
if( ! identical(ncol(data1), ncol(data2))){
same.col.nb <- FALSE
}else{
same.col.nb <- TRUE
col.nb <- ncol(data1)
}
# row and col names
if(is.null(dimnames(data1)) & is.null(dimnames(data2))){
same.row.name <- TRUE
same.col.name <- TRUE
# row and col names remain NULL
}else if((is.null(dimnames(data1)) &  ! is.null(dimnames(data2))) | ( ! is.null(dimnames(data1)) & is.null(dimnames(data2)))){
same.row.name <- FALSE
same.col.name <- FALSE
# row and col names remain NULL
}else{
if( ! identical(dimnames(data1)[[1]], dimnames(data2)[[1]])){
same.row.name <- FALSE
# row names remain NULL
}else{
same.row.name <- TRUE
row.name <- dimnames(data1)[[1]]
}
if( ! identical(dimnames(data1)[[2]], dimnames(data2)[[2]])){
same.col.name <- FALSE
# col names remain NULL
}else{
same.col.name <- TRUE
col.name <- dimnames(data1)[[2]]
}
}
# identical row and col content
if(all(class(data1) == "table")){
as.data.frame(matrix(data1, ncol = ncol(data1)), stringsAsFactors = FALSE)
}else if(all(class(data1) == "matrix")){
data1 <- as.data.frame(data1, stringsAsFactors = FALSE)
}else if(all(class(data1) == "data.frame")){
data1 <- data.frame(lapply(data1, as.character), stringsAsFactors=FALSE)
}
if(all(class(data2) == "table")){
as.data.frame(matrix(data2, ncol = ncol(data2)), stringsAsFactors = FALSE)
}else if(all(class(data2) == "matrix")){
data2 <- as.data.frame(data2, stringsAsFactors = FALSE)
}else if(all(class(data2) == "data.frame")){
data2 <- data.frame(lapply(data2, as.character), stringsAsFactors=FALSE)
}
row.names(data1) <- paste0("A", 1:nrow(data1))
row.names(data2) <- paste0("A", 1:nrow(data2))
if(same.col.nb == TRUE){ # because if not the same col nb, the row cannot be identical
same.row.pos1 <- suppressWarnings(which(mapply(FUN = identical, c(as.data.frame(t(data1), stringsAsFactors = FALSE)), c(as.data.frame(t(data2), stringsAsFactors = FALSE)))))
same.row.pos2 <- suppressWarnings(which(mapply(FUN = identical, c(as.data.frame(t(data2), stringsAsFactors = FALSE)), c(as.data.frame(t(data1), stringsAsFactors = FALSE)))))
names(same.row.pos1) <- NULL
names(same.row.pos2) <- NULL
if(all(is.na(same.row.pos1))){
same.row.pos1 <- NULL
}else{
same.row.pos1 <- same.row.pos1[ ! is.na(same.row.pos1)]
any.id.row <- TRUE
}
if(all(is.na(same.row.pos2))){
same.row.pos2 <- NULL
}else{
same.row.pos2 <- same.row.pos2[ ! is.na(same.row.pos2)]
any.id.row <- TRUE
}
if(is.null(same.row.pos1) & is.null(same.row.pos2)){
any.id.row <- FALSE
}
}else{
any.id.row <- FALSE
# same.row.pos1 and 2 remain NULL
}
if(same.row.nb == TRUE){ # because if not the same row nb, the col cannot be identical
same.col.pos1 <- suppressWarnings(which(mapply(FUN = identical, c(data1), c(data2))))
same.col.pos2 <- suppressWarnings(which(mapply(FUN = identical, c(data2), c(data1))))
names(same.col.pos1) <- NULL
names(same.col.pos2) <- NULL
if(all(is.na(same.col.pos1))){
same.col.pos1 <- NULL
}else{
same.col.pos1 <- same.col.pos1[ ! is.na(same.col.pos1)]
any.id.col <- TRUE
}
if(all(is.na(same.col.pos2))){
same.col.pos2 <- NULL
}else{
same.col.pos2 <- same.col.pos2[ ! is.na(same.col.pos2)]
any.id.col <- TRUE
}
if(is.null(same.col.pos1) & is.null(same.col.pos2)){
any.id.col <- FALSE
}
}else{
any.id.col <- FALSE
# same.col.pos1 and 2 remain NULL
}
if(same.dim == TRUE & ! all(is.null(same.row.pos1), is.null(same.row.pos2), is.null(same.col.pos1), is.null(same.col.pos2))){
if(identical(same.row.pos1, 1:row.nb) & identical(same.row.pos2, 1:row.nb) & identical(same.col.pos1, 1:col.nb) & identical(same.col.pos2, 1:col.nb)){
identical.content <- TRUE
}
}else{
identical.content <- FALSE
}
}
output <- list(same.class = same.class, class = class, same.dim = same.dim, dim = dim, same.row.nb = same.row.nb, row.nb = row.nb, same.col.nb = same.col.nb , col.nb = col.nb, same.row.name = same.row.name, row.name = row.name, same.col.name = same.col.name, col.name = col.name, any.id.row = any.id.row, same.row.pos1 = same.row.pos1, same.row.pos2 = same.row.pos2, any.id.col = any.id.col, same.col.pos1 = same.col.pos1, same.col.pos2 = same.col.pos2, identical.object = identical.object, identical.content = identical.content)
return(output)
}


################ flipping data to have column name as a qualitative column and vice-versa


dataframe_flipping_fun <- function(data, quanti.col.name = "quanti", quali.col.name = "quali"){
# AIM:
# if the data frame is made of numeric columns, a new data frame is created, with the 1st column gathering all the numeric values, and the 2nd column being the name of the columns of the initial data frame. If the data frame is made of one nueric column and one character or factor column, a new data frame is created, with the new columns corresponding to the split numeric values (according to the character column). NA are added a the end of each column to have the same number of rows
# REQUIRED FUNCTIONS
# param_check_fun()
# ARGUMENTS
# data: data frame to convert
# quanti.col.name: optional name for the quanti column of the new data frame
# quali.col.name: optional name for the quali column of the new data frame
# RETURN
# the modified data frame
# EXAMPLES
# data = data.frame(a = 1:3, b = 4:6) ; quanti.col.name = "quanti" ; quali.col.name = "quali"
# data = data.frame(a = 1:3, b = 4:6, c = 11:13) ; quanti.col.name = "quanti" ; quali.col.name = "quali"
# data = data.frame(a = 1:3, b = letters[1:3]) ; quanti.col.name = "quanti" ; quali.col.name = "quali"
# data = data.frame(b = letters[1:3], a = 1:3) ; quanti.col.name = "quanti" ; quali.col.name = "quali"
# data = data.frame(b = c("e", "e", "h"), a = 1:3) ; quanti.col.name = "quanti" ; quali.col.name = "quali"
# argument checking
if( ! all(class(data) == "data.frame")){
tempo.cat <- paste0("data ARGUMENT MUST BE A DATA FRAME")
stop(tempo.cat, "\n\n")
}
tempo.factor <- unlist(lapply(data, class)) # convert factor columns as character
for(i in 1:length(tempo.factor)){
if(all(tempo.factor[i] == "factor")){
data[, i] <- as.character(data[, i])
}
}
tempo.factor <- unlist(lapply(data, mode)) # convert factor columns as 
if(length(data) == 2){
if( ! ((mode(data[, 1]) == "character" & mode(data[, 2]) == "numeric") | mode(data[, 2]) == "character" & mode(data[, 1]) == "numeric" | mode(data[, 2]) == "numeric" & mode(data[, 1]) == "numeric") ){
tempo.cat <- paste0("IF data ARGUMENT IS A DATA FRAME MADE OF 2 COLUMNS, EITHER A COLUMN MUST BE NUMERIC AND THE OTHER CHARACTER, OR THE TWO COLUMNS MUST BE NUMERIC")
stop(tempo.cat, "\n\n")
}
}else{
if( ! all(tempo.factor %in% "numeric")){
tempo.cat <- paste0("IF data ARGUMENT IS A DATA FRAME MADE OF ONE COLUMN, OR MORE THAN 2 COLUMNS, THESE COLUMNS MUST BE NUMERIC")
stop(tempo.cat, "\n\n")
}
}
if(( ! any(tempo.factor %in% "character")) & is.null(names(data))){
tempo.cat <- paste0("NUMERIC DATA FRAME in the data ARGUMENT MUST HAVE COLUMN NAMES")
stop(tempo.cat, "\n\n")
}
tempo <- param_check_fun(data = quanti.col.name, class = "character", length = 1)
if(tempo$problem == TRUE){
tempo.cat <- paste0("quanti.col.name ARGUMENT MUST BE A SINGLE CHARACTER VALUE")
stop(tempo.cat, "\n\n")
}
tempo <- param_check_fun(data = quali.col.name, class = "character", length = 1)
if(tempo$problem == TRUE){
tempo.cat <- paste0("quali.col.name ARGUMENT MUST BE A SINGLE CHARACTER VALUE")
stop(tempo.cat, "\n\n")
}
# end argument checking
if(all(tempo.factor %in% "numeric")){
quanti <- NULL
for(i in 1:length(data)){
quanti <-c(quanti, data[, i])
}
quali <- rep(names(data), each = nrow(data))
output.data <- data.frame(quanti, quali)
names(output.data) <- c(quanti.col.name, quali.col.name)
}else{
if(class(data[, 1]) == "character"){
data <- cbind(data[2], data[1])
}
nc.max <- max(table(data[, 2])) # effectif maximum des classes
nb.na <- nc.max - table(data[,2]) # nombre de NA à ajouter pour réaliser la data frame
tempo<-split(data[, 1], data[, 2])
for(i in 1:length(tempo)){tempo[[i]] <- append(tempo[[i]], rep(NA, nb.na[i]))} # des NA doivent être ajoutés lorsque les effectifs sont différents entre les classes. C'est uniquement pour que chaque colonne ait le même nombre de lignes
output.data<-data.frame(tempo)
}
return(output.data)
}


################ Refactorization (remove classes that are not anymore present)


refactorization_fun <- function(data, also.ordered = TRUE){
# AIM:
# refactorize the factors of the data frame (to remove the empty classes after row removing for instance)
# REQUIRED FUNCTIONS
# none
# ARGUMENTS
# data: data frame
# also.ordered: refactorize also ordered factors ? This to deal with ordered factors that have class -> "ordered" "factor"
# RETURN
# the modified data frame
# EXAMPLES
# data <- data.frame(a = LETTERS[1:6], b = paste0(letters[1.6], c(1,1,2,2,3,3)), c = 1:6) ; data <- data[-c(1:2),]
if( ! all(class(data) == "data.frame")){
tempo.cat <- paste0("data ARGUMENT MUST BE A DATA FRAME")
stop(tempo.cat, "\n\n")
}
#use check function
if( ! all(class(also.ordered) == "logical")){
tempo.cat <- paste0("also.ordered ARGUMENT MUST BE LOGICAL")
stop(tempo.cat, "\n\n")
}
# add a log.txt indicating the modified column and the removed classes
if(also.ordered == TRUE){
kind <- "any"
}else{
kind <- "all"
}
tempo.factor <- sapply(sapply(lapply(data, class), FUN = "%in%", "factor"), FUN = kind)
data[, tempo.factor] <- data.frame(lapply(data[, tempo.factor], as.character))
return(data)
}


################ Rounding number if decimal present


rounding_fun <- function(data, dec.nb = 2, after.lead.zero = TRUE){
# AIM:
# round a vector of value if decimal with the desired number of decimal digits
# BEWARE
# Work well with numbers as character strings, but not always with numerical numbers because of the floating point
# ARGUMENTS
# data: a vector of numbers (numeric or character mode
# dec.nb: a number
# after.lead.zero: logical. If FALSE, rounding is performed for all the decimal numbers, whatever the leading zeros (e.g., 0.123 -> 0.12 and 0.0012 -> 0.00). If TRUE, dec.nb are taken after the leading zeros (e.g., 0.123 -> 0.12 and 0.0012 -> 0.0012)
# REQUIRED FUNCTIONS
# param_check_fun()
# RETURN
# the modified vector
# EXAMPLES
# rounding_fun(data = c(100, 12312.1235), dec.nb = 2, after.lead.zero = FALSE)
# data = c(100, 12312.1235) ; dec.nb = 3 ; after.lead.zero = FALSE
# argument checking
if( ! (all(typeof(data) == "character") | all(typeof(data) == "double") | all(typeof(data) == "integer"))){
tempo.cat <- paste0("data ARGUMENT MUST BE A VECTOR OF NUMBERS (IN NUMERIC OR CHARACTER MODE)")
stop(tempo.cat, "\n\n")
}
tempo <- param_check_fun(data = dec.nb, class = "numeric", length = 1)
if(tempo$problem == TRUE){
tempo.cat <- paste0("dec.nb ARGUMENT MUST BE A SINGLE INTEGER VALUE")
stop(tempo.cat, "\n\n")
}
tempo <- param_check_fun(data = after.lead.zero, class = "logical", length = 1)
if(tempo$problem == TRUE){
tempo.cat <- paste0("after.lead.zero ARGUMENT MUST BE A SINGLE LOGICAL VALUE")
stop(tempo.cat, "\n\n")
}
# end parameter checking
tempo <- grepl(x = data, pattern = "\\.")
if(typeof(data) == "character"){
data2 <- data
}else{
data2 <- as.character(data)
}
if(after.lead.zero == TRUE){
for(i in 1:length(data2)){ # scan all the numbers of the vector
if(tempo[i] == TRUE){ # means decimal number
zero.pos <- unlist(gregexpr(text=data2[i], pattern = 0)) # recover all the position of the zeros in the number. -1 if no zeros (do not record the leading and trailing zeros)
dot.pos <- unlist(gregexpr(text=data2[i], pattern = "\\.")) # recover all the position of the zeros in the number
digit.pos <- unlist(gregexpr(text=data2[i], pattern = "[[:digit:]]")) # recover all the position of the zeros in the number
dec.pos <- digit.pos[digit.pos > dot.pos]
count <- 0
while((dot.pos + count + 1) %in% zero.pos & (dot.pos + count + 1) <= max(dec.pos)){
count <- count + 1
}
data2[i] <- formatC(as.numeric(data2[i]), digits = (count + dec.nb), format = "f")
# data2[i] <- round(data2[i], count + dec.nb) # round after the leading zeros after the dot, the dec.nb length
}
}
}else{
data2[tempo] <- formatC(as.numeric(data2), digits = dec.nb, format = "f")[tempo]
# data2[tempo] <- round(data2, dec.nb)[tempo]
}
if(typeof(data) == "character"){
data <- data2
}else{
data <- as.numeric(data2)
}
return(data)
}


################ Matrix flip for colorization


fun.matrix.flip <- function(data){
# AIM:
# prepare the matrix for image representation
# REQUIRED FUNCTIONS
# none
# ARGUMENTS
# data: matrix that has to be colored (matrix class)
# RETURN
# the modified matrix
if( ! all(class(data) == "matrix")){
tempo.cat <- paste0("data ARGUMENT MUST BE A MATRIX")
stop(tempo.cat, "\n\n")
}
for (i in 1:ncol(data)){data[,i] <- rev(data[,i])} # la fonction rev() inverse les éléments
data <- t(data) # la fonction t() est la transposée d'une matrice
return(data)
}


################ Matrix colorization and color scale


################ Standard Matrix


fun.matrix.hsv.color <- function(data, type = c("two.colors", "three.colors"), top.two.color = c(1,1,1), bottom.two.color = c(1,0,1), middle.three.color = c("white", "grey")){
# REVOIR CETTE FUCNTION SUR LES DYNAMIQUES
# return a list of the following compartments:
# real.dyn: real dynamics
# plot.dyn.txt: text of the plotted dynamics for plots
# real.dyn.txt: text of the real dynamics for plots
# chip.colors for fun.matrix.plot(). The dynamic displayed length(chip.colors) is different from the real.dyn of the matrix if real.dyn > 256^3
# data: matrix that has to be colored (matrix class)
# type: shade type. Either two.colors or three.colors
# top.two.color: h, s and v three values of hsv()
# bottom.two.color: h, s and v three values of hsv()
# middle.three.color: "white" or "grey"
if(class(data) != "matrix"){
tempo.cat <- paste0("data ARGUMENT MUST BE A MATRIX")
stop(tempo.cat, "\n\n")
}
if(all(type != "two.colors") & all(type != "three.colors")){
tempo.cat <- paste0("type ARGUMENT MUST BE SET AS two.colors OR three.colors")
stop(tempo.cat, "\n\n")
}
if(all(type == "three.colors") & ! any(middle.three.color == "white" | middle.three.color == "grey")){
tempo.cat <- paste0("middle.three.color ARGUMENT MUST BE SET AS white OR grey")
stop(tempo.cat, "\n\n")
}
if(length(table(data)) > 1){
min.data.diff <- min(diff(sort(unique(as.vector(data)))),  na.rm = TRUE) # minimal distance between two values in the matrix
dyn <<- floor(1 / (min.data.diff / diff(range(data, na.rm = TRUE)))) + 1 # dyn indicates the dynamic (from 1 to +Inf). This will be used to define the number of different colors to use in fun.matrix.plot(). 1 / (min.data.diff / diff(range(data, na.rm = TRUE))) is the nb of intervals
plot.dyn.txt <<- "Graphic dynamic: idem" # to warn in display when dyn to big (below)
real.dyn <<- dyn # real matrix dynamic (for fun.matrix.plot())
if(dyn > 256^3){ # cannot be more than the number of colors available
dyn <<- 256^3 # 16,777,216 FAUX: only 256 different colors with 1 axis
plot.dyn.txt <<- "Graphic dynamic: 16,777,216 (max)" # to warn in display
}
}else{
dyn <<- 0
real.dyn <<- dyn # real matrix dynamic (for fun.matrix.plot())
plot.dyn.txt <<- "Graphic dynamic: idem"
}
if(real.dyn > 1000){ # add commas
real.dyn.txt <<- formatC(real.dyn, format="fg", big.mark=',') # for fun.matrix.plot()
}else{
real.dyn.txt <<- real.dyn # for fun.matrix.plot()
}
if(dyn != 0 & all(type == "three.colors")){ # blue/white/red scale
if(dyn / 2 - trunc(dyn / 2) == 0){ # if even dyn, then 1 value is added for the blue seq and 1 for the red seq. Finally, the perfect white value from each seq is removed (no perfect white with even dyn)
chip.colors <<- hsv(
h = c(rep(0.5, (dyn / 2 + 1)), rep(0, (dyn / 2 + 1))), # +1 to add the perfect white value at the middle of the color vector. Here +1 value for the blue sequence (0.51) and +1 value for the red seq (0)
s = c(seq(1, 0, length.out = (dyn / 2 + 1)), seq(0, 1, length.out = (dyn / 2 + 1))),
if(all(middle.three.color == "white")){
v = 1
}else if(all(middle.three.color == "grey")){
v = c(seq(1, 0.6, length.out = (dyn / 2 + 1)), seq(0.6, 1, length.out = (dyn / 2 + 1)))
}
)
chip.colors <<- chip.colors[-c((dyn + 2) / 2, (dyn + 2) / 2 + 1)] # white middle values removed because even dyn
}else{ # if odd dyn, then 1 value is added to the dyn. Finally, only the perfect white value from the blue seq is removed (a single perfect white with odd dyn)
tempo.dyn.color <- dyn + 1 # +1 to have an even dyn number (because divided in 2 series of bleu and red seq)
chip.colors <<- hsv(
h = c(rep(0.5, tempo.dyn.color / 2), rep(0, tempo.dyn.color / 2)),
s = c(seq(1, 0, length.out = tempo.dyn.color / 2), seq(0, 1, length.out = tempo.dyn.color / 2)),
if(all(middle.three.color == "white")){
v = 1
}else if(all(middle.three.color == "grey")){
v = c(seq(1, 0.6, length.out = tempo.dyn.color / 2), seq(0.6, 1, length.out = tempo.dyn.color / 2))
}
)
chip.colors <<- chip.colors[-(tempo.dyn.color / 2)] # white middle values removed because even dyn
}
# chip.colors ; plot(1:length(chip.colors), col=chip.colors, pch=16, cex=2)
}
if(dyn != 0 & all(type == "two.colors")){ # yellow/red.brown scale
chip.colors <<- hsv(h = seq(bottom.two.color[1], top.two.color[1], length.out = dyn), s = seq(bottom.two.color[2], top.two.color[2], length.out = dyn), v = seq(bottom.two.color[3], top.two.color[3], length.out = dyn))
}
if(dyn == 0 ){
if(all(type == "three.colors")){
if(all(middle.three.color == "white")){
chip.colors <<- "#FFFFFF" # white
}else if(all(middle.three.color == "grey")){
chip.colors <<- "#999999" # grey
}
}else{
chip.colors <<- hsv(bottom.two.color[1], bottom.two.color[2], bottom.two.color[3]) # yellow from two.colors scale
}
}
real.dyn <<- real.dyn
output <- list(real.dyn = real.dyn, plot.dyn.txt = plot.dyn.txt, real.dyn.txt = real.dyn.txt, chip.colors = chip.colors)
return(output)
}


################ Matrix plot Gradient color (raster)


fun.matrix.rgb.colorization <- function(mat1, mat2 = NULL, mat.number = 1, z.min = NULL, z.max = NULL, fun.max.colors = 255, type = c("invert", "std")){
# AIM:
# provide a single matrix colorization or an overlay of 2 matrices, with the black as min value (red & green + yellow for the overlay) value or with the white as min value (magenta & cyan + blue for the overlay)
# REQUIRED FUNCTIONS
# none
# ARGUMENTS:
# mat1: matrix 1 of non negative values that has to be colored (matrix class)
# mat2: matrix 2 (of non negative values) if overlay, must have same dimension, row and column names than mat1
# mat.number: define if it is mat1 or mat2 alone which is submitted. Only for defining the red or green or grey scale in single matrice display. Can only be value 0 (grey), 1 (red) or 2 (green). Not used if mat2 != NULL
# z.min: set a minimal value to the dynamic scale of mat1 and mat2 (in unit of mat1 & mat2). Beware: this can rescale the dynamic & gradient colors. Only works with positive or null values. See below
# z.max: add a maximal value to the dynamic scale of mat1 and mat2 (in unit of mat1 & mat2). Beware: this can rescale the dynamic & gradient colors. The dynamic scale is not [min(min(mat), z.min) ; max(max(mat), z.max)] but systematically [z.min ; z.max]. Thus, if any(mat1) < z.min, these matrix values are increased to reach z.min (the values of mat1 are modified). Idem for mat2. If z.min is below min(mat1), mat1 is not modified but min(mat1) is not the min of the dynamic scale. Idem for mat2. Idem for z.max. This allow to set the same dynamic scale for all the batch of pairwise comparison.
# fun.max.colors: only 255 (default) or 1 allowed. Equivalent to the maxColorValue argument of rgb(), but 255 by default instead of 1
# type: shade type. Either black null reference ("std") or white null reference ("invert")
# RETURN a list of the following compartments:
# mat1: in case of modification by z.min or z.max
# mat1.name: name of mat1
# real.dyn1: real dynamics of matrix 1
# print.dyn1.txt: text of the plotted dynamics of matrix 1 for print
# real.dyn1.txt: real dynamics of matrix 1 for print (with correct format)
# mat1.labels.scale: labels for the scale related to mat1
# rgb.mat1: values between 0 and 255 or 0 and 1 of mat1 (rgb range)
# log.txt: different messages from the function to print
# mat2: in case of modification by z.min or z.max
# mat2.name: name of mat2
# real.dyn2: real dynamics of matrix 2
# print.dyn2.txt: text of the plotted dynamics of matrix 2 for print
# real.dyn2.txt: real dynamics of matrix 2 for print (with correct format)
# mat2.labels.scale: labels for the scale related to mat2
# rgb.mat2: values between 0 and 255 or 0 and 1 of mat2 (rgb range)
# mat.color.scale: the colors for the scale of the plot (either a 1D vector of 256 values or a 2D matrix of 256^2 values)
# colored.mat: colors of the matrix1, or overlay, for fun.matrix.plot(). The dynamic displayed (length(mat.colors)) is over the real.dyn of the matrix if real.dyn <= 256, and is lower than the real.dyn of the matrix if real.dyn > 256
# global.dyn: either "NonNULL" or NULL. In the latter case, it means that the dynamic of mat1 or mat2 is null -> no possible plot
# EXAMPLES:
# output.fun.matrix.rgb.colorization <- fun.matrix.rgb.colorization(mat1 = mat1, mat2 = NULL, type = "std", mat.number = 2, z.min = NULL, z.max = NULL) ; output.fun.matrix.rgb.colorization ; output.fun.matrix.rgb.colorization[-(length(output.fun.matrix.rgb.colorization) - 1)]
# mat1 = matrix1 ; mat2 = matrix2 ; type = type.color.matrix ; z.min = z.min.mat.plot ; z.max = z.max.mat.plot ; mat.number = 1 ; fun.max.colors = 255 ; type = "std"
# mat1 = matrix(c(0,1,1,2,1,5,9,11), ncol = 2) ; dimnames(mat1) <- list(LETTERS[1:4], letters[1:2]) ; mat2 = matrix(c(6,6,6,8,10,12, 4, 2), ncol = 2) ; dimnames(mat2) <- list(LETTERS[1:4], letters[1:2]) ; mat.number = 1 ; z.min = NULL ; z.max = NULL ; fun.max.colors = 255 ; type = "std"

if( ! all(class(mat1) == "matrix")){
tempo.cat <- paste0("mat1 ARGUMENT MUST BE A MATRIX")
stop(tempo.cat, "\n\n")
}
if( ! (all(is.null(mat2)) | all(class(mat2) == "matrix"))){
tempo.cat <- paste0("mat2 ARGUMENT MUST BE A MATRIX OR a NULL VECTOR")
stop(tempo.cat, "\n\n")
}
if(any(mat1 < 0, na.rm = TRUE)){
tempo.cat <- paste0("mat1 ARGUMENT MUST BE A MATRIX OF NON NEGATIVE VALUES")
stop(tempo.cat, "\n\n")
}
if( ! all(is.null(mat2)) & any(mat2 < 0, na.rm = TRUE)){
tempo.cat <- paste0("mat2 ARGUMENT MUST BE A MATRIX OF NON NEGATIVE VALUES")
stop(tempo.cat, "\n\n")
}
if( ! all(is.null(mat2))){
if( ! identical(dim(mat1), dim(mat2))){
tempo.cat <- paste0("DIMENSION OF mat2 ARGUMENT (", paste0(dim(mat2), collapse = " "), ") MUST BE A MATRIX OF SAME DIMENSION AS mat1 ARGUMENT (", paste0(dim(mat1), collapse = " "), ")")
stop(tempo.cat, "\n\n")
}
}
if( ! all(is.null(mat2))){
if( ! identical(rownames(mat1), rownames(mat2))){
if(length(rownames(mat1)) <= 10 & length(rownames(mat2)) <= 10){
tempo.cat <- paste0("BEWARE: IN FUNCTION fun.matrix.rgb.colorization, ROW NAMES OF mat2 ARGUMENT (", paste0(rownames(mat2), collapse = " "), ") ARE NOT IDENTICAL TO ROW NAMES OF mat1 ARGUMENT (", paste0(rownames(mat1), collapse = " "), ")")
}else{
tempo.cat <- paste0("BEWARE: IN FUNCTION fun.matrix.rgb.colorization, ROW NAMES OF mat2 ARGUMENT ARE NOT IDENTICAL TO ROW NAMES OF mat1 ARGUMENT")
}
cat(tempo.cat, "\n\n")
}
}
if( ! all(is.null(mat2))){
if( ! identical(colnames(mat1), colnames(mat2))){
if(length(colnames(mat1)) <= 10 & length(colnames(mat2)) <= 10){
tempo.cat <- paste0("BEWARE: IN FUNCTION fun.matrix.rgb.colorization, COL NAMES OF mat2 ARGUMENT (", paste0(colnames(mat2), collapse = " "), ") ARE NOT IDENTICAL TO COL NAMES OF mat1 ARGUMENT (", paste0(colnames(mat1), collapse = " "), ")")
}else{
tempo.cat <- paste0("BEWARE: IN FUNCTION fun.matrix.rgb.colorization, COLUMN NAMES OF mat2 ARGUMENT ARE NOT IDENTICAL TO COLUMN NAMES OF mat1 ARGUMENT")
}
cat(tempo.cat, "\n\n")
}
}
if( ! ((all(mat.number == 0) | all(mat.number == 1) | all(mat.number == 2)) & length(mat.number) == 1)){
tempo.cat <- paste0("mat.number ARGUMENT MUST BE 0, 1 OR 2")
stop(tempo.cat, "\n\n")
}
if( ! (all(is.null(z.min)) | (all(class(z.min) == "numeric") & length(z.min) == 1))){
tempo.cat <- paste0("z.min ARGUMENT MUST BE NULL OR A SINGLE NUMERIC VALUE")
stop(tempo.cat, "\n\n")
}
if( ! (all(is.null(z.max)) | (all(class(z.max) == "numeric") & length(z.max) == 1))){
tempo.cat <- paste0("z.max ARGUMENT MUST BE NULL OR A SINGLE NUMERIC VALUE")
stop(tempo.cat, "\n\n")
}
if( ! (length(fun.max.colors) == 1 & (all(fun.max.colors == 1) | all(fun.max.colors == 255)))){
tempo.cat <- paste0("fun.max.colors ARGUMENT MUST BE 255 OR 1")
stop(tempo.cat, "\n\n")
}
mat1.name <- deparse(substitute(mat1))
if( ! is.null(mat2)){
mat2.name <- deparse(substitute(mat2))
}
type <- match.arg(type)
# change the scale of the plotted matrix
print.dyn1.txt <- NULL
mat1.min <- min(mat1, na.rm = TRUE) # vector containing the range of mat1
if( ! is.null(z.min)){
mat1.z.min.ini <- min(mat1, na.rm = TRUE)
if(any(mat1 < z.min, na.rm = TRUE)){
mat1[mat1 < z.min] <- z.min # if values of mat1 < z.min then these values are increased, meaning that now the lower scale limit is z.min
mat1.min <- min(mat1, na.rm = TRUE) # vector containing the range of mat1
print.dyn1.txt <- paste0(print.dyn1.txt, "THE MIN VALUES OF MATRIX 1 HAVE BEEN INCREASED TO ", formatC(z.min), " (FOR AN INITIAL MIN VALUE OF ", formatC(mat1.z.min.ini), ")\nTHUS, IN THE SCALE, ", formatC(z.min), " MEANS ", formatC(z.min), " OR LESS\n")
}else{
mat1.min <- min(c(mat1, z.min), na.rm = TRUE)
}
}
mat1.max <- max(mat1, na.rm = TRUE) # vector containing the range of mat1
if( ! is.null(z.max)){
mat1.z.max.ini <- max(mat1, na.rm = TRUE)
if(any(mat1 > z.max, na.rm = TRUE)){
mat1[mat1 > z.max] <- z.max # if values of mat1 > z.max then these values are increased, meaning that now the lower scale limit is z.max
mat1.max <- max(mat1, na.rm = TRUE) # vector containing the range of mat1
print.dyn1.txt <- paste0(print.dyn1.txt, "THE MAX VALUES OF MATRIX 1 HAVE BEEN DECREASED TO ", formatC(z.max), " (FOR AN INITIAL MAX VALUE OF ", formatC(mat1.z.max.ini), ")\nTHUS, IN THE SCALE, ", formatC(z.max), " MEANS ", formatC(z.max), " OR MORE\n")
}else{
mat1.max <-max(c(mat1, z.max), na.rm = TRUE)
}
}
mat1.range <- range(mat1.min, mat1.max)
# to modify all the values of mat1 to fit the new mat1.range
# For the initial values 2 4 6, and the new range 8 to 20, the formula is
# x.min = 2 ; x.max = 6 ; xi = c(2, 4, 6) ; y.min = 8 ; y.max = 16
# y.min + (xi - x.min) / (x.max - x.min) * (y.max - y.min)
# mat1.for.color <- min(mat1.range, na.rm = TRUE) + (mat1 - min(mat1, na.rm = TRUE)) / (max(mat1, na.rm = TRUE) - min(mat1, na.rm = TRUE)) * (max(mat1.range, na.rm = TRUE) - min(mat1.range, na.rm = TRUE))
if( ! all(is.null(mat2))){
mat2.min <- min(mat2, na.rm = TRUE) # vector containing the range of mat2
print.dyn2.txt <- NULL
if( ! is.null(z.min)){
mat2.z.min.ini <- min(mat2, na.rm = TRUE)
if(any(mat2 < z.min, na.rm = TRUE)){
mat2[mat2 < z.min] <- z.min # if values of mat2 < z.min then these values are increased, meaning that now the lower scale limit is z.min
mat2.min <- min(mat2, na.rm = TRUE)
print.dyn2.txt <- paste0(print.dyn2.txt, "THE MIN VALUES OF MATRIX 2 HAVE BEEN INCREASED TO ", formatC(z.min), " (FOR AN INITIAL MIN VALUE OF ", formatC(mat2.z.min.ini), ")\nTHUS, IN THE SCALE, ", formatC(z.min), " MEANS ", formatC(z.min), " OR LESS\n")
}else{
mat2.min <-min(c(mat2, z.min), na.rm = TRUE)
}
}
mat2.max <- max(mat2, na.rm = TRUE) # vector containing the range of mat1
if( ! is.null(z.max)){
mat2.z.max.ini <- max(mat2, na.rm = TRUE)
if(any(mat2 > z.max, na.rm = TRUE)){
mat2[mat2 > z.max] <- z.max # if values of mat2 > z.max then these values are increased, meaning that now the lower scale limit is z.max
mat2.max <-max(mat2, na.rm = TRUE)
print.dyn2.txt <- paste0(print.dyn2.txt, "THE MAX VALUES OF MATRIX 2 HAVE BEEN DECREASED TO ", formatC(z.max), " (FOR AN INITIAL MAX VALUE OF ", formatC(mat2.z.max.ini), ")\nTHUS, IN THE SCALE, ", formatC(z.max), " MEANS ", formatC(z.max), " OR MORE\n")
}else{
mat2.max <-max(c(mat2, z.max), na.rm = TRUE)
}
}
mat2.range <- range(mat2.min, mat2.max)
# mat2.for .color <- min(mat2.range, na.rm = TRUE) + (mat2 - min(mat2, na.rm = TRUE)) / (max(mat2, na.rm = TRUE) - min(mat2, na.rm = TRUE)) * (max(mat2.range, na.rm = TRUE) - min(mat2.range, na.rm = TRUE)) # see mat1 above
}
# end of change the scale of the plotted matrix
global.dyn <- "NonNULL" # used to define if one of the dyn1 or dyn2 is null
if(length(table(mat1)) > 1){
min.mat1.diff <- min(diff(sort(unique(as.vector(mat1)))),  na.rm = TRUE) # minimal distance between two values in the matrix
dyn1 <- floor(1 / (min.mat1.diff / diff(mat1.range))) + 1 # dyn1 indicates the dynamic (ie the number of values in the range of mat1 due to a minimal interval. The dynamic is between 1 and +Inf. This will be used to define the number of different colors to use in fun.matrix.plot(). floor(1 / (min.mat1.diff / diff(range(mat1, na.rm = TRUE)))) is the nb of intervals in the dynamic and min.mat1.diff is the min interval
real.dyn1 <- dyn1 # real matrix dynamic (for fun.matrix.plot())
if(real.dyn1 > 1000){ # add commas
real.dyn1.txt <- formatC(real.dyn1, format="fg", big.mark=',') # for fun.matrix.plot()
}else{
real.dyn1.txt <- real.dyn1 # for fun.matrix.plot()
}
print.dyn1.txt <- paste0(print.dyn1.txt, "REAL DYNAMIC OF MATRIX 1: ", real.dyn1.txt) # to warn in display when dyn to big (below)
if(dyn1 > 256){ # cannot be more than the number of colors available on one axis of the RGB cube
dyn1 <- 256
print.dyn1.txt <- paste0(print.dyn1.txt, "\nGRAPHIC DYNAMIC OF MATRIX 1 IS 256 (MAX 1D GRAPHICAL DYNAMIC REACHED)") # to warn in display
}else{
print.dyn1.txt <- paste0(print.dyn1.txt, "\nGRAPHIC DYNAMIC OF MATRIX 1 IS 256 (MAX 1D GRAPHICAL DYNAMIC NOT REACHED)") # to warn in display
}
}else{
dyn1 <- 0
real.dyn1 <- dyn1 # real matrix dynamic (for fun.matrix.plot())
real.dyn1.txt <- real.dyn1 # for fun.matrix.plot()
global.dyn <- NULL
print.dyn1.txt <- paste0(print.dyn1.txt, "REAL DYNAMIC OF MATRIX 1: ", real.dyn1, "\nNO POSSIBLE MATRIX COLORIZATION")
}
if( ! is.null(mat2) & length(table(mat2)) > 1){
min.mat2.diff <- min(diff(sort(unique(as.vector(mat2)))),  na.rm = TRUE) # minimal distance between two values in the matrix
dyn2 <- floor(1 / (min.mat2.diff / diff(mat2.range))) + 1 # as dyn1
real.dyn2 <- dyn2 # real matrix dynamic (for fun.matrix.plot())
if(real.dyn2 > 1000){ # add commas
real.dyn2.txt <- formatC(real.dyn2, format="fg", big.mark=',') # for fun.matrix.plot()
}else{
real.dyn2.txt <- real.dyn2 # for fun.matrix.plot()
}
print.dyn2.txt <- paste0(print.dyn2.txt, "REAL DYNAMIC OF MATRIX 2: ", real.dyn2.txt) # to warn in display when dyn to big (below)
real.dyn2 <- dyn2 # real matrix dynamic (for fun.matrix.plot())
if(dyn2 > 256){ # cannot be more than the number of colors available on one axis of the RGB cube
dyn2 <- 256
print.dyn2.txt <- paste0(print.dyn2.txt, "\nGRAPHIC DYNAMIC OF MATRIX 2 IS 256 (MAX 1D GRAPHICAL DYNAMIC REACHED)") # to warn in display
}else{
print.dyn2.txt <- paste0(print.dyn2.txt, "\nGRAPHIC DYNAMIC OF MATRIX 2 IS 256 (MAX 1D GRAPHICAL DYNAMIC NOT REACHED)") # to warn in display
}
}else if( ! is.null(mat2)){
dyn2 <- 0
real.dyn2 <- dyn2 # real matrix dynamic (for fun.matrix.plot())
real.dyn2.txt <- real.dyn2 # for fun.matrix.plot()
global.dyn <- NULL
print.dyn2.txt <- paste0(print.dyn2.txt, "REAL DYNAMIC OF MATRIX 2: ", real.dyn2, "\nNO POSSIBLE MATRIX COLORIZATION")
}else{
dyn2 <- -Inf # just to create the dyn2 object even if mat2  == NULL
}
if(dyn1 != 0){
mat1.labels.scale <- seq(min(mat1.range), max(mat1.range), length.out = 256)
mat1.labels.scale <- rounding_fun(mat1.labels.scale, 1)
base.color.ini <- 0
base.color <- base.color.ini
tempo.dim.mat1 <- dim(mat1)
x <- c(mat1.range, mat1) / (max(mat1.range) - min(mat1.range)) # initial matrix that will give the rgb matrix numbers. The c(mat1.range, mat1) creates a vector from the matrix mat1 with the 2 first numbers which are the range of mat1 (it is to deal with z.min and z.max)
if(min(x, na.rm = TRUE) != 0){
x <- (x / min(x, na.rm = TRUE)) - 1 # min x is 0
}
x <- x / max(x, na.rm = TRUE) * (fun.max.colors - base.color.ini) # color of the first matrix from 0 to 255. Used to color mat1 -> colored.mat Proportionality of mat1 is conserved. for instance relative distance between 9 and 6 is (9-6)/(11-6) = 0.6 for mat1 = matrix(c(6,6,6,6,6,6,9,11), ncol = 2) and is (153-0)/(255-0)  = 0.6 for the converted matrix x
x <- x[-(1:2)] # two first number removed
dim(x) <- tempo.dim.mat1 # recreates the matrix
# x <- min(mat1.range) + (mat1 - min(mat1.range)) / (max(mat1.range) - min(mat1.range)) * (fun.max.colors - base.color.ini) # see mat1.for.color above
mat1.scale <- seq(base.color.ini, fun.max.colors, length.out = 256) # color scale displayed
if(type == "invert"){
x <- (1-x/fun.max.colors)*fun.max.colors
base.color <- (1-base.color.ini/fun.max.colors)*fun.max.colors
}
if(is.null(mat2) & mat.number == 0){
mat.color.scale <- rgb(red = mat1.scale, green = mat1.scale, blue = mat1.scale, maxColorValue = fun.max.colors) # different colors in mat1. Equivalent to the color scale (and is used to plot the scale)
if(type == "std"){
mat.color.scale <- rev(mat.color.scale)
}
mat.color.scale <- matrix(mat.color.scale, ncol = 1)
colored.mat <- rgb(red = x, green = x, blue = x, maxColorValue = fun.max.colors) # mat1 with values replaced by hexa colors
colored.mat <- as.matrix(colored.mat)
dim(colored.mat) <- dim(mat1)
rownames(colored.mat) <- rownames(mat1)
colnames(colored.mat) <- colnames(mat1)
}else if(is.null(mat2) & mat.number == 1){
mat.color.scale <- rgb(red = mat1.scale, green = base.color, blue = base.color, maxColorValue = fun.max.colors) # different colors in mat1. Equivalent to the color scale (and is used to plot the scale)
if(type == "std"){
mat.color.scale <- rev(mat.color.scale)
}
mat.color.scale <- matrix(mat.color.scale, ncol = 1)
colored.mat <- rgb(red = x, green = base.color, blue = base.color, maxColorValue = fun.max.colors) # mat1 with values replaced by hexa colors
colored.mat <- as.matrix(colored.mat)
dim(colored.mat) <- dim(mat1)
rownames(colored.mat) <- rownames(mat1)
colnames(colored.mat) <- colnames(mat1)
}else if(is.null(mat2) & mat.number == 2){
mat.color.scale <- rgb(red = base.color, green = mat1.scale, blue = base.color, maxColorValue = fun.max.colors) # different colors in mat1. Equivalent to the color scale (and is used to plot the scale)
if(type == "std"){
mat.color.scale <- rev(mat.color.scale)
}
mat.color.scale <- matrix(mat.color.scale, ncol = 1)
colored.mat <- rgb(red = base.color, green = x, blue = base.color, maxColorValue = fun.max.colors) # mat1 with values replaced by hexa colors
colored.mat <- as.matrix(colored.mat)
dim(colored.mat) <- dim(mat1)
rownames(colored.mat) <- rownames(mat1)
colnames(colored.mat) <- colnames(mat1)
}else if( ! is.null(mat2)){
if(dyn2 != 0){
mat2.labels.scale <- seq(min(mat2.range), max(mat2.range), length.out = 256)
mat2.labels.scale <- rounding_fun(mat2.labels.scale, 1)
tempo.dim.mat2 <- dim(mat2)
y <- c(mat2.range, mat2) / (max(mat2.range) - min(mat2.range)) # initial matrix that will give the rgb matrix numbers. The c(mat2.range, mat2) creates a vector from the matrix mat2 with the 2 first numbers which are the range of mat2 (it is to deal with z.min and z.max)
if(min(y, na.rm = TRUE) != 0){
y <- (y / min(y, na.rm = TRUE)) - 1 # min y is 0
}
y <- y / max(y, na.rm = TRUE) * (fun.max.colors - base.color.ini) # color of the first matrix from 0 to 255. Used to color mat2 -> colored.mat Proportionality of mat2 is conserved. for instance relative distance between 9 and 6 is (9-6)/(11-6) = 0.6 for mat2 = matrix(c(6,6,6,6,6,6,9,11), ncol = 2) and is (153-0)/(255-0)  = 0.6 for the converted matrix y
y <- y[-(1:2)] # two first number removed
dim(y) <- tempo.dim.mat2 # recreates the matrix
mat2.scale <- seq(base.color.ini, fun.max.colors, length.out = 256) # color scale displayed
if(type == "invert"){
y <- (1-y/fun.max.colors)*fun.max.colors
mat1.scale <- rev(mat1.scale)
mat2.scale <- rev(mat2.scale)
}
mat1.color.scale <- rgb(red = mat1.scale, green = base.color, blue = base.color, maxColorValue = fun.max.colors) # red different colors in mat1 in the same order as x and mat1.scale
mat2.color.scale <- rgb(red = base.color, green = mat2.scale, blue = base.color, maxColorValue = fun.max.colors) # green different colors in mat2 in the same order as y and mat2.scale
x.mat.color.scale.2D <- matrix(mat1.scale, nrow = length(mat2.scale), ncol = length(mat1.scale), byrow = TRUE)
y.mat.color.scale.2D <- matrix(rev(mat2.scale), nrow = length(mat2.scale), ncol = length(mat1.scale), byrow = FALSE)
mat.color.scale <- rgb(red = x.mat.color.scale.2D, green = y.mat.color.scale.2D, blue = base.color, maxColorValue = fun.max.colors)
mat.color.scale <- as.matrix(mat.color.scale)
dim(mat.color.scale) <- dim(x.mat.color.scale.2D)
colored.mat <- rgb(red = x, green = y, blue = base.color, maxColorValue = fun.max.colors)
colored.mat <- as.matrix(colored.mat)
dim(colored.mat) <- dim(mat1)
rownames(colored.mat) <- rownames(mat1)
colnames(colored.mat) <- colnames(mat1)
}else{
y <- 0
mat2.labels.scale <- NULL
}
}
}else{
x <- 0
mat1.labels.scale <- NULL
}
if(dyn1 == 0 | dyn2 == 0){
mat.color.scale <- NULL
colored.mat <- matrix("#FFFFFF", nrow = nrow(mat1), ncol = ncol(mat1))
y <- 0
mat2.labels.scale <- NULL
}
if(is.null(mat2)){
log.txt <- print.dyn1.txt
output <- list(mat1 = mat1, mat1.name = mat1.name, real.dyn1 = real.dyn1, print.dyn1.txt = print.dyn1.txt, real.dyn1.txt = real.dyn1.txt, mat1.labels.scale = mat1.labels.scale, rgb.mat1 = x, log.txt = log.txt, mat.color.scale = mat.color.scale, colored.mat = colored.mat, global.dyn = global.dyn)
}else{
log.txt <- paste0(print.dyn1.txt, "\n", print.dyn2.txt)
output <- list(mat1 = mat1, mat1.name = mat1.name, real.dyn1 = real.dyn1, print.dyn1.txt = print.dyn1.txt, real.dyn1.txt = real.dyn1.txt, mat1.labels.scale = mat1.labels.scale, rgb.mat1 = x, mat2 = mat2, mat2.name = mat2.name, real.dyn2 = real.dyn2, print.dyn2.txt = print.dyn2.txt, real.dyn2.txt = real.dyn2.txt, mat2.labels.scale = mat2.labels.scale, rgb.mat2 = y, log.txt = log.txt, mat.color.scale = mat.color.scale, colored.mat = colored.mat, global.dyn = global.dyn)
}
return(output)
}


################ Conversion of a numeric matrix into hexadecimal color matrix


fun.hexa.hsv.color.matrix <- function(mat1, mat.hsv.h = TRUE, notch = 1, s = 1, v = 1, forced.color = NULL){
# AIM:
# convert a matrix made of number into a hexadecimal matrix for rgb colorization
# REQUIRED FUNCTIONS
# param_check_fun()
# ARGUMENTS:
# mat1: matrix 1 of non negative numerical values that has to be colored (matrix class)
# mat.hsv.h: logical. Is mat1 the h of hsv colors ? (if TRUE, mat1 must be between zero and 1)
# notch: single value between 0 and 1 to shift the successive colors on the hsv circle by + notch
# s: s argument of hsv(). Must be between 0 and 1
# v: v argument of hsv(). Must be between 0 and 1
# forced.color: Must be NULL or hexadecimal color code. The first minimal values of mat1 will be these colors. All the color of mat1 can be forced using this argument
# RETURN a list of the following compartments:
# mat1.name: name of mat1
# colored.mat: colors of mat1 in hexa
# problem: logical. Is any colors of forced.color overlap the colors designed by the function. NULL if forced.color = NULL
# text.problem: text when overlapping colors. NULL if forced.color = NULL or problem == FALSE
# EXAMPLES:
# mat1 = matrix(c(1,1,1,2,1,5,9,NA), ncol = 2) ; dimnames(mat1) <- list(LETTERS[1:4], letters[1:2]) ; fun.hexa.hsv.color.matrix(mat1, mat.hsv.h = FALSE, notch = 1, s = 1, v = 1, forced.color = NULL)
# mat1 = matrix(c(1,1,1,2,1,5,9,NA), ncol = 2) ; dimnames(mat1) <- list(LETTERS[1:4], letters[1:2]); mat.hsv.h = FALSE ; notch = 1 ; s = 1 ; v = 1 ; forced.color = c(hsv(1,1,1), hsv(0,0,0))
if( ! all(class(mat1) == "matrix")){
tempo.cat <- paste0("mat1 ARGUMENT MUST BE A MATRIX")
stop(tempo.cat, "\n\n")
}
if( ! mode(mat1) == "numeric"){
tempo.cat <- paste0("mat1 ARGUMENT MUST BE A NUMERIC MATRIX")
stop(tempo.cat, "\n\n")
}
if(any(mat1 < 0, na.rm = TRUE)){
tempo.cat <- paste0("mat1 ARGUMENT MUST BE A MATRIX OF NON NEGATIVE VALUES")
stop(tempo.cat, "\n\n")
}
tempo <- param_check_fun(data = notch, prop = TRUE, length = 1)
if(tempo$problem == TRUE){
tempo.cat <- paste0("notch ARGUMENT MUST BE A SINGLE DECIMAL VALUE BETWEEN O AND 1")
stop(tempo.cat, "\n\n")
}
tempo <- param_check_fun(data = s, prop = TRUE, length = 1)
if(tempo$problem == TRUE){
tempo.cat <- paste0("s ARGUMENT MUST BE A SINGLE DECIMAL VALUE BETWEEN O AND 1")
stop(tempo.cat, "\n\n")
}
tempo <- param_check_fun(data = v, prop = TRUE, length = 1)
if(tempo$problem == TRUE){
tempo.cat <- paste0("v ARGUMENT MUST BE A SINGLE DECIMAL VALUE BETWEEN O AND 1")
stop(tempo.cat, "\n\n")
}
if( ! is.null(forced.color)){
tempo <- param_check_fun(data = forced.color, class = "character")
if(tempo$problem == TRUE | ! all(grepl(pattern = "^#", forced.color))){ # check that all strings of forced.color start by #
tempo.cat <- paste0("forced.color ARGUMENT MUST BE A HEXADECIMAL COLOR VECTOR")
stop(tempo.cat, "\n\n")
}
}
problem <- NULL
text.problem <- NULL
mat1.name <- deparse(substitute(mat1))
# change the scale of the plotted matrix
if(mat.hsv.h == TRUE){
if(any(min(mat1, na.rm = TRUE) < 0 | max(mat1, na.rm = TRUE) > 1, na.rm = TRUE)){
tempo.cat <- paste0("\n\n================\n\nERROR: mat1 MUST BE MADE OF VALUES BETWEEN 0 AND 1 BECAUSE mat.hsv.h ARGUMENT SET TO TRUE\n\n================\n\n")
stop(tempo.cat, "\n\n")
}
}else{
if(any(mat1 - floor(mat1) > 0, na.rm = TRUE) | any(mat1 == 0, na.rm = TRUE)){
tempo.cat <- paste0("\n\n================\n\nERROR: mat1 MUST BE MADE OF INTEGER VALUES WITHOUT 0 BECAUSE mat.hsv.h ARGUMENT SET TO FALSE\n\n================\n\n")
stop(tempo.cat, "\n\n")
}else{
mat1 <- mat1 / max(mat1, na.rm = TRUE)
}
}
if(notch != 1){
different.color <- unique(as.vector(mat1))
different.color <- different.color[ ! is.na(different.color)]
tempo.different.color <- different.color + c(0, cumsum(rep(notch, length(different.color) - 1)))
tempo.different.color <- tempo.different.color - floor(tempo.different.color)
if(any(duplicated(tempo.different.color) == TRUE)){
tempo.cat <- paste0("\n\n================\n\nERROR: DUPLICATED VALUES AFTER USING notch (", paste(tempo.different.color[duplicated(tempo.different.color)], collapse = " "), "). TRY ANOTHER notch VALUE\n\n================\n\n")
stop(tempo.cat, "\n\n")
}else if(length(different.color) != length(tempo.different.color)){
tempo.cat <- paste0("\n\n================\n\nERROR: LENGTH OF different.color (", paste(different.color, collapse = " "), ") DIFFERENT FROM LENGTH OF tempo.different.color (", paste(tempo.different.color, collapse = " "), ")\n\n================\n\n")
stop(tempo.cat, "\n\n")
}else{
for(i in 1:length(different.color)){
mat1[mat1 == different.color[i]] <- tempo.different.color[i]
}
}
}
if( ! is.null(forced.color)){
hexa.values.to.change <- hsv(unique(sort(mat1))[1:length(forced.color)], s, v)
}
mat1[ ! is.na(mat1)] <- hsv(mat1[ ! is.na(mat1)], s, v)
if( ! is.null(forced.color)){
if(any(forced.color %in% mat1, na.rm = TRUE)){
problem <- TRUE
text.problem <- paste0("THE FOLLOWING COLORS WHERE INTRODUCED USING forced.color BUT WHERE ALREADY PRESENT IN THE COLORED MATRIX :", paste(forced.color[forced.color %in% mat1], collapse = " "))
}else{
problem <- FALSE
}
for(i in 1:length(hexa.values.to.change)){
if( ! any(mat1 == hexa.values.to.change[i], na.rm = TRUE)){
tempo.cat <- paste0("\n\n================\n\nERROR: THE ", hexa.values.to.change[i], " VALUE FROM hexa.values.to.change IS NOT REPRESENTED IN mat1 : ", paste(unique(as.vector(mat1)), collapse = " "), "\n\n================\n\n")
stop(tempo.cat, "\n\n")
}else{
mat1[which(mat1 == hexa.values.to.change[i])] <- forced.color[i]
}
}
}
output <- list(mat1.name = mat1.name, colored.mat = mat1, problem = problem, text.problem = text.problem)
return(output)
}


################ Graphic window size & margins


################ standard plots


fun.window.size <- function(nb.categ = NULL, down.space = 7, left.space = 7, up.space = 5, right.space = 2, inches.per.nb.f = 1){
## output objects: down.space, left.space, up.space, right.space, nb.mut.graph, range.max, range.min, inches.sides, width.wind.var
# nb.categ: number of different classes plotted (number of levels in Name column of the dataframe to analyze. Has to be executed before fun.graph.param() to give the default values of fun.graph.param()
# up.space: upper vertical margin between plot region and grapical window defined by par(mar)
# down.space: lower vertical margin
# left.space: left horizontal margin
# right.space: right horizontal margin
# inches.per.nb.f: number of inches per unit of nb.mut.graph. 2 means 2 inches for each boxplot for instance
down.space <<- down.space
left.space <<- left.space
up.space <<- up.space
right.space <<- right.space
nb.mut.graph <<- nb.categ
range.max <<- nb.mut.graph + 0.5 # the max range in the plot
range.min <<- 0.5
inches.sides <<- (left.space + right.space) * 0.2 # this is the size in inches occupied by the vertical margins of the graph. Indeed, par()$mai/par()$mar is generally equal to 0.2 inches per line, with par()$mai the margins in inches and par()$mar the margins in lines
width.wind.var <<- inches.sides + inches.per.nb.f * (range.max - range.min)
}


################ Matrix plots keeping same matrix sizes


fun.mat.window.size <- function(mat.dim = NULL, wind.size.inch = NULL, resol.disp.inch = NULL, down.space = 3, left.space = 4, up.space = 5, right.space = 4, mat.scale.dim = NULL, width.inch.scale = NULL, scale.margin = 4, max.size = 20){
# AIM:
# Set the window parameters for matrix display
# BEWARE: to have a square matrix displayed, down.space + up.space has to equal to left.space + right.space
# BEWARE: keep the same resol.disp.inch for the different matrix to keep proportionality
# ARGUMENTS
# mat.dim: vector indicating the number of rows & number of columns of the matrix. If NULL, standard window will be opened
# wind.size.inch: window width and height in inches. If NULL, not taken into account. Override mat.dim. Do not use resol.disp.inch
# resol.disp.inch: number of rows / columns per inch desired in the plot. If NULL, not taken into account
# down.space: bottom margin space of the main plot (in par(mar()) units)
# up.space: top margin space of the main plot  (in par(mar()) units)
# left.space: left margin space of the main plot  (in par(mar()) units)
# right.space: right margin space of the main plot  (in par(mar()) units)
# mat.scale.dim: vector indicating the number of rows & number of columns of the scale matrix; If 1 column, use 1 inch for width of scale plot. If more than 1 column, use 3 inches for width. Not affected by resol.disp.inch. If NULL; use width.inch.scale and if is also NULL, no room defined for scale plot
# width.inch.scale: if not NULL, width of the scale displayed (in inches, which correspond to width.inch.scale / 0.2 par(mar()) units). Not affected by resol.disp.inch. Override mat.scale.dim. If NULL and mat.scale.dim = NULL, no room defined for scale plot
# scale.margin.space: increase the margins for the overlay 2D scale matrix defined by par(mar). If 0, no margins added
# max.size: max width or height size of the window (in inches)
# RETURN a list of the following compartments:
# height.wind: total window height, margins added (in inches)
# width.wind: total window width, margins added (in inches)
# width.wind.scale: scale window width, scale magins added (in inches)
# wind.text: text generated for the resized window
# down.space: bottom margin space of the main plot (in par(mar()) units)
# up.space: top margin space of the main plot  (in par(mar()) units)
# left.space: left margin space of the main plot  (in par(mar()) units)
# right.space: right margin space of the main plot  (in par(mar()) units)
# down.space.scale: bottom margin space of the scale plot (in par(mar()) units)
# up.space.scale: top margin space of the scale plot  (in par(mar()) units)
# left.space.scale: left margin space of the scale plot  (in par(mar()) units)
# right.space.scale: right margin space of the scale plot  (in par(mar()) units)
# EXAMPLES:
# output.fun.mat.window.size <- fun.mat.window.size(dim(output.fun.matrix.rgb.colorization$colored.mat), resol.disp.inch = NULL, mat.scale.dim = dim(output.fun.matrix.rgb.colorization$mat.color.scale), scale.margin = 1, max.size = 20)
# mat.dim = dim(output.fun.matrix.rgb.colorization$colored.mat) ; resol.disp.inch = NULL ; mat.scale.dim = dim(output.fun.matrix.rgb.colorization$mat.color.scale) ; width.inch.scale = NULL ; down.space = 3 ; left.space = 4 ; up.space = 5 ; right.space = 4 ; scale.margin = 4 ; max.size = 20
down.space <- down.space
left.space <- left.space
up.space <- up.space
right.space <- right.space
if(is.null(wind.size.inch) & ((down.space + up.space) == (left.space + right.space))){
wind.text <- "CASES OF PLOTTED MATRIX ARE PERFECT SQUARE"
}else{
wind.text <- "BEWARE: CASES OF PLOTTED MATRIX MIGHT NOT BE SQUARES"
}
if(is.null(resol.disp.inch)){
resol.disp.inch <- 1
}
if( ! all(is.null(wind.size.inch))){
wind.width.tempo <- wind.size.inch # size of the square matrix in inches
wind.height.tempo <- wind.size.inch # size of the square matrix in inches
}else if(all(is.null(mat.dim))){
wind.width.tempo <- 5 / resol.disp.inch
wind.height.tempo <- 5 / resol.disp.inch
}else{
wind.width.tempo <- mat.dim[2] / resol.disp.inch # size of the square matrix in inches
wind.height.tempo <- mat.dim[1] / resol.disp.inch # size of the square matrix in inches
}
# (left.space + right.space) * 0.2 # this is the size in inches occupied by the vertical margins of the graph. Indeed, par()$mai/par()$mar is generally equal to 0.2 inches per line, with par()$mai the margins in inches and par()$mar the margins in lines
height.wind <- wind.height.tempo + (up.space + down.space) * 0.2 # height of the graphic windows in inches
width.wind <- wind.width.tempo + (left.space + right.space) * 0.2 # width of the graphic windows in inches
if( ! is.null(mat.scale.dim)){
if(mat.scale.dim[2] == 1){
width.wind.scale <- 3 # 1 inch
}else{
width.wind.scale <- 3 # 3 inches
}
}else{
width.wind.scale <- 0
}
if( ! is.null(width.inch.scale)){
width.wind.scale <- width.inch.scale
}
if( ! is.null(mat.scale.dim)){
if(mat.scale.dim[2] == 1){
up.space.scale <- (height.wind / 4) / 0.2 # 1/4 of height.wind for the top scale window
down.space.scale <- (height.wind / 4) / 0.2 # 1/4 of height.wind for the top scale window
prop.scale.wind <- 1/15 # the proportion 1/12 of width.wind.scale represented by the plot region
left.space.scale <- ((width.wind.scale - (width.wind.scale * prop.scale.wind)) / 4) / 0.2 # the width of the scale plot is set to 1/10 of width.wind.scale
right.space.scale <- (width.wind.scale - (width.wind.scale * prop.scale.wind)) / 0.2 - left.space.scale
}else{
if(height.wind > width.wind.scale){
up.space.scale <-  scale.margin + ((height.wind / 0.2 - ( scale.margin + scale.margin)) - (width.wind.scale / 0.2 - (scale.margin + scale.margin))) / 2 # a' + ((Y/0.2 - 2a') - (X/0.2 - 2a)) / 2

 

down.space.scale <-  scale.margin + ((height.wind / 0.2 - ( scale.margin + scale.margin)) - (width.wind.scale / 0.2 - (scale.margin + scale.margin))) / 2 # a' ((Y/0.2 - 2a') - (X/0.2 - 2a)) / 2
left.space.scale <- scale.margin
right.space.scale <- scale.margin
}else{
left.space.scale <-  scale.margin + ((width.wind.scale / 0.2 - ( scale.margin + scale.margin)) - (height.wind / 0.2 - (scale.margin + scale.margin))) / 2 # a' ((Y/0.2 - 2a') - (X/0.2 - 2a)) / 2
right.space.scale <-  scale.margin + ((width.wind.scale / 0.2 - ( scale.margin + scale.margin)) - (height.wind / 0.2 - (scale.margin + scale.margin))) / 2 # a' ((Y/0.2 - 2a') - (X/0.2 - 2a)) / 2
up.space.scale <- scale.margin
down.space.scale <- scale.margin
}
}
}else{
up.space.scale <- 0
right.space.scale <- 0
down.space.scale <- 0
left.space.scale <- 0
}
if(width.wind < (right.space + left.space) * 0.2){
tempo.cat <- paste0("right.space (", right.space, ") AND left.space (", left.space, ") ARGUMENTS TOO BIG FOR THE FINAL WINDOW WIDTH (", width.wind, ")")
stop(tempo.cat, "\n\n")
}
if(height.wind < (up.space + down.space) * 0.2){
tempo.cat <- paste0("up.space (", up.space, ") AND down.space (", down.space, ") ARGUMENTS TOO BIG FOR THE FINAL WINDOW HEIGHT (", height.wind, ")")
stop(tempo.cat, "\n\n")
}
if(width.wind.scale < (right.space.scale + left.space.scale) * 0.2){
tempo.cat <- paste0("right.space.scale (", right.space.scale, ") AND left.space.scale (", left.space.scale, ") ARGUMENTS TOO BIG FOR THE FINAL SCALE WINDOW WIDTH (", width.wind.scale, ")")
stop(tempo.cat, "\n\n")
}
if(height.wind < (up.space.scale + down.space.scale) * 0.2){
tempo.cat <- paste0("up.space.scale (", up.space.scale, ") AND down.space.scale (", down.space.scale, ") ARGUMENTS TOO BIG FOR THE FINAL SCALE WINDOW HEIGHT (", height.wind, ")")
stop(tempo.cat, "\n\n")
}
width.wind <- width.wind + width.wind.scale
if(width.wind > max.size | height.wind > max.size){
if(width.wind > height.wind){
cor.factor <- max.size / width.wind
}else{
cor.factor <- max.size / height.wind
}
width.wind <- width.wind * cor.factor
height.wind <- height.wind * cor.factor
width.wind.scale <- width.wind.scale * cor.factor
down.space <- down.space * cor.factor
left.space <- left.space * cor.factor
up.space <- up.space * cor.factor
right.space <- right.space * cor.factor
down.space.scale <- down.space.scale * cor.factor
left.space.scale <- left.space.scale * cor.factor
up.space.scale <- up.space.scale * cor.factor
right.space.scale <- right.space.scale * cor.factor
wind.text <- paste0(wind.text, "\nBEWARE: MAX WINDOW SIZE REACHED (", max.size," INCHES)")
}else{
wind.text <- paste0(wind.text, "\nMAX WINDOW SIZE NOT REACHED (", max.size," INCHES)") # to the other proportional matrices
}
output <- list(height.wind = height.wind, width.wind = width.wind, width.wind.scale = width.wind.scale, wind.text = wind.text, down.space = down.space, up.space = up.space, left.space = left.space, right.space = right.space, down.space.scale = down.space.scale, up.space.scale = up.space.scale, left.space.scale = left.space.scale, right.space.scale = right.space.scale)
return(output)
}


################ Matrix plots keeping same window sizes


fun.mat.fixed.window.size <- function(mat.dim, wind.size = c(7, 7), margin.space = 1.5, scale.mat.dim = NULL, scale.wind.width = NULL, scale.margin.space = 0.5, scale.plot.region.width.multi = 1){
# AIM:
# Set the window parameters for matrix display with systematic square cases
# REQUIRED FUNCTIONS:
# param_check_fun
# ARGUMENTS:
# mat.dim: vector indicating the number of rows & number of columns of the matrix, respectively
# wind.size: numeric vector of length 2 indicating the window width and height in inches, respectively. Default c(7, 7)
# margin.space: minimal margin size in inches (for par(mai)). If the matrix is square and wind.size is also square, margin.space will be used for the four sides. Otherwise, it will be used for 2 sides corresponding to the smallest margins of the graphic windows
# scale.mat.dim: vector indicating the number of rows & number of columns of the scale matrix. If NULL, no room defined for scale plot
# scale.wind.width: figure region width of the scale, in inches. Ignored if scale.mat.dim is NULL. If NULL and if scale.mat.dim not NULL, then use 3 inches for width
# scale.margin.space: as margin spaces but for scale. Ignored if scale.mat.dim is NULL
# scale.plot.region.width.multi: multiplication factor of the scale plot region width relative to scale.wind.width. For instance, if scale.wind.width = 3 inches and scale.plot.region.width.multi = 0.1, then the width of the scale plot region is 0.3 inches. Only used when scale.mat.dim has a single column. As consequence, scale.margin.space is only used for up and down margins when scale.mat.dim has a single column. Ignored if scale.mat.dim is NULL
# RETURN a list of the following compartments:
# wind.height: main figure and scale figure height (in inches)
# wind.width: main figure width, not including scale width (in inches)
# height.plot.region: height of the main plot region (in inches)
# width.plot.region: width of the main plot region (in inches)
# mat.ratio: ratio nrow/ncol of the matrix
# down.space: bottom margin space of the main plot (in inches ie par(mai()) units)
# up.space: top margin space of the main plot (in inches ie par(mai()) units)
# left.space: left margin space of the main plot (in inches ie par(mai()) units)
# right.space: right margin space of the main plot (in inches ie par(mai()) units)
# scale.wind.width: scale figure width (in inches)
# scale.height.plot.region: height of the scale plot region (in inches)
# scale.width.plot.region: width of the scale plot region (in inches)
# scale.mat.ratio: ratio nrow/ncol of the scale matrix
# scale.down.space: bottom margin space of the scale plot (in inches ie par(mai()) units)
# scale.up.space: top margin space of the scale plot (in inches ie par(mai()) units)
# scale.left.space: left margin space of the scale plot (in inches ie par(mai()) units)
# scale.right.space: right margin space of the scale plot (in inches ie par(mai()) units)
# wind.text: text generated for the resized window
# EXAMPLES:
# mat.dim = as.integer(c(57, 4)) ; wind.size = c(7.7, 5.4) ; margin.space = 0.1 ; scale.mat.dim = as.integer(c(100, 1)) ; scale.wind.width = 3 ; scale.margin.space = 0.5 ; scale.plot.region.width.multi = 0.33
# mat.dim = dim(output.fun.matrix.rgb.colorization$colored.mat) ; wind.size = c(7.7, 5.4) ; margin.space = 0.1 ; scale.mat.dim = as.integer(c(100, 1)) ; scale.wind.width = 3 ; scale.margin.space = 0.5 ; scale.plot.region.width.multi = 0.33
# output.fun.mat.fixed.window.size <- fun.mat.fixed.window.size(mat.dim = dim(output.fun.matrix.rgb.colorization$colored.mat), wind.size = c(7, 70), margin.space = 0.5, scale.mat.dim = dim(output.fun.matrix.rgb.colorization$mat.color.scale), scale.wind.width = NULL, scale.margin.space = 0.1)
# arguments check
# add param_check_fun detected
tempo <- param_check_fun(data = mat.dim, typeof = "integer", length = 2, print = FALSE)
if(tempo$problem == TRUE){
stop(tempo$text)
}
tempo <- param_check_fun(data = wind.size, class = "numeric", length = 2, print = FALSE)
if(tempo$problem == TRUE){
stop(tempo$text)
}
tempo <- param_check_fun(data = margin.space, class = "numeric", length = 1, print = FALSE)
if(tempo$problem == TRUE){
stop(tempo$text)
}
tempo <- param_check_fun(data = scale.mat.dim, typeof = "integer", length = 2, print = FALSE)
if( ! (is.null(scale.mat.dim)) & tempo$problem == TRUE){
cat("\n\n PARAMETER scale.mat.dim IS NOT NULL AND\n\n")
stop(tempo$text)
}
if( ! (is.null(scale.mat.dim))){
tempo <- param_check_fun(data = scale.wind.width, class = "numeric", length = 1, print = FALSE)
if( ! (is.null(scale.wind.width)) & tempo$problem == TRUE){
cat("\n\n PARAMETER scale.wind.width IS NOT NULL AND\n\n")
stop(tempo$text)
}
tempo <- param_check_fun(data = scale.margin.space, class = "numeric", length = 1, print = FALSE)
if(tempo$problem == TRUE){
stop(tempo$text)
}
tempo <- param_check_fun(data =  scale.plot.region.width.multi, class = "numeric", length = 1, print = FALSE)
if(tempo$problem == TRUE){
stop(tempo$text)
}
}
# end arguments check
# parameters of the main plot
wind.width <- wind.size[1]
wind.height <- wind.size[2]
if((margin.space * 2 + 0) > wind.width | (margin.space * 2 + 0) > wind.height){
tempo.cat <- paste0("\n\n================\n\nERROR: WITH ", margin.space, " INCHES, PARAMETER margin.space IS TOO BIG FOR THE WINDOW WIDTH OR HEIGHT (", paste0(wind.size, collapse = " "), ")\nTWICE THE MARGINS + 0 INCH MINIMUM FOR THE PLOT REGION IS ", (margin.space * 2 + 0), " INCHES\n\n================\n\n")
stop(tempo.cat, "\n\n")
}
down.space.ini <- margin.space
left.space.ini <- margin.space
up.space.ini <- margin.space
right.space.ini <- margin.space
plot.region.width.ini <- wind.width - margin.space * 2 # in inches
plot.region.height.ini <- wind.height - margin.space * 2 # in inches
plot.region.ratio <- plot.region.height.ini / plot.region.width.ini
mat.ratio <- mat.dim[1] / mat.dim[2] # ratio nrow/ncol (mat.height/mat.width)
if(mat.ratio < plot.region.ratio){ # down and up margins have to be increased
left.space.add <- 0 # in inches
right.space.add <- 0 # in inches
mat.width <- plot.region.width.ini # in inches
if((plot.region.ratio / mat.ratio) < 1){
mat.height <- plot.region.height.ini * (plot.region.ratio / mat.ratio) # in inches
}else{
mat.height <- plot.region.height.ini / (plot.region.ratio / mat.ratio) # in inches
}
up.space.add <- (plot.region.height.ini - mat.height) / 2
down.space.add <- (plot.region.height.ini - mat.height) / 2
} else if (mat.ratio > plot.region.ratio){ # left and right margins have to be increased
up.space.add <- 0 # in inches
down.space.add <- 0 # in inches
if((plot.region.ratio / mat.ratio) < 1){
mat.width <- plot.region.width.ini * (plot.region.ratio / mat.ratio) # in inches
}else{
mat.width <- plot.region.width.ini / (plot.region.ratio / mat.ratio) # in inches
}
left.space.add <- (plot.region.width.ini - mat.width) / 2
right.space.add <- (plot.region.width.ini - mat.width) / 2
}else if(mat.ratio == plot.region.ratio){
up.space.add <- 0 # in inches
down.space.add <- 0 # in inches
left.space.add <- 0 # in inches
right.space.add <- 0 # in inches
}else{
tempo.cat <- paste0("\n\n================\n\nERROR: PROBLEMS IN THE PARAMETERS mat.ratio AND plot.region.ratio FROM THE fun.mat.fixed.window.size() FUNCTION\n\n================\n\n")
stop(tempo.cat, "\n\n")
}
down.space <- down.space.ini + down.space.add
left.space <- left.space.ini + left.space.add
up.space <- up.space.ini + up.space.add
right.space <- right.space.ini + right.space.add
mat.height <- wind.height - up.space - down.space # in inches
mat.width <- wind.width - right.space - left.space # in inches
wind.text <- "CASES OF PLOTTED MATRIX ARE PERFECT SQUARE"
# parameters of the scale plot
if(is.null(scale.mat.dim)){ # no scale required
scale.wind.width <- NULL
scale.down.space <- NULL
scale.left.space <- NULL
scale.up.space <- NULL
scale.right.space <- NULL
scale.mat.height <- NULL
scale.mat.width <- NULL
scale.mat.ratio <- NULL # ratio nrow/ncol
}else{
if(is.null(scale.wind.width)){ # no particular width specified for scale
scale.wind.width <- 3 # 3 inches
}
# idem code above but for the scale matrix
if(scale.mat.dim[2] == 1){ # only one colum
scale.down.space <- scale.margin.space
scale.up.space <- scale.margin.space
scale.left.space <- (scale.wind.width - scale.wind.width * scale.plot.region.width.multi) / 2
scale.right.space <- (scale.wind.width - scale.wind.width * scale.plot.region.width.multi) / 2
scale.mat.height <- wind.height - scale.up.space - scale.down.space
scale.mat.width <- scale.wind.width - scale.right.space - scale.left.space
scale.mat.ratio <- scale.mat.dim[1] / scale.mat.dim[2] # ratio nrow/ncol
}else{
if((scale.margin.space * 2 + 0) > scale.wind.width | (scale.margin.space * 2 + 0) > wind.height){
tempo.cat <- paste0("\n\n================\n\nERROR: WITH ", scale.margin.space, " INCHES, PARAMETER scale.margin.space IS TOO BIG FOR THE WINDOW WIDTH OR HEIGHT (", scale.wind.width, " AND ", wind.height, ")\nTWICE THE MARGINS + 0 INCH MINIMUM FOR THE PLOT REGION IS ", (scale.margin.space * 2 + 0), " INCHES\n\n================\n\n")
stop(tempo.cat, "\n\n")
}
scale.down.space.ini <- scale.margin.space
scale.left.space.ini <- scale.margin.space
scale.up.space.ini <- scale.margin.space
scale.right.space.ini <- scale.margin.space
scale.plot.region.height.ini <- wind.height - scale.margin.space * 2 # in inches
scale.plot.region.width.ini <- scale.wind.width - scale.margin.space * 2 # in inches
scale.plot.region.ratio <- scale.plot.region.height.ini / scale.plot.region.width.ini
scale.mat.ratio <- scale.mat.dim[1] / scale.mat.dim[2] # ratio nrow/ncol (scale.mat.height/scale.mat.width)
if(scale.mat.ratio < scale.plot.region.ratio){ # down and up margins have to be increased
scale.left.space.add <- 0 # in inches
scale.right.space.add <- 0 # in inches
if((scale.plot.region.ratio / scale.mat.ratio) < 1){
scale.mat.height <- scale.plot.region.height.ini * (scale.plot.region.ratio / scale.mat.ratio) # in inches
}else{
scale.mat.height <- scale.plot.region.height.ini / (scale.plot.region.ratio / scale.mat.ratio) # in inches
}
scale.up.space.add <- (scale.plot.region.height.ini - scale.mat.height) / 2
scale.down.space.add <- (scale.plot.region.height.ini - scale.mat.height) / 2
}else if (scale.mat.ratio > scale.plot.region.ratio){ # left and right margins have to be increased
scale.up.space.add <- 0 # in inches
scale.down.space.add <- 0 # in inches
if((scale.plot.region.ratio / scale.mat.ratio) < 1){
scale.mat.width <- scale.plot.region.width.ini * (scale.plot.region.ratio / scale.mat.ratio) # in inches
}else{
scale.mat.width <- scale.plot.region.width.ini / (scale.plot.region.ratio / scale.mat.ratio) # in inches
}
scale.left.space.add <- (scale.plot.region.width.ini - scale.mat.width) / 2
scale.right.space.add <- (scale.plot.region.width.ini - scale.mat.width) / 2
}else if(scale.mat.ratio == scale.plot.region.ratio){
scale.up.space.add <- 0 # in inches
scale.down.space.add <- 0 # in inches
scale.left.space.add <- 0 # in inches
scale.right.space.add <- 0 # in inches
}else{
tempo.cat <- paste0("\n\n================\n\nERROR: PROBLEMS IN THE PARAMETERS scale.mat.ratio AND scale.plot.region.ratio FROM THE fun.mat.fixed.window.size() FUNCTION\n\n================\n\n")
stop(tempo.cat, "\n\n")
}
scale.down.space <- scale.down.space.ini + scale.down.space.add
scale.left.space <- scale.left.space.ini + scale.left.space.add
scale.up.space <- scale.up.space.ini + scale.up.space.add
scale.right.space <- scale.right.space.ini + scale.right.space.add
scale.mat.height <- wind.height - scale.up.space - scale.down.space
scale.mat.width <- scale.wind.width - scale.right.space - scale.left.space
wind.text <- paste0(wind.text, "\nCASES OF SCALE MATRIX ARE PERFECT SQUARE")
}
}
if(mat.width <= 0 | mat.height <= 0){
tempo.cat <- paste0("\n\n================\n\nERROR: WITH ", margin.space, " INCHES, PARAMETER margin.space IS TOO BIG FOR THE WINDOW WIDTH OR HEIGHT (", wind.width, " AND ", wind.height, ", RESPECTIVELY)\nWIDTH AND HEIGHT MUST BE MORE THAN TWICE THE MARGINS\n\n================\n\n")
stop(tempo.cat, "\n\n")
}
if( ! (is.null(scale.mat.width) & is.null(scale.mat.height))){
if(scale.mat.width <= 0 | scale.mat.height <= 0){
tempo.cat <- paste0("\n\n================\n\nERROR: WITH ", scale.margin.space, " INCHES, PARAMETER scale.margin.space IS TOO BIG FOR THE WINDOW WIDTH OR HEIGHT (", scale.wind.width, " AND ", wind.height, ")\nTWICE THE MARGINS + 0 INCH MINIMUM FOR THE PLOT REGION IS ", (scale.margin.space * 2 + 0), " INCHES\n\n================\n\n")
stop(tempo.cat, "\n\n")
}
}
output <- list(wind.height = wind.height, wind.width = wind.width, height.plot.region = mat.height, width.plot.region = mat.width, mat.ratio = mat.ratio, down.space = down.space, up.space = up.space, left.space = left.space, right.space = right.space, scale.wind.width = scale.wind.width, scale.height.plot.region = scale.mat.height, scale.width.plot.region = scale.mat.width, scale.mat.ratio = scale.mat.ratio, scale.down.space = scale.down.space, scale.up.space = scale.up.space, scale.left.space = scale.left.space, scale.right.space = scale.right.space, wind.text = wind.text)
return(output)
}


################ Open graph windows in R or pdf


fun.open.window <- function(pdf.disp = TRUE, path.fun = "C:/Users/Gael/Desktop", pdf.name.file = "graphs", width.fun = 7, height.fun = 7, paper = "special", return.output = FALSE){
# AIM:
#open a pdf or screen graphic window
# ARGUMENTS:
# pdf.disp: use pdf or not
# path.fun: where the pdf is saved. Must not finish by a path separator
# pdf.name.file: name of the pdf file containing the graphs
# width.fun: width of the windows (in inches). Can be width.wind.var from fun.window.size function
# height.fun: height of the windows (in inches)
# paper: paper argument of the pdf function (paper format). Only used for pdf()
# return.output: return output ? If TRUE but function not assigned, the output list is displayed
# RETURN a list of the following compartments:
# pdf.loc: path of the pdf created
# par.ini: initial par() parameters (to reset in a new graph)
# zone.ini: initial window spliting (to reset in a new graph)
# EXAMPLES:
# pdf.disp = TRUE ; path.fun = "C:/Users/Gael/Desktop" ; pdf.name.file = "graphs" ; width.fun = 7 ; height.fun = 7 ; paper = "special" ; return.output = TRUE
if(Sys.info()["sysname"] == "Windows"){ # .Platform$OS.type() only says "unix" for macOS and Linux and "Windows" for Windows
windows()
}else if(Sys.info()["sysname"] == "Linux"){
# do nothing
}else{
quartz()
}
par.ini <- par(no.readonly = TRUE) # to recover the initial graphical parameters if required (reset)
invisible(dev.off()) # close the new window
zone.ini <- matrix(1, ncol=1) # to recover the initial parameters for next figure region when device region split into several figure regions
if(pdf.disp == TRUE){
pdf.loc <- paste0(path.fun, "/", pdf.name.file, ".pdf")
pdf(width = width.fun, height = height.fun, file=pdf.loc, paper = paper)
}else if(pdf.disp == FALSE){
pdf.loc <- NULL
if(Sys.info()["sysname"] == "Windows"){ # .Platform$OS.type() only says "unix" for macOS and Linux and "Windows" for Windows
windows(width = width.fun, height = height.fun, rescale="fixed")
}else if(Sys.info()["sysname"] == "Linux"){
stop("PROBLEM: THIS FUNCTION CANNOT RUN ON LINUX OR NON MACOS UNIX SYSTEM (GRAPHIC INTERFACE HAS TO BE SET")
}else{
quartz(width = width.fun, height = height.fun)
}
}else{
stop("PROBLEM: ARGUMENT pdf.disp CAN ONLY BE TRUE OR FALSE")
}
if(return.output == TRUE){
output <- list(pdf.loc = pdf.loc, par.ini = par.ini, zone.ini = zone.ini)
return(output)
}
}


################ Graphical parameters prior plotting


fun.graph.param <- function(down.space.fun = down.space, left.space.fun = left.space, up.space.fun = up.space, right.space.fun = right.space, orient = 1, dist.legend = 4.5, tick.length = 0.5, box.type = "l", amplif.label = amplif, amplif.axis = amplif){
## Use this to fashion axes without redrawing them. BEWARE: require fun.window.size() function for default values of down.space.fun, left.space.fun, up.space.fun, right.space.fun
# up.space.fun: upper vertical margin between plot region and grapical window defined by par(mar)
# down.space.fun: lower vertical margin
# left.space.fun: left horizontal margin
# right.space.fun: right horizontal margin
# orient: for par(las)
# dist.legend: increase the number to move axis legends away
# tick.length: length of the ticks (1 means complete the distance between the plot region and the axis numbers, 0.5 means half the length, etc.
# box.type: equivalent to par()$bty
# amplif.label: increase or decrease the size of the text in legends
# amplif.axis: increase or decrease the size of the numbers in axis
par(mar = c(down.space.fun, left.space.fun, up.space.fun, right.space.fun), las = orient, mgp = c(dist.legend, 1, 0), xpd = FALSE, bty= box.type, cex.lab = amplif.label, cex.axis = amplif.axis)
par(tcl = -par()$mgp[2] * tick.length) # tcl gives the length of the ticks as proportion of line text, knowing that mgp is in text lines. So the main ticks are a 0.5 of the distance of the axis numbers by default. The sign provides the side of the tick (negative for outside of the plot region)
}


fun.graph.param.prior.axis <- function(xlog.scale = "", ylog.scale = "", ann.fun = FALSE, xaxt.fun = "n", yaxt.fun = "n", down.space.fun = down.space, left.space.fun = left.space, up.space.fun = up.space, right.space.fun = right.space, orient = 1, dist.legend = 4.5, tick.length = 0.5, box.type = "n", amplif.label = amplif, amplif.axis = amplif){
## Use this to erase axes before redrawing them using fun.axis.bg.feature. BEWARE: require fun.window.size() function for default values of down.space.fun, left.space.fun, up.space.fun, right.space.fun
# xlog.scale: if there is a log scale planned or not for x-axis. Use xlog.scale or other
# ylog.scale: if there is a log scale planned or not for y-axis. Use ylog.scale or other
# ann.fun: remove labels (axis legend) of the two axes (TRUE OR FALSE ONLY)
# xaxt.fun: remove x-axis except labels ("n" or "s" only). Inactivated if xlog.scale = "x"
# yaxt.fun: remove y-axis except labels ("n" or "s" only). Inactivated if ylog.scale = "y"
# up.space.fun: upper vertical margin between plot region and grapical window (in inches, mai argument of par())
# down.space.fun: lower vertical margin (in inches, mai argument of par())
# left.space.fun: left horizontal margin (in inches, mai argument of par())
# right.space.fun: right horizontal margin (in inches, mai argument of par())
# orient: for par(las)
# dist.legend: increase the number to move axis legends away
# tick.length: length of the ticks (1 means complete the distance between the plot region and the axis numbers, 0.5 means half the length, etc.
# box.type: equivalent to par()$bty
# amplif.label: increase or decrease the size of the text in legends
# amplif.axis: increase or decrease the size of the numbers in axis
par(mai = c(down.space.fun, left.space.fun, up.space.fun, right.space.fun), ann = ann.fun, xaxt = xaxt.fun, yaxt = yaxt.fun , las = orient, mgp = c(dist.legend, 1, 0), xpd = FALSE, bty= box.type, cex.lab = amplif.label, cex.axis = amplif.axis)
par(tcl = -par()$mgp[2] * tick.length) # tcl gives the length of the ticks as proportion of line text, knowing that mgp is in text lines. So the main ticks are a 0.5 of the distance of the axis numbers by default. The sign provides the side of the tick (negative for outside of the plot region)
if(xlog.scale == "x"){
par(xaxt = "n", xlog = TRUE) # suppress the x-axis label
}else{
par(xlog = FALSE)
}
if(ylog.scale == "y"){
par(yaxt = "n", ylog = TRUE) # suppress the y-axis label
}else{
par(ylog = FALSE)
}
}


################ Plot


################ Matrix plot for fixed windows (raster)


fun.colored.fixed.matrix.plot <- function(colored.mat, mat.color.scale = NULL, null.dyn.display = TRUE, disp.axis = TRUE, xside = 3, yside = 2, nb.row.tick = 0, nb.col.tick = 0, x.nb.inter.tick = 0, y.nb.inter.tick = 0, tick.length = 0.1, axis.magnific = 1.5, orient = 2, dist.legend = 2, box.type = "o", x.adj = "i", y.adj = "i", text.corner = "", magnific.text.corner = 1.5, disp.axis.scale = TRUE, xside.scale = 1, yside.scale = 2, nb.main.tick.scale = 3, nb.inter.tick.scale = 0, tick.length.scale = 0.1, orient.scale = 2, dist.legend.scale = 2, box.type.scale = "o", axis.magnific.scale = 1.5, label.magnific.scale = 1.5, output.fun.mat.fixed.window.size = output.fun.mat.fixed.window.size, output.fun.matrix.rgb.colorization = output.fun.matrix.rgb.colorization){
# AIM:
# plot a colored matrix with scale on the right side
# REQUIRED FUNCTIONS:
# param_check_fun
# fun.matrix.rgb.colorization()
# fun.mat.fixed.window.size()
# fun.mat.graph.param()
# fun.mat.post.graph.feature()
#fun.scale.post.graph.feature()
# ARGUMENTS:
# colored.mat: matrix of hexadecimal colors (matrix class) (provided by fun.matrix.rgb.colorization())
# mat.color.scale: matrix (1D) or matrix (2D) hexadecimal colors indicating the color scale (provided by fun.matrix.rgb.colorization()). If NULL, no scale displayed
# null.dyn.display: display something when no dynamic ?
# disp.axis: display ticks and row and column names on axis ?
# xside: x-axis at the bottom (1) or top (3) of the region figure. Write 0 if no axis required
# yside: y-axis at the left (2) or right (4) of the region figure. Write 0 if no axis required
# nb.row.tick: nb of row ticks and labels
# nb.col.tick: nb of col ticks and labels
# x.nb.inter.tick: number of secondary ticks between main ticks on x-axis (only if not log scale). Zero means non secondary ticks
# y.nb.inter.tick: number of secondary ticks between main ticks on y-axis (only if not log scale). Zero means non secondary ticks
# tick.length: length of the ticks (1 means complete the distance between the plot region and the axis numbers, 0.5 means half the length, etc. O means no ticks
# axis.magnific: increase or decrease the size of the numbers in axis of the main plot
# orient: for par(las)
# dist.legend: increase the number to move axis legends away
# box.type: increase the number to move axis legends away
# x.adj: "i" (default) to remove the extra 4% on each side of the axes range, "r" to maintain the extra 4%
# y.adj: "i" (default) to remove the extra 4% on each side of the axes range, "r" to maintain the extra 4%
# text.corner: text to add at the top right corner of the window
# magnific.text.corner: increase or decrease the size of the text
# disp.axis.scale: display axis scale?
# xside.scale: x-axis at the bottom (1) or top (3) of the region figure. Write 0 if no axis required
# yside.scale: y-axis at the left (2) or right (4) of the region figure. Write 0 if no axis required
# nb.main.tick.scale: nb of main ticks and labels
# nb.inter.tick.scale: number of secondary ticks between main ticks (only if not log scale). Zero means non secondary ticks
# tick.length.scale: length of the ticks (1 means complete the distance between the plot region and the axis numbers, 0.5 means half the length, etc. O means no ticks
# orient.scale: for par(las)
# dist.legend.scale: increase the number to move axis legends away
# box.type.scale: increase the number to move axis legends away
# axis.magnific.scale: increase or decrease the value to increase or decrease the size of the axis numbers in the scale plot
# label.magnific.scale: increase or decrease the value to increase or decrease the size of the axis legend in the scale plot (only for overlay 2D plot)
# output.fun.mat.fixed.window.size: output list of fun.mat.fixed.window.size()
# output.fun.matrix.rgb.colorization: output list of fun.matrix.rgb.colorization()
# RETURN:
# the plot
# EXAMPLES:
# amplif = 1 ; color.scale.display = TRUE ; resol.display.inch = 0.05 ; output.fun.mat.fixed.window.size <- fun.mat.fixed.window.size() ; colored.mat = output.fun.matrix.rgb.colorization$colored.mat ; mat.color.scale = output.fun.matrix.rgb.colorization$mat.color.scale ; null.dyn.display = TRUE ; disp.axis = TRUE ; xside = 3 ; yside = 2 ; nb.row.tick = nrow(colored.mat) ; nb.col.tick = ncol(colored.mat) ; x.nb.inter.tick = 0 ; y.nb.inter.tick = 0 ; tick.length = 0.5 ; axis.magnific = 1 ; orient = 2 ; dist.legend = 2 ; box.type = "o" ; axis.magnific = 1 ; x.adj = "i" ; y.adj = "i" ; text.corner = "" ; magnific.text.corner = magnific/2 ; disp.axis.scale = TRUE ; xside.scale = 1 ; yside.scale = 2 ; nb.main.tick.scale = 3 ; nb.inter.tick.scale = 0 ; tick.length.scale = 0.5 ; orient.scale = 2 ; dist.legend.scale = 2 ; box.type.scale = "o" ; axis.magnific.scale = 1 ; label.magnific.scale = 1 ; output.fun.mat.fixed.window.size = output.fun.mat.fixed.window.size ; output.fun.matrix.rgb.colorization = output.fun.matrix.rgb.colorization
# colored.mat = output.fun.matrix.rgb.colorization$colored.mat ; mat.color.scale = output.fun.matrix.rgb.colorization$mat.color.scale ; null.dyn.display = null.dyn.display ; disp.axis = disp.axis.mat.plot ; xside = xside.mat.plot ; yside = yside.mat.plot ; nb.row.tick = nrow(output.fun.matrix.rgb.colorization$colored.mat) ; nb.col.tick = ncol(output.fun.matrix.rgb.colorization$colored.mat) ; x.nb.inter.tick = x.nb.inter.tick.mat.plot ; y.nb.inter.tick = y.nb.inter.tick.mat.plot ; tick.length = tick.length.mat.plot ; axis.magnific = axis.amplif.mat.plot ; orient = orient.mat.plot ; dist.legend = dist.legend.mat.plot ; box.type = box.type.mat.plot ; x.adj = x.adj.mat.plot ; y.adj = y.adj.mat.plot ; text.corner = text.mat.plot ; magnific.text.corner = amplif.text.corner.mat.plot ; disp.axis.scale = disp.axis.scale.mat.plot ; xside.scale = xside.scale.mat.plot ; yside.scale = yside.scale.mat.plot ; nb.main.tick.scale = nb.main.tick.scale.mat.plot ; nb.inter.tick.scale = nb.inter.tick.scale.mat.plot ; tick.length.scale = tick.length.scale.mat.plot ; orient.scale = orient.scale.mat.plot ; dist.legend.scale = dist.legend.scale.mat.plot ; box.type.scale = box.type.scale.mat.plot ; axis.magnific.scale = axis.amplif.scale.mat.plot ; label.magnific.scale = label.amplif.scale.mat.plot ; output.fun.mat.fixed.window.size = output.fun.mat.fixed.window.size ; output.fun.matrix.rgb.colorization = output.fun.matrix.rgb.colorization
if( ! (all(class(colored.mat) == "matrix") & all(typeof(colored.mat) == "character"))){
tempo.cat <- paste0("colored.mat ARGUMENT MUST BE A CHARACTER MATRIX OF HEXADECIMAL COLORS")
stop(tempo.cat, "\n\n")
}
if( ! (all(is.null(mat.color.scale)) | (all(class(mat.color.scale) == "matrix") & all(typeof(mat.color.scale) == "character")))){
tempo.cat <- paste0("mat.color.scale ARGUMENT MUST BE A CHARACTER MATRIX OF HEXADECIMAL COLORS OR A NULL VECTOR")
stop(tempo.cat, "\n\n")
}
if(text.corner != ""){
text.corner <- paste0(text.corner, "\n", output.fun.matrix.rgb.colorization$log.txt , "\n", output.fun.mat.fixed.window.size$wind.text)
}else{
text.corner <- paste0(output.fun.matrix.rgb.colorization$log.txt , "\n", output.fun.mat.fixed.window.size$wind.text)
}
if(disp.axis == TRUE){
data.row.name <- rev(rownames(colored.mat)) # rev() because axis is added after the plot and first element is at the bottom of the braph, and not at the top like in the matrix
if(all(is.null(data.row.name))){
data.row.name <-""
}
data.col.name <- colnames(colored.mat)
if(all(is.null(data.col.name))){
data.col.name <-""
}
}else{
data.row.name <-""
data.col.name <-""
xside = 0
yside = 0
}
if(is.null(output.fun.matrix.rgb.colorization$global.dyn) & null.dyn.display == TRUE){
par(bty = "n", xaxt = "n", yaxt = "n", ann = FALSE, xpd = TRUE)
plot(1, pch = 16, col = "white", xlab = "", ylab = "")
text(x = 1, y = 1, "NULL DYNAMIC\nNO MATRIX DISPLAYED", cex = 2)
}else{
par(xaxt = "n", yaxt = "n", ann = FALSE)
if( ! all(is.null(mat.color.scale))){
layout(matrix(1:2, ncol = 2), widths = c(output.fun.mat.fixed.window.size$wind.width, output.fun.mat.fixed.window.size$scale.wind.width)) # cut the windows in two figure regions: one for the matrix and one for the scale
}else{
layout(matrix(1, ncol = 1))
}
par(mai = c(output.fun.mat.fixed.window.size$down.space, output.fun.mat.fixed.window.size$left.space, output.fun.mat.fixed.window.size$up.space, output.fun.mat.fixed.window.size$right.space), las = orient, mgp = c(dist.legend, 1, 0), xpd = FALSE, bty= box.type, cex.axis = axis.magnific, xaxs = x.adj, yaxs = y.adj, tcl = -par()$mgp[2] * tick.length) # tcl gives the length of the ticks as proportion of line text, knowing that mgp is in text lines. So the main ticks are a 0.5 of the distance of the axis numbers by default. The sign provides the side of the tick (negative for outside of the plot region)
plot(x = rep(1:ncol(colored.mat), each = nrow(colored.mat)), y = rep(1:nrow(colored.mat), ncol(colored.mat)), xlim = c(0.5, ncol(colored.mat) + 0.5), ylim = c(0.5, nrow(colored.mat) + 0.5), type = "n") # needed by rasterImage()
rasterImage(colored.mat, par()$usr[1], par()$usr[3], par()$usr[2], par()$usr[4], interpolate = FALSE) # main plot
box()
if(disp.axis == TRUE){
fun.mat.post.graph.feature(mat = colored.mat, data.row.name = data.row.name, data.col.name = data.col.name, xside = xside, yside = yside, nb.row.tick = nb.row.tick, nb.col.tick = nb.col.tick, x.nb.inter.tick = x.nb.inter.tick, y.nb.inter.tick = y.nb.inter.tick, text.corner = "", axis.magnific = axis.magnific)
}
if( ! all(is.null(mat.color.scale))){
par(xaxt = "n", yaxt = "n", ann = FALSE)
par(mai = c(output.fun.mat.fixed.window.size$scale.down.space, output.fun.mat.fixed.window.size$scale.left.space, output.fun.mat.fixed.window.size$scale.up.space, output.fun.mat.fixed.window.size$scale.right.space), las = orient.scale, mgp = c(dist.legend.scale, 1, 0), xpd = FALSE, bty= box.type.scale, cex.axis = axis.magnific.scale, xaxs = x.adj, yaxs = y.adj, tcl = -par()$mgp[2] * tick.length.scale) # tcl gives the length of the ticks as proportion of line text, knowing that mgp is in text lines. So the main ticks are a 0.5 of the distance of the axis numbers by default. The sign provides the side of the tick (negative for outside of the plot region)
plot(x = rep(1:ncol(mat.color.scale), each = nrow(mat.color.scale)), y = rep(1:nrow(mat.color.scale), ncol(mat.color.scale)), xlim = c(0.5, ncol(mat.color.scale) + 0.5), ylim = c(0.5, nrow(mat.color.scale) + 0.5), type = "n") # needed by rasterImage()
rasterImage(mat.color.scale, par()$usr[1], par()$usr[3], par()$usr[2], par()$usr[4], interpolate = FALSE) # main scale plot
box()
if(disp.axis.scale == TRUE){
data.row.name.scale <- quantile(output.fun.matrix.rgb.colorization$mat1.labels.scale, probs = seq(0, 1, length.out = nb.main.tick.scale))
if(ncol(mat.color.scale) == 1){
data.col.name.scale <-""
xside.scale = 0
}else{
data.col.name.scale <- quantile(output.fun.matrix.rgb.colorization$mat2.labels.scale, probs = seq(0, 1, length.out = nb.main.tick.scale))
}
}else{
data.row.name.scale <-""
data.col.name.scale <-""
xside.scale = 0
yside.scale = 0
}
if(ncol(mat.color.scale) == 1){
fun.mat.post.graph.feature(mat = mat.color.scale, data.row.name = data.row.name.scale, data.col.name = data.col.name.scale, xside = xside.scale, yside = yside.scale, nb.row.tick = nb.main.tick.scale, nb.col.tick = nb.main.tick.scale, x.nb.inter.tick = nb.inter.tick.scale, y.nb.inter.tick = nb.inter.tick.scale, text.corner = "", axis.magnific = axis.magnific.scale)
}else{
fun.mat.post.graph.feature(mat = mat.color.scale, data.row.name = data.col.name.scale, data.col.name = data.row.name.scale, xside = xside.scale, yside = yside.scale, nb.row.tick = nb.main.tick.scale, nb.col.tick = nb.main.tick.scale, x.nb.inter.tick = nb.inter.tick.scale, y.nb.inter.tick = nb.inter.tick.scale, text.corner = "", axis.magnific = axis.magnific.scale)
par(las = 0)
mtext(output.fun.matrix.rgb.colorization$mat1.name, side = xside.scale, cex = label.magnific.scale, line = par()$mgp[1])
mtext(output.fun.matrix.rgb.colorization$mat2.name, side = yside.scale, cex = label.magnific.scale, line = par()$mgp[1])
}
}
}
fun.axis.bg.feature(text.corner = text.corner, magnific.text.corner = magnific.text.corner)
}


################ Matrix plot (raster)


fun.colored.matrix.plot <- function(colored.mat, mat.color.scale = NULL, null.dyn.display = TRUE, disp.axis = TRUE, xside = 3, yside = 2, nb.row.tick = 0, nb.col.tick = 0, x.nb.inter.tick = 0, y.nb.inter.tick = 0, tick.length = tick.length, axis.magnific = 1.5, orient = 2, dist.legend = 2, box.type = "o", x.adj = "i", y.adj = "i", text.corner = "", magnific.text.corner = 1.5, disp.axis.scale = TRUE, xside.scale = 1, yside.scale = 2, nb.main.tick.scale = 3, nb.inter.tick.scale = 0, tick.length.scale = 0.1, orient.scale = 2, dist.legend.scale = 2, box.type.scale = "o", axis.magnific.scale = 1.5, label.magnific.scale = 1.5, output.fun.mat.window.size = output.fun.mat.window.size, output.fun.matrix.rgb.colorization = output.fun.matrix.rgb.colorization){
# amplif = 1 ; color.scale.display = TRUE ; resol.display.inch = 0.05 ; output.fun.mat.window.size <- fun.mat.window.size() ; colored.mat = output.fun.matrix.rgb.colorization$colored.mat ; mat.color.scale = output.fun.matrix.rgb.colorization$mat.color.scale ; null.dyn.display = TRUE ; disp.axis = TRUE ; xside = 3 ; yside = 2 ; nb.row.tick = nrow(colored.mat) ; nb.col.tick = ncol(colored.mat) ; x.nb.inter.tick = 0 ; y.nb.inter.tick = 0 ; tick.length = 0.5 ; axis.magnific = 1 ; orient = 2 ; dist.legend = 2 ; box.type = "o" ; axis.magnific = 1 ; x.adj = "i" ; y.adj = "i" ; text.corner = "" ; magnific.text.corner = magnific/2 ; disp.axis.scale = TRUE ; xside.scale = 1 ; yside.scale = 2 ; nb.main.tick.scale = 3 ; nb.inter.tick.scale = 0 ; tick.length.scale = 0.5 ; orient.scale = 2 ; dist.legend.scale = 2 ; box.type.scale = "o" ; axis.magnific.scale = 1 ; label.magnific.scale = 1 ; output.fun.mat.window.size = output.fun.mat.window.size ; output.fun.matrix.rgb.colorization = output.fun.matrix.rgb.colorization
# output.fun.mat.window.size <- fun.mat.window.size(dim(output.fun.matrix.rgb.colorization$colored.mat), resol.disp.inch = NULL, mat.scale.dim = dim(output.fun.matrix.rgb.colorization$mat.color.scale), scale.margin = 2, max.size = 20) ;                                   fun.open.window(pdf.disp = FALSE, path.fun = "C:/Users/Gael/Desktop", pdf.name.file = "graphs", width.fun = output.fun.mat.window.size$width.wind, height.fun = output.fun.mat.window.size$height.wind) ;             fun.colored.matrix.plot(colored.mat = output.fun.matrix.rgb.colorization$colored.mat, mat.color.scale = output.fun.matrix.rgb.colorization$mat.color.scale, null.dyn.display = TRUE, disp.axis = TRUE, xside = 3, yside = 2, nb.row.tick = nrow(output.fun.matrix.rgb.colorization$colored.mat), nb.col.tick = ncol(output.fun.matrix.rgb.colorization$colored.mat), x.nb.inter.tick = 0, y.nb.inter.tick = 0, tick.length = tick.length, axis.magnific = amplif, orient = 2, dist.legend = 2, box.type = "o", axis.magnific = amplif, x.adj = "i", y.adj = "i", text.corner = "", magnific.text.corner = magnific, disp.axis.scale = TRUE, xside.scale = 1, yside.scale = 2, nb.main.tick.scale = 3, nb.inter.tick.scale = 0, tick.length.scale = tick.length.scale, orient.scale = 2, dist.legend.scale = 2, box.type.scale = "o", axis.magnific.scale = amplif, label.magnific.scale = amplif, output.fun.mat.window.size = output.fun.mat.window.size, output.fun.matrix.rgb.colorization = output.fun.matrix.rgb.colorization)
# require fun.mat.window.size() activated first (for color.scale.display). Require also fun.matrix.rgb.colorization(), fun.mat.graph.param(), fun.mat.post.graph.feature(), fun.scale.post.graph.feature()
# ARGUMENTS:
# colored.mat: matrix of hexadecimal colors (matrix class) (provided by fun.matrix.rgb.colorization())
# mat.color.scale: matrix (1D) or matrix (2D) hexadecimal colors indicating the color scale (provided by fun.matrix.rgb.colorization()). If NULL, no scale displayed
# null.dyn.display: display something when no dynamic ?
# disp.axis: display ticks and row and column names on axis ?
# xside: x-axis at the bottom (1) or top (3) of the region figure. Write 0 if no axis required
# yside: y-axis at the left (2) or right (4) of the region figure. Write 0 if no axis required
# nb.row.tick: nb of row ticks and labels
# nb.col.tick: nb of col ticks and labels
# x.nb.inter.tick: number of secondary ticks between main ticks on x-axis (only if not log scale). Zero means non secondary ticks
# y.nb.inter.tick: number of secondary ticks between main ticks on y-axis (only if not log scale). Zero means non secondary ticks
# tick.length: length of the ticks (1 means complete the distance between the plot region and the axis numbers, 0.5 means half the length, etc. O means no ticks
# axis.magnific: increase or decrease the value to increase or decrease the size of the axis numbers
# orient: for par(las)
# dist.legend: increase the number to move axis legends away
# box.type: increase the number to move axis legends away
# axis.magnific: increase or decrease the size of the numbers in axis of the main plot
# x.adj: "i" (default) to remove the extra 4% on each side of the axes range, "r" to maintain the extra 4%
# y.adj: "i" (default) to remove the extra 4% on each side of the axes range, "r" to maintain the extra 4%
# text.corner: text to add at the top right corner of the window
# magnific.text.corner: increase or decrease the size of the text
# disp.axis.scale: display axis scale?
# yside.scale: y-axis at the left (2) or right (4) of the region figure. Write 0 if no axis required
# nb.main.tick.scale: nb of main ticks and labels
# nb.inter.tick.scale: number of secondary ticks between main ticks (only if not log scale). Zero means non secondary ticks
# tick.length.scale: length of the ticks (1 means complete the distance between the plot region and the axis numbers, 0.5 means half the length, etc. O means no ticks
# orient.scale: for par(las)
# dist.legend.scale: increase the number to move axis legends away
# box.type.scale: increase the number to move axis legends away
# axis.magnific.scale: increase or decrease the value to increase or decrease the size of the axis numbers in the scale plot
# label.magnific.scale: increase or decrease the value to increase or decrease the size of the axis legend in the scale plot (only for overlay 2D plot)
# output.fun.mat.window.size: output list of fun.mat.window.size()
# output.fun.matrix.rgb.colorization: output list of fun.matrix.rgb.colorization()
if( ! (all(is.null(colored.mat)) | (all(class(colored.mat) == "matrix") & all(typeof(colored.mat) == "character")))){
tempo.cat <- paste0("colored.mat ARGUMENT MUST BE NULL OR A CHARACTER MATRIX OF HEXADECIMAL COLORS")
stop(tempo.cat, "\n\n")
}
if( ! (all(is.null(mat.color.scale)) | (all(class(mat.color.scale) == "matrix") & all(typeof(mat.color.scale) == "character")))){
tempo.cat <- paste0("mat.color.scale ARGUMENT MUST BE A CHARACTER MATRIX OF HEXADECIMAL COLORS OR A NULL VECTOR")
stop(tempo.cat, "\n\n")
}
if(text.corner != ""){
text.corner <- paste0(text.corner, "\n", output.fun.matrix.rgb.colorization$log.txt , "\n", output.fun.mat.window.size$wind.txt)
}else{
text.corner <- paste0(output.fun.matrix.rgb.colorization$log.txt , "\n", output.fun.mat.window.size$wind.txt)
}
if(disp.axis == TRUE){
data.row.name <- rownames(colored.mat)
if(all(is.null(data.row.name))){
data.row.name <-""
}
data.col.name <- colnames(colored.mat)
if(all(is.null(data.col.name))){
data.col.name <-""
}
}else{
data.row.name <-""
data.col.name <-""
xside = 0
yside = 0
}
if(all(is.null(colored.mat)) & null.dyn.display == TRUE){
par(bty = "n", xaxt = "n", yaxt = "n", ann = FALSE, xpd = TRUE)
plot(1, pch = 16, col = "white", xlab = "", ylab = "")
text(x = 1, y = 1, "NULL DYNAMIC\nNO MATRIX DISPLAYED", cex = 2)
}else{
par(xaxt = "n", yaxt = "n", ann = FALSE)
if( ! all(is.null(mat.color.scale))){
layout(matrix(1:2, ncol = 2), widths = c(output.fun.mat.window.size$width.wind - output.fun.mat.window.size$width.wind.scale, output.fun.mat.window.size$width.wind.scale)) # cut the windows in two figure regions: one for the matrix and one for the scale
}else{
layout(matrix(1, ncol = 1))
}
par(mar = c(output.fun.mat.window.size$down.space, output.fun.mat.window.size$left.space, output.fun.mat.window.size$up.space, output.fun.mat.window.size$right.space), las = orient, mgp = c(dist.legend, 1, 0), xpd = FALSE, bty= box.type, cex.axis = axis.magnific, xaxs = x.adj, yaxs = y.adj, tcl = -par()$mgp[2] * tick.length) # tcl gives the length of the ticks as proportion of line text, knowing that mgp is in text lines. So the main ticks are a 0.5 of the distance of the axis numbers by default. The sign provides the side of the tick (negative for outside of the plot region)
plot(x = rep(1:ncol(colored.mat), each = nrow(colored.mat)), y = rep(1:nrow(colored.mat), ncol(colored.mat)), xlim = c(0.5, ncol(colored.mat) + 0.5), ylim = c(0.5, nrow(colored.mat) + 0.5), type = "n") # needed by rasterImage()
rasterImage(colored.mat, par()$usr[1], par()$usr[3], par()$usr[2], par()$usr[4], interpolate = FALSE) # main plot
box()
if(disp.axis == TRUE){
fun.mat.post.graph.feature(mat = colored.mat, data.row.name = data.row.name, data.col.name = data.col.name, xside = xside, yside = yside, nb.row.tick = nb.row.tick, nb.col.tick = nb.col.tick, x.nb.inter.tick = x.nb.inter.tick, y.nb.inter.tick = y.nb.inter.tick, text.corner = "", axis.magnific = axis.magnific)
}
if( ! all(is.null(mat.color.scale))){
par(xaxt = "n", yaxt = "n", ann = FALSE)
par(mar = c(output.fun.mat.window.size$down.space.scale, output.fun.mat.window.size$left.space.scale, output.fun.mat.window.size$up.space.scale, output.fun.mat.window.size$right.space.scale), las = orient.scale, mgp = c(dist.legend.scale, 1, 0), xpd = FALSE, bty= box.type.scale, cex.axis = axis.magnific.scale, xaxs = x.adj, yaxs = y.adj, tcl = -par()$mgp[2] * tick.length.scale) # tcl gives the length of the ticks as proportion of line text, knowing that mgp is in text lines. So the main ticks are a 0.5 of the distance of the axis numbers by default. The sign provides the side of the tick (negative for outside of the plot region)
plot(x = rep(1:ncol(mat.color.scale), each = nrow(mat.color.scale)), y = rep(1:nrow(mat.color.scale), ncol(mat.color.scale)), xlim = c(0.5, ncol(mat.color.scale) + 0.5), ylim = c(0.5, nrow(mat.color.scale) + 0.5), type = "n") # needed by rasterImage()
rasterImage(mat.color.scale, par()$usr[1], par()$usr[3], par()$usr[2], par()$usr[4], interpolate = FALSE) # main scale plot
box()
if(disp.axis.scale == TRUE){
data.row.name.scale <- quantile(output.fun.matrix.rgb.colorization$mat1.labels.scale, probs = seq(0, 1, length.out = nb.main.tick.scale))
if(ncol(mat.color.scale) == 1){
data.col.name.scale <-""
xside.scale = 0
}else{
data.col.name.scale <- quantile(output.fun.matrix.rgb.colorization$mat2.labels.scale, probs = seq(0, 1, length.out = nb.main.tick.scale))
}
}else{
data.row.name.scale <-""
data.col.name.scale <-""
xside.scale = 0
yside.scale = 0
}
if(ncol(mat.color.scale) == 1){
fun.mat.post.graph.feature(mat = mat.color.scale, data.row.name = data.row.name.scale, data.col.name = data.col.name.scale, xside = xside.scale, yside = yside.scale, nb.row.tick = nb.main.tick.scale, nb.col.tick = nb.main.tick.scale, x.nb.inter.tick = nb.inter.tick.scale, y.nb.inter.tick = nb.inter.tick.scale, text.corner = "", axis.magnific = axis.magnific.scale)
}else{
fun.mat.post.graph.feature(mat = mat.color.scale, data.row.name = data.col.name.scale, data.col.name = data.row.name.scale, xside = xside.scale, yside = yside.scale, nb.row.tick = nb.main.tick.scale, nb.col.tick = nb.main.tick.scale, x.nb.inter.tick = nb.inter.tick.scale, y.nb.inter.tick = nb.inter.tick.scale, text.corner = "", axis.magnific = axis.magnific.scale)
par(las = 0)
mtext(output.fun.matrix.rgb.colorization$mat1.name, side = xside.scale, cex = label.magnific.scale, line = par()$mgp[1])
mtext(output.fun.matrix.rgb.colorization$mat2.name, side = yside.scale, cex = label.magnific.scale, line = par()$mgp[1])
}
}
}
fun.axis.bg.feature(text.corner = text.corner, magnific.text.corner = magnific.text.corner)
}


################ Matrix plot


fun.matrix.plot <- function(mat1, mat2 = NULL, z.min1 = NULL, z.max1 = NULL, z.min2 = NULL, z.max2 = NULL, color.scale.disp = color.scale.display, scale.width = 0.25, null.dyn.display = TRUE, disp.axis.main = display.axis.main.plot, disp.axis.scale = legend.scale.display, orient = 2, dist.legend = 2, box.type = "o", amplif.label = amplif, amplif.axis = amplif, x.adj = "i", y.adj = "i", mat1.row.name = row.names(mat1), mat1.col.name = colnames(mat1), xside = 3, yside = 2, nb.row.tick = length(mat1.row.name), nb.col.tick = length(mat1.col.name), x.nb.inter.tick = 0, y.nb.inter.tick = 0, text.corner = "", magnific = amplif, magnific.text.corner = magnific, yside.scale = 4, nb.main.tick.scale = 3, y.nb.inter.tick.scale = 0, magnific.scale = amplif){
# require fun.mat.window.size() activated first (for color.scale.display). Require also fun.matrix.color(), fun.mat.graph.param(), fun.mat.post.graph.feature(), fun.scale.post.graph.feature()
# mat1: matrix that has to be colored (matrix class)
# mat2: matrix that has to be colored if overlay (matrix class). Must have same dimension, row and column names than mat1
# z.min1: add a minimal value to the dynamic scale of mat1. Beware: this rescale the dynamic & gradient colors
# z.max1: add a maximal  value to the dynamic scale of mat1. Beware: this rescale the dynamic & gradient colors
# z.min2: add a minimal value to the dynamic scale of mat2. Beware: this rescale the dynamic & gradient colors
# z.max2: add a maximal  value to the dynamic scale of mat2. Beware: this rescale the dynamic & gradient colors
# axis.disp: display axis ?
# color.scale.disp: display color scale ?
# scale.width: in inches
# null.dyn.display: display when no dynamic ?
### embedded: fun.mat.graph.param()
### disp.axis.main: display axis of main plot?
### disp.axis.scale: display axis of scale?
### orient: for par(las)
### dist.legend: increase the number to move axis legends away
### amplif.label: increase or decrease the size of the text in legends
### amplif.axis: increase or decrease the size of the numbers in axis
#### embedded: fun.mat.post.graph.feature()
#### mat1.row.name: row names of the plotted matrix
#### mat1.col.name: col names of the plotted matrix
#### xside: x-axis at the bottom (1) or top (3) of the region figure. Write 0 if no axis required
#### yside: y-axis at the left (2) or right (4) of the region figure. Write 0 if no axis required
#### nb.row.tick: nb of row ticks and labels
#### nb.col.tick: nb of col ticks and labels
#### x.nb.inter.tick: number of secondary ticks between main ticks on x-axis (only if not log scale). Zero means non secondary ticks
#### y.nb.inter.tick: number of secondary ticks between main ticks on y-axis (only if not log scale). Zero means non secondary ticks
#### text.corner: text to add at the top right corner of the window
#### magnific: increase or decrease the value to increase or decrease the size of the axis (numbers and legends)
#### magnific.text.corner: increase or decrease the size of the text
##### embedded: fun.scale.post.graph.feature()
##### yside.scale: y-axis at the left (2) or right (4) of the region figure. Write 0 if no axis required
##### nb.main.tick.scale: nb of main ticks and labels
##### x.nb.inter.tick: number of secondary ticks between main ticks on x-axis (only if not log scale). Zero means non secondary ticks
##### y.nb.inter.tick.scale: number of secondary ticks between main ticks on y-axis (only if not log scale). Zero means non secondary ticks
##### magnific.scale: increase or decrease the value to increase or decrease the size of the axis (numbers and legends)
if( ! all(class(mat1) == "matrix")){
tempo.cat <- paste0("mat1 ARGUMENT MUST BE A MATRIX")
stop(tempo.cat, "\n\n")
}
if( ! (all(is.null(mat2)) | all(class(mat2) == "matrix"))){
tempo.cat <- paste0("mat2 ARGUMENT MUST BE A MATRIX OR a NULL VECTOR")
stop(tempo.cat, "\n\n")
}
if( ! all(is.null(mat2)) & identical(dim(mat1), dim(mat2))){
tempo.cat <- paste0("DIMENSION OF mat2 ARGUMENT (", paste0(dim(mat2), collapse = " "), ") MUST BE A MATRIX OF SAME DIMENSION AS mat1 ARGUMENT (", paste0(dim(mat1), collapse = " "), ")")
stop(tempo.cat, "\n\n")
}
if( ! all(is.null(mat2)) & identical(rownames(mat1), rownames(mat2))){
tempo.cat <- paste0("ROW NAMES OF mat2 ARGUMENT (", paste0(rownames(mat2), collapse = " "), ") MUST BE IDENTICAL TO ROW NAMES OF mat1 ARGUMENT (", paste0(rownames(mat1), collapse = " "), ")")
stop(tempo.cat, "\n\n")
}
if( ! all(is.null(mat2)) & identical(colnames(mat1), colnames(mat2))){
tempo.cat <- paste0("COL NAMES OF mat2 ARGUMENT (", paste0(colnames(mat2), collapse = " "), ") MUST BE IDENTICAL TO COL NAMES OF mat1 ARGUMENT (", paste0(colnames(mat1), collapse = " "), ")")
stop(tempo.cat, "\n\n")
}
if(is.null(mat2) & ! (is.null(z.min2) & is.null(z.max2))){
tempo.cat <- paste0("z.min2 AND z.max2 ARGUMENTS MUST BE NULL IF NO mat2 ARGUMENT PROVIDED")
stop(tempo.cat, "\n\n")
}
# change the scale of the plotted matrix
text.scale.limits <- ""
if(is.null(z.min1) == TRUE){
z.min1 <- min(mat1, na.rm =TRUE) # if no z.min1 referenced, then z.min1 is min(mat1)
}else{
if(any(mat1 < z.min1, na.rm = TRUE)){
mat1[mat1 < z.min1] <- z.min1 # if values of mat1 < z.min1 then these values are truncated, meaning that now the lower scale limit is z.min1
}
text.scale.limits <- paste0("The min scale value is ", formatC(z.min1), " (for a min matrix value of ", formatC(min(mat1, na.rm =TRUE)), ")\n")
}
if(is.null(z.max) == TRUE){
z.max <- max(mat1, na.rm =TRUE)
}else{
if(any(mat1 > z.max, na.rm = TRUE)){
mat1[mat1 > z.max] <- z.max # if values of mat1 > z.max then these values are truncated, meaning that now the upper scale limit is z.max
}
text.scale.limits <- paste0(text.scale.limits, paste0("The max scale value is ", formatC(z.max), " (for a max matrix value of ", formatC(max(mat1, na.rm =TRUE)), ")\n"))
}
# end of change the scale of the plotted matrix
# fun.matrix.color(mat1 = mat1, type = type) # provide real.dyn and chip.colors but do not use here or add the color arguments
if(real.dyn == 0 & null.dyn.display == FALSE){
par(bty = "n", xaxt = "n", yaxt = "n", xpd = TRUE)
plot(1, pch = 16, col = "white", xlab = "", ylab = "")
text(x = 1, y = 1, "Null dynamic\nNo matrix displayed", cex = 2)
}else{
fun.mat.graph.param(disp.axis.main = disp.axis.main, orient = orient, dist.legend = dist.legend, box.type = box.type, amplif.label = amplif.label, amplif.axis = amplif.axis, x.adj = x.adj, y.adj = y.adj)
if(color.scale.disp == TRUE){
layout(matrix(1:2, ncol = 2), widths = c(width.wind - width.wind.scale, width.wind.scale)) # cut the windows in two figure regions: one for the matrix and one for the scale
par(mar = c(down.space, left.space, up.space, 0)) # the right margin is removed because right.space has been taken by layout for the second figure region
mat1.bis <- fun.matrix.flip(mat1)
image(x = mat1.bis, zlim = c(z.min, z.max), bty="o", col = chip.colors, useRaster = TRUE) # main plot
box()
fun.mat.post.graph.feature(data.row.name = NULL, data.col.name = NULL, xside = 0, yside = 0, text.corner = "", magnific.text.corner = magnific.text.corner) # only text corner
if(disp.axis.main == TRUE){
fun.mat.post.graph.feature(data.row.name = mat1.row.name, data.col.name = mat1.col.name, xside = xside, yside = yside, nb.row.tick = nb.row.tick, nb.col.tick = nb.col.tick, x.nb.inter.tick = x.nb.inter.tick, y.nb.inter.tick = y.nb.inter.tick, text.corner = "", axis.magnific = magnific, magnific.text.corner = magnific.text.corner) # no text corner
}
fun.mat.graph.param(disp.axis.scale = disp.axis.scale, orient = orient, dist.legend = dist.legend, box.type = box.type, amplif.label = amplif.label, amplif.axis = amplif.axis, x.adj = x.adj, y.adj = y.adj)
par(mar = c(scale.down.space, scale.left.space, scale.up.space, scale.right.space)) # margins of the scale figure region defined in fun.mat.window.size()
if(length(chip.colors) <= 500){
image(x = t(matrix(1:length(chip.colors), ncol = 1)), bty="o", col = chip.colors, useRaster = TRUE) # scale plot
box()
}else{
image(x = t(matrix(1:500, ncol = 1)), bty="n", col = chip.colors, useRaster = TRUE) # scale plot
box()
}
fun.scale.post.graph.feature(data = c(as.vector(mat1), z.min, z.max), yside.scale = 0, text.corner.scale = paste0(text.corner, text.scale.limits), magnific.text.corner.scale = magnific.text.corner)
if(disp.axis.scale == TRUE){
fun.scale.post.graph.feature(data = c(as.vector(mat1), z.min, z.max), yside.scale = yside.scale, nb.main.tick.scale = nb.main.tick.scale, y.nb.inter.tick.scale = y.nb.inter.tick.scale, magnific.axis.scale = magnific.scale)
}
}else{
mat1.bis <- fun.matrix.flip(mat1)
image(x = mat1.bis,  zlim = c(z.min, z.max), bty="o", col = chip.colors, useRaster = TRUE) # main plot
box()
fun.mat.post.graph.feature(data.row.name = NULL, data.col.name = NULL, xside = 0, yside = 0, text.corner = paste0(text.corner, text.scale.limits), magnific.text.corner = magnific.text.corner) # only text corner
if(disp.axis.main == TRUE){
fun.mat.post.graph.feature(data.row.name = mat1.row.name, data.col.name = mat1.col.name, xside = xside, yside = yside, nb.row.tick = nb.row.tick, nb.col.tick = nb.col.tick, x.nb.inter.tick = x.nb.inter.tick, y.nb.inter.tick = y.nb.inter.tick, text.corner = "", axis.magnific = magnific, magnific.text.corner = magnific.text.corner)
}
}
}
}


################ Graphical features post plotting


################ Standard plot


fun.axis.bg.feature <- function(x.side.fun = "", x.categ = NULL, x.categ.pos = NULL, x.lab.fun = "", x.dist.legend = 4.5, x.log.scale = "", x.nb.inter.tick = 1, y.side.fun = "", y.categ = NULL, y.lab.fun = "", y.dist.legend = 4.5, y.log.scale = "", y.nb.inter.tick = 1, text.angle.fun = 90, tick.length = 0.5, sec.tick.length = 0.3, bg.color = NULL, grid.lwd = NULL, grid.col = "white", text.corner = "", magnific = 1.5, magnific.text.corner = 1, par.ini.fun = FALSE, tempo.par.ini.fun = tempo.par.ini){
# AIM:
# Redesign axis. If x.side.fun = "", y.side.fun = "", just adds text at topright of the graph and reset par() and provides outputs (see below)
# REQUIRED FUNCTIONS
# require fun.graph.param() or fun.graph.param.prior.axis() for default value of tempo.par.ini.fun. Require fun.graph.param.prior.axis() for previous inactivation of the axis drawings
# ARGUMENTS
# x.side.fun: axis at the bottom (1) or top (3) of the region figure. Write "" for no change
# x.categ: classes (levels()) to specify when the x-axis is qualititative(stripchart, boxplot)
# x.categ.pos: position of the classes names (numeric vector of identical length than x.categ). If left NULL, this will be 1:length(levels())
# x.lab.fun: label of the x-axis
# x.dist.legend: increase the number to move x-axis legends away
# x.log.scale: if there is a log scale planned or not for x-axis. Use log.scale or other
# x.nb.inter.tick: number of secondary ticks between main ticks on x-axis (only if not log scale). -1 means non secondary ticks
# y.side.fun: axis at the left (2) or right (4) of the region figure. Write "" for no change
# y.categ: classes (levels()) to specify when the y-axis is qualititative(stripchart, boxplot)
# y.lab.fun: label of the y-axis
# y.dist.legend: increase the number to move y-axis legends away
# y.log.scale: if there is a log scale planned or not for y-axis. Use log.scale or other
# y.nb.inter.tick: number of secondary ticks between main ticks on y-axis (only if not log scale). -1 means non secondary ticks
# text.angle.fun: angle of the text when axis is qualitative.
# tick.length: length of the main ticks (1 means complete the distance between the plot region and the axis numbers, 0.5 means half the length, etc.
# sec.tick.length: length of the secondary ticks (1 means complete the distance between the plot region and the axis numbers, 0.5 means half the length, etc.
# bg.color: background color of the plot region. NULL for no color. BEWARE: recover an existing plot !
# grid.lwd: if non NULL, active the grid line (specify the line width)
# grid.col: grid line color (only if grid.lwd non NULL)
# text.corner: text to add at the top right corner of the window
# magnific: increase or decrease the value to increase or decrease the size of the axis (numbers and legends)
# magnific.text.corner: increase or decrease the size of the text
# par.ini.fun: to reset all the graphics parameters. BEWARE: TRUE can generates bugs, mainly in graphic devices with multiple figure regions
# tempo.par.ini.fun: to reset all the graphics parameters
# RETURN
# a list containing:: 
# $x.mid.left.fig.region: 
# $x.left.fig.region: 
# $x.mid.right.fig.region: 
# $x.right.fig.region: 
# $x.left.plot.region: 
# $x.right.plot.region: 
# $y.mid.bottom.fig.region: 
# $y.bottom.fig.region: 
# $y.mid.top.fig.region: 
# $y.top.fig.region: 
# $y.top.plot.region: 
# $y.bottom.plot.region: 
# EXAMPLES
# Example of log axis with log y-axis and unmodified x-axis: fun.axis.bg.feature(y.side.fun = 2, y.lab.fun = y.axis.legend, y.dist.legend = 3.5, y.log.scale = ylog.scale)
# Example of log axis with log y-axis and normal x-axis: fun.axis.bg.feature(x.side.fun = 1, x.categ = levels(obs2[, qual.var[1]]), text.angle.fun = text.angle, magnific = 1.5, text.corner = levels(user.data.ini[, qual.var[2]])[i], y.side.fun = 2, y.lab.fun = y.axis.legend, y.dist.legend = 3.5, y.log.scale = ylog.scale)
par(tcl = -par()$mgp[2] * tick.length)
if(x.log.scale == "x"){
grid.coord.x <- c(10^par("usr")[1], 10^par("usr")[2])
}else{
grid.coord.x <- c(par("usr")[1], par("usr")[2])
}
if(y.log.scale == "y"){
grid.coord.y <- c(10^par("usr")[3], 10^par("usr")[4])
}else{
grid.coord.y <- c(par("usr")[3], par("usr")[4])
}
if( ! is.null(bg.color)){
rect(grid.coord.x[1], grid.coord.y[1], grid.coord.x[2], grid.coord.y[2], col = bg.color, border = NA)
}
if( ! is.null(grid.lwd)){
grid(nx = NA, ny = NULL, col = grid.col, lty = 1, lwd = grid.lwd)
}
if(x.log.scale == "x"){
x.mid.left.fig.region <<- 10^(par("usr")[1] - ((par("usr")[2] -  par("usr")[1]) / (par("plt")[2] - par("plt")[1])) * par("plt")[1] / 2) # in x coordinates, to position axis labeling at the bottom of the graph (according to x scale)
x.left.fig.region <<- 10^(par("usr")[1] - ((par("usr")[2] -  par("usr")[1]) / (par("plt")[2] - par("plt")[1])) * par("plt")[1]) # in x coordinates
x.mid.right.fig.region <<- 10^(par("usr")[2] + ((par("usr")[2] -  par("usr")[1]) / (par("plt")[2] - par("plt")[1])) * (1 - par("plt")[2]) / 2) # in x coordinates, to position axis labeling at the top of the graph (according to x scale)
x.right.fig.region <<- 10^(par("usr")[2] + ((par("usr")[2] -  par("usr")[1]) / (par("plt")[2] - par("plt")[1])) * (1 - par("plt")[2])) # in x coordinates
x.left.plot.region <<- 10^par("usr")[1] # in x coordinates, left of the plot region (according to x scale)
x.right.plot.region <<- 10^par("usr")[2] # in x coordinates, right of the plot region (according to x scale)
x.mid.plot.region <<- 10^((par("usr")[2] + par("usr")[1]) / 2) # in x coordinates, right of the plot region (according to x scale)
}else{
x.mid.left.fig.region <<- (par("usr")[1] - ((par("usr")[2] -  par("usr")[1]) / (par("plt")[2] - par("plt")[1])) * par("plt")[1] / 2) # in x coordinates, to position axis labeling at the bottom of the graph (according to x scale)
x.left.fig.region <<- (par("usr")[1] - ((par("usr")[2] -  par("usr")[1]) / (par("plt")[2] - par("plt")[1])) * par("plt")[1]) # in x coordinates
x.mid.right.fig.region <<- (par("usr")[2] + ((par("usr")[2] -  par("usr")[1]) / (par("plt")[2] - par("plt")[1])) * (1 - par("plt")[2]) / 2) # in x coordinates, to position axis labeling at the top of the graph (according to x scale)
x.right.fig.region <<- (par("usr")[2] + ((par("usr")[2] -  par("usr")[1]) / (par("plt")[2] - par("plt")[1])) * (1 - par("plt")[2])) # in x coordinates
x.left.plot.region <<- par("usr")[1] # in x coordinates, left of the plot region (according to x scale)
x.right.plot.region <<- par("usr")[2] # in x coordinates, right of the plot region (according to x scale)
x.mid.plot.region <<- (par("usr")[2] + par("usr")[1]) / 2 # in x coordinates, right of the plot region (according to x scale)
}
if(y.log.scale == "y"){
y.mid.bottom.fig.region <<- 10^(par("usr")[3] - ((par("usr")[4] -  par("usr")[3]) / (par("plt")[4] - par("plt")[3])) * par("plt")[3] / 2) # in y coordinates, to position axis labeling at the bottom of the graph (according to y scale). Ex mid.bottom.space
y.bottom.fig.region <<- 10^(par("usr")[3] - ((par("usr")[4] -  par("usr")[3]) / (par("plt")[4] - par("plt")[3])) * par("plt")[3]) # in y coordinates
y.mid.top.fig.region <<- 10^(par("usr")[4] + ((par("usr")[4] -  par("usr")[3]) / (par("plt")[4] - par("plt")[3])) * (1 - par("plt")[4]) / 2) # in y coordinates, to position axis labeling at the top of the graph (according to y scale). Ex mid.top.space
y.top.fig.region <<- 10^(par("usr")[4] + ((par("usr")[4] -  par("usr")[3]) / (par("plt")[4] - par("plt")[3])) * (1 - par("plt")[4])) # in y coordinates
y.top.plot.region <<- 10^par("usr")[4] # in y coordinates, top of the plot region (according to y scale)
y.bottom.plot.region <<- 10^par("usr")[3] # in y coordinates, bottom of the plot region (according to y scale)
y.mid.plot.region <<- (par("usr")[3] + par("usr")[4]) / 2 # in x coordinates, right of the plot region (according to x scale)
}else{
y.mid.bottom.fig.region <<- (par("usr")[3] - ((par("usr")[4] -  par("usr")[3]) / (par("plt")[4] - par("plt")[3])) * par("plt")[3] / 2) # in y coordinates, to position axis labeling at the bottom of the graph (according to y scale). Ex mid.bottom.space
y.bottom.fig.region <<- (par("usr")[3] - ((par("usr")[4] -  par("usr")[3]) / (par("plt")[4] - par("plt")[3])) * par("plt")[3]) # in y coordinates
y.mid.top.fig.region <<- (par("usr")[4] + ((par("usr")[4] -  par("usr")[3]) / (par("plt")[4] - par("plt")[3])) * (1 - par("plt")[4]) / 2) # in y coordinates, to position axis labeling at the top of the graph (according to y scale). Ex mid.top.space
y.top.fig.region <<- (par("usr")[4] + ((par("usr")[4] -  par("usr")[3]) / (par("plt")[4] - par("plt")[3])) * (1 - par("plt")[4])) # in y coordinates
y.top.plot.region <<- par("usr")[4] # in y coordinates, top of the plot region (according to y scale)
y.bottom.plot.region <<- par("usr")[3] # in y coordinates, bottom of the plot region (according to y scale)
y.mid.plot.region <<- 10^((par("usr")[3] + par("usr")[4]) / 2) # in x coordinates, right of the plot region (according to x scale)
}
if(x.side.fun == 1 | x.side.fun == 3){
par(xpd=FALSE, xaxt="s")
if(is.null(x.categ) & x.log.scale == "x"){
if(any(par()$xaxp[1:2] == 0)){
if(par()$xaxp[1] == 0){
par(xaxp = c(10^-30, par()$xaxp[2:3])) # because log10(par()$xaxp[1] == 0) == -Inf
}
if(par()$xaxp[2] == 0){
par(xaxp = c(par()$xaxp[1], 10^-30, par()$xaxp[3])) # because log10(par()$xaxp[2] == 0) == -Inf
}
}
axis(side=x.side.fun, at=c(10^par()$usr[1], 10^par()$usr[2]), labels=rep("", 2), lwd=1, lwd.ticks=0) # draw the axis line
mtext(side = x.side.fun, text = x.lab.fun, line = x.dist.legend, las = 0, cex = magnific)
par(tcl = -par()$mgp[2] * sec.tick.length) # length of the secondary ticks are reduced
suppressWarnings(rug(10^outer(c((log10(par("xaxp")[1]) -1):log10(par("xaxp")[2])), log10(1:10), "+"), ticksize = NA, side = x.side.fun)) # ticksize = NA to allow the use of par()$tcl value
par(tcl = -par()$mgp[2] * tick.length) # back to main ticks
axis(side = x.side.fun, at = c(1e-15, 1e-14, 1e-13, 1e-12, 1e-11, 1e-10, 1e-9, 1e-8, 1e-7, 1e-6, 1e-5, 1e-4, 1e-3, 1e-2, 1e-1, 1e0, 1e1, 1e2, 1e3, 1e4, 1e5, 1e6, 1e7, 1e8, 1e9, 1e10), labels = expression(10^-15, 10^-14, 10^-13, 10^-12, 10^-11, 10^-10, 10^-9, 10^-8, 10^-7, 10^-6, 10^-5, 10^-4, 10^-3, 10^-2, 10^-1, 10^0, 10^1, 10^2, 10^3, 10^4, 10^5, 10^6, 10^7, 10^8, 10^9, 10^10), lwd = 0, lwd.ticks = 1, cex.axis = magnific)
x.text <- 10^par("usr")[2]
}else if(is.null(x.categ) & x.log.scale == ""){
axis(side=x.side.fun, at=c(par()$usr[1], par()$usr[2]), labels=rep("", 2), lwd=1, lwd.ticks=0) # draw the axis line
axis(side=x.side.fun, at=round(seq(par()$xaxp[1], par()$xaxp[2], length.out=par()$xaxp[3]+1), 2))
mtext(side = x.side.fun, text = x.lab.fun, line = x.dist.legend, las = 0, cex = magnific)
if(x.nb.inter.tick > 0){
inter.tick.unit <- (par("xaxp")[2] - par("xaxp")[1]) / par("xaxp")[3]
par(tcl = -par()$mgp[2] * sec.tick.length) # length of the ticks are reduced
suppressWarnings(rug(seq(par("xaxp")[1] - 10 * inter.tick.unit, par("xaxp")[2] + 10 * inter.tick.unit, by = inter.tick.unit / (1 + x.nb.inter.tick)), ticksize = NA, x.side.fun)) # ticksize = NA to allow the use of par()$tcl value
par(tcl = -par()$mgp[2] * tick.length) # back to main ticks
}
x.text <- par("usr")[2]
}else if(( ! is.null(x.categ)) & x.log.scale == ""){
if(is.null(x.categ.pos)){
x.categ.pos <- 1:length(x.categ)
}else if(length(x.categ.pos) != length(x.categ)){
stop("\n\nPROBLEM: x.categ.pos MUST BE THE SAME LENGTH AS x.categ\n\n")
}
par(xpd = TRUE)
if(x.side.fun == 1){
segments(x0 = x.left.plot.region, x1 = x.right.plot.region, y0 = y.bottom.plot.region, y1 = y.bottom.plot.region) # draw the line of the axis
text(x = x.categ.pos, y = y.mid.bottom.fig.region, labels = x.categ, srt = text.angle.fun, cex = magnific)
}else if(x.side.fun == 3){
segments(x0 = x.left.plot.region, x1 = x.right.plot.region, y0 = y.top.plot.region, y1 = y.top.plot.region) # draw the line of the axis
text(x = x.categ.pos, y = y.mid.top.fig.region, labels = x.categ, srt = text.angle.fun, cex = magnific)
}else{
stop("\n\nARGUMENT x.side.fun CAN ONLY BE 1 OR 3\n\n")
}
par(xpd = FALSE)
x.text <- par("usr")[2]
}else{
stop("\n\nPROBLEM WITH THE x.side.fun (", x.side.fun ,") OR x.log.scale (", x.log.scale,") ARGUMENTS\n\n")
}
}else{
x.text <- par("usr")[2]
}
if(y.side.fun == 2 | y.side.fun == 4){
par(xpd=FALSE, yaxt="s")
if(is.null(y.categ) & y.log.scale == "y"){
if(any(par()$yaxp[1:2] == 0)){
if(par()$yaxp[1] == 0){
par(yaxp = c(10^-30, par()$yaxp[2:3])) # because log10(par()$yaxp[1] == 0) == -Inf
}
if(par()$yaxp[2] == 0){
par(yaxp = c(par()$yaxp[1], 10^-30, par()$yaxp[3])) # because log10(par()$yaxp[2] == 0) == -Inf
}
}
axis(side=y.side.fun, at=c(10^par()$usr[3], 10^par()$usr[4]), labels=rep("", 2), lwd=1, lwd.ticks=0) # draw the axis line
mtext(side = y.side.fun, text = y.lab.fun, line = y.dist.legend, las = 0, cex = magnific)
par(tcl = -par()$mgp[2] * sec.tick.length) # length of the ticks are reduced
suppressWarnings(rug(10^outer(c((log10(par("yaxp")[1])-1):log10(par("yaxp")[2])), log10(1:10), "+"), ticksize = NA, side = y.side.fun)) # ticksize = NA to allow the use of par()$tcl value
par(tcl = -par()$mgp[2] * tick.length) # back to main tick length
axis(side = y.side.fun, at = c(1e-15, 1e-14, 1e-13, 1e-12, 1e-11, 1e-10, 1e-9, 1e-8, 1e-7, 1e-6, 1e-5, 1e-4, 1e-3, 1e-2, 1e-1, 1e0, 1e1, 1e2, 1e3, 1e4, 1e5, 1e6, 1e7, 1e8, 1e9, 1e10), labels = expression(10^-15, 10^-14, 10^-13, 10^-12, 10^-11, 10^-10, 10^-9, 10^-8, 10^-7, 10^-6, 10^-5, 10^-4, 10^-3, 10^-2, 10^-1, 10^0, 10^1, 10^2, 10^3, 10^4, 10^5, 10^6, 10^7, 10^8, 10^9, 10^10), lwd = 0, lwd.ticks = 1, cex.axis = magnific)
y.text <- 10^(par("usr")[4] + (par("usr")[4] -  par("usr")[3]) / (par("plt")[4] - par("plt")[3]) * (1 - par("plt")[4]))
mtext(side = y.side.fun, text = y.lab.fun, line = y.dist.legend, las = 0, cex = magnific)
}else if(is.null(y.categ) & y.log.scale == ""){
axis(side=y.side.fun, at=c(par()$usr[3], par()$usr[4]), labels=rep("", 2), lwd=1, lwd.ticks=0) # draw the axis line
axis(side=y.side.fun, at=round(seq(par()$yaxp[1], par()$yaxp[2], length.out=par()$yaxp[3]+1), 2))
mtext(side = y.side.fun, text = y.lab.fun, line = y.dist.legend, las = 0, cex = magnific)
if(y.nb.inter.tick > 0){
inter.tick.unit <- (par("yaxp")[2] - par("yaxp")[1]) / par("yaxp")[3]
par(tcl = -par()$mgp[2] * sec.tick.length) # length of the ticks are reduced
suppressWarnings(rug(seq(par("yaxp")[1] - 10 * inter.tick.unit, par("yaxp")[2] + 10 * inter.tick.unit, by =  inter.tick.unit / (1 + y.nb.inter.tick)), ticksize = NA, side=y.side.fun)) # ticksize = NA to allow the use of par()$tcl value
par(tcl = -par()$mgp[2] * tick.length) # back to main tick length
}
y.text <- (par("usr")[4] + (par("usr")[4] -  par("usr")[3]) / (par("plt")[4] - par("plt")[3]) * (1 - par("plt")[4]))
}else if(( ! is.null(y.categ)) & y.log.scale == ""){
axis(side = y.side.fun, at = 1:length(y.categ), labels = rep("", length(y.categ)), lwd=0, lwd.ticks=1) # draw the line of the axis
par(xpd = TRUE)
if(y.side.fun == 2){
text(x = x.mid.left.fig.region, y = (1:length(y.categ)), labels = y.categ, srt = text.angle.fun, cex = magnific)
}else if(y.side.fun == 4){
text(x = x.mid.right.fig.region, y = (1:length(y.categ)), labels = y.categ, srt = text.angle.fun, cex = magnific)
}else{
stop("\n\nARGUMENT y.side.fun CAN ONLY BE 2 OR 4\n\n")
}
par(xpd = FALSE)
y.text <- (par("usr")[4] + (par("usr")[4] -  par("usr")[3]) / (par("plt")[4] - par("plt")[3]) * (1 - par("plt")[4]))
}else{
stop("\n\nPROBLEM WITH THE y.side.fun (", y.side.fun ,") OR y.log.scale (", y.log.scale,") ARGUMENTS\n\n")
}
}else{
y.text <- (par("usr")[4] + (par("usr")[4] -  par("usr")[3]) / (par("plt")[4] - par("plt")[3]) * (1 - par("plt")[4]))
}
par(xpd=NA)
text(x = x.mid.right.fig.region, y = y.text, text.corner, adj=c(1, 1.1), cex = magnific.text.corner) # text at the topright corner. Replace x.right.fig.region by x.text if text at the right edge of the plot region
par(xpd=FALSE)
if(par.ini.fun == TRUE){
par(tempo.par.ini.fun)
}
}


################ Matrix plot


fun.mat.post.graph.feature <- function(mat, data.row.name, data.col.name, xside = 3, yside = 4, nb.row.tick = length(data.row.name), nb.col.tick = length(data.col.name), x.nb.inter.tick = 0, y.nb.inter.tick = 0, text.corner = "", axis.magnific = 1.5, magnific.text.corner = 1){
# mat = mat.color.scale ; data.row.name = data.row.name.scale ; data.col.name = data.col.name.scale ; xside = xside.scale ; yside = yside.scale ; nb.row.tick = nb.main.tick.scale ; nb.col.tick = nb.main.tick.scale ; x.nb.inter.tick = nb.inter.tick.scale ; y.nb.inter.tick = nb.inter.tick.scale ; text.corner = text.corner ; magnific = magnific ; magnific.text.corner = magnific.text.corner

# mat: plotted matrix
# data.row.name: row names of the plotted matrix
# data.col.name: col names of the plotted matrix
# xside: x-axis at the bottom (1) or top (3) of the region figure. Write 0 if no axis required
# yside: y-axis at the left (2) or right (4) of the region figure. Write 0 if no axis required
# nb.row.tick: nb of row ticks and labels
# nb.col.tick: nb of col ticks and labels
# x.nb.inter.tick: number of secondary ticks between main ticks on x-axis (only if not log scale). Zero means non secondary ticks
# y.nb.inter.tick: number of secondary ticks between main ticks on y-axis (only if not log scale). Zero means non secondary ticks
# text.corner: text to add at the top right corner of the window
# axis.magnific: increase or decrease the value to increase or decrease the size of the axis (numbers)
# magnific.text.corner: increase or decrease the size of the text
tempo.par.ini <- par()[c("xpd", "xaxt", "xaxp", "yaxt", "yaxp")] # local
# middle of margins and top figure region
par(tcl = -par()$mgp[2] * 0.5)
par(xpd=FALSE)
mid.left.space <<- (par("usr")[1] - ((par("usr")[2] -  par("usr")[1]) / (par("plt")[2] - par("plt")[1])) * par("plt")[1] / 2) # to position axis labeling at the left of the graph (according to x scale)
mid.right.space <<- (par("usr")[2] + ((par("usr")[2] -  par("usr")[1]) / (par("plt")[2] - par("plt")[1])) * par("plt")[1] / 2) # to position axis labeling at the right of the graph (according to x scale)
mid.bottom.space <<- (par("usr")[3] - ((par("usr")[4] -  par("usr")[3]) / (par("plt")[4] - par("plt")[3])) * par("plt")[3] / 2) # to position axis labeling at the bottom of the graph (according to y scale)
mid.top.space <<- (par("usr")[4] + ((par("usr")[4] -  par("usr")[3]) / (par("plt")[4] - par("plt")[3])) * par("plt")[3] / 2) # to position axis labeling at the top of the graph (according to y scale)
top.plot.region <<- par("usr")[4] # top of the region figure (according to y scale)
# x
if(xside != 0){
if(par()$xaxt != "n"){
tempo.cat <- paste0("CANNOT ADD X-AXIS IF par()$xaxt != \"n\"")
stop(tempo.cat, "\n\n")
}else{
par(xaxt = "s")
axis(side = xside, at = seq(1, ncol(mat), length.out = nb.col.tick), labels=data.col.name[quantile(1:length(data.col.name), probs = seq(0, 1, length.out = nb.col.tick), na.rm = TRUE)], lwd=1, lwd.ticks=1, cex.axis = axis.magnific)
if(x.nb.inter.tick > 0){
inter.tick.unit <- (par("xaxp")[2] - par("xaxp")[1]) / par("xaxp")[3]
suppressWarnings(rug(seq(par("xaxp")[1] - 10 * inter.tick.unit, par("xaxp")[2] + 10 * inter.tick.unit, by = inter.tick.unit / (1 + x.nb.inter.tick)), ticksize = par()$tck*2/3, xside))
}
}
}
x.text <- par("usr")[2] + (par("usr")[2] -  par("usr")[1]) / (par("plt")[2] - par("plt")[1]) * (1 - par("plt")[2])
# y
if(yside != 0){
if(par()$yaxt != "n"){
tempo.cat <- paste0("CANNOT ADD Y-AXIS IF par()$yaxt != \"n\"")
stop(tempo.cat, "\n\n")
}else{
par(yaxt = "s", xpd = NA)
axis(side = yside, at = seq(1, nrow(mat), length.out = nb.row.tick), labels = data.row.name[quantile(1:length(data.row.name), probs = seq(0, 1, length.out = nb.row.tick), na.rm = TRUE)], lwd=1, lwd.ticks=1, cex.axis = axis.magnific) # rev() because we have set a negative diagonal for matrix display (best contact from topleft to bottomright)
par(xpd = FALSE)
if(y.nb.inter.tick > 0){
inter.tick.unit <- (par("yaxp")[2] - par("yaxp")[1]) / par("yaxp")[3]
suppressWarnings(rug(seq(par("yaxp")[1] - 10 * inter.tick.unit, par("yaxp")[2] + 10 * inter.tick.unit, by =  inter.tick.unit / (1 + y.nb.inter.tick)), ticksize = par()$tck*2/3, side=yside))
}
}
}
y.text <- (par("usr")[4] + (par("usr")[4] -  par("usr")[3]) / (par("plt")[4] - par("plt")[3]) * (1 - par("plt")[4]))
# corner text
par(xpd=NA)
text(x = x.text, y = y.text, text.corner, adj=c(1, 1.1), cex = magnific.text.corner) # text at the topright corner
par(tempo.par.ini)
rm(tempo.par.ini)
}


################ Matrix scale post plotting


fun.scale.post.graph.feature <- function(data, yside.scale = 4, nb.main.tick.scale = 3, y.nb.inter.tick.scale = 0, magnific.axis.scale = 1.5, text.corner.scale = "", magnific.text.corner.scale = 1){
# data: plotted matrix (to recover values for the scale)
# yside.scale: y-axis at the left (2) or right (4) of the region figure. Write 0 if no axis required
# nb.main.tick.scale: nb of main ticks and labels
# x.nb.inter.tick: number of secondary ticks between main ticks on x-axis (only if not log scale). Zero means non secondary ticks
# y.nb.inter.tick.scale: number of secondary ticks between main ticks on y-axis (only if not log scale). Zero means non secondary ticks
# magnific.axis.scale: increase or decrease the value to increase or decrease the size of the axis (numbers and legends)
# text.corner.scale: text to add at the top right corner of the window
# magnific.text.corner.scale: increase or decrease the size of the text
tempo.par.ini <- par()[c("xpd", "xaxt", "xaxp", "yaxt", "yaxp")] # local
par(xpd=FALSE)
if(yside.scale != 0){
if(par()$yaxt != "n"){
tempo.cat <- paste0("CANNOT ADD Y-AXIS IF par()$yaxt != \"n\"")
stop(tempo.cat, "\n\n")
}else{
par(yaxt = "s")
if(length(unique(as.vector(data))) == 1){ # deal with 1 case matrix because axis is between -1 and 1 in that case and because only one number required
nb.main.tick.scale <- 1
axis(side = yside.scale , at = 0, labels = formatC(unique(as.vector(data))), lwd=1, lwd.ticks=1, cex.axis = magnific.axis.scale)
}else{
axis(side = yside.scale , at = seq(0, 1, length.out = nb.main.tick.scale), labels = formatC(seq(min(data, na.rm = TRUE), max(data, na.rm = TRUE), length.out = nb.main.tick.scale)), lwd=1, lwd.ticks=1, cex.axis = magnific.axis.scale)
}
if(y.nb.inter.tick.scale > 0){
inter.tick.unit <- (par("yaxp")[2] - par("yaxp")[1]) / par("yaxp")[3]
suppressWarnings(rug(seq(par("yaxp")[1] - 10 * inter.tick.unit, par("yaxp")[2] + 10 * inter.tick.unit, by =  inter.tick.unit / (1 + y.nb.inter.tick.scale)), ticksize = par()$tck*2/3, side=2))
}
}
}
box()
x.text <- par("usr")[2]
y.text <- (par("usr")[4] + (par("usr")[4] -  par("usr")[3]) / (par("plt")[4] - par("plt")[3]) * (1 - par("plt")[4]))
# corner text
par(xpd=NA)
text(x = x.text, y = y.text, text.corner.scale, adj=c(1, 1.1), cex = magnific.text.corner.scale) # text at the topright corner
par(tempo.par.ini)
rm(tempo.par.ini)
}


################ Closing all the pdf files (but not the R windows)


fun.close.pdf <- function(){
# Close only the opened pdf windows
if(length(dev.list()) != 0){
for(i in length(names(dev.list())):1){
if(names(dev.list())[i] == "pdf"){
dev.off(dev.list()[i])
}
}
}
}


################ Colors of the variant names in the stripcharts and boxplots


fun.color.name <- function(categ, col.wt.reference = "black", col.other.reference = hsv(20/24, 1, 0.75), col.pathogenic = hsv(0, 1, 1), col.neutral = hsv(13/24, 1, 0.9), col.UV = hsv(0, 0, 0.6)){
# categ: write the levels of the variants (levels(user.data.norm$Name) or levels(res.tot$Variant)
# col.wt.reference: color of the reference.column
# col.other.reference: color of Other.reference
# col.pathogenic: color of the pathogenic variants (red by default)
# col.neutral: color of the neutral variants (blue by default)
# col.UV: color of the UV (grey by default)
# output: color.name.water
color.name.water <<- vector("character", length(categ))
color.name.water[categ %in% reference.column] <<- col.wt.reference
if(all(Other.reference != "NO")){
color.name.water[categ %in% Other.reference] <<- col.other.reference
}
color.name.water[categ %in% Pathogenic] <<- col.pathogenic
color.name.water[categ %in% Neutral] <<- col.neutral
if(all(UV != "NO")){
color.name.water[categ %in% UV] <<- col.UV
}
}


################ Stripcharts in waterfall


fun.stripchart <- function(data1 = output.fun.ordering.waterfall, data2 = NULL, shift = data.shift, central = central.param.displayed, categ.nb = length(output.fun.ordering.waterfall), categ.name = names(output.fun.ordering.waterfall), text.corner.f = ""){
# require fun.color.name() activated first to get color.name.water
# embedded: fun.post.graph.feature() which uses the text.corner.f argument
# data1: a list of values to be plotted. Either splitted user.data.norm.ini or output.fun.ordering.waterfall (default) provided by fun.ordering.waterfall(). The variant order is the same as in the list
# data2: an optional reduced list of the values to be added in the plot
# shift: an optional number that shift data1 on the left and data2 on the rigth (unit of the x-axis)
# central: either median or mean of the data1 displayed (grey horizontal segment)
# categ.nb: number of categories displayed
# categ.name: name of the categories displayed
# text.corner.f: name of the categories displayed
if(!is.null(data2)){
jit <- 0
}else{
shift <- 0
}
par(xaxt="n", xaxs="i")
stripchart(at = (1:categ.nb) - shift, data1, vertical = TRUE, method = "jitter", jitter = jit, xlim = range(range.min, range.max), xlab = names(obs2)[2], ylab = names(obs2)[1], log = ylog.scale, pch = 1, cex = pt.cex.strip)
if(!is.null(data2)){
stripchart(at = (1:categ.nb) + shift, data2, vertical = TRUE,  add = TRUE, col = "red", log = ylog.scale,  pch = 1, cex = pt.cex.strip)
}
m <- sapply(data1, central)
l.seg <- 0.3
segments((1:categ.nb)- l.seg, m, (1:categ.nb)+ l.seg, m, lwd=4, col=gray(0.4)) # draw medians or means of variants
par(xaxt = "s", xpd = TRUE)
axis(side = 1, at = 1:length(m), labels = rep("", length(m)), lwd = 0, lwd.ticks = 1)
par(xpd = FALSE, yaxt = "s")
segments(range.min, m[1], range.max, m[1], lty="44") # draw the WT median or mean
fun.post.graph.feature(ylog.scale = ylog.scale, x.nb.inter.tick = -1, text.corner = text.corner.f)
par(xpd=TRUE)
text(x = (1:categ.nb), y = y.mid.bottom.fig.region, labels = categ.name, col = color.name.water, srt = text.angle, cex = amplif)
if(!is.null(data2)){
m2 <- sapply(data2, central)
segments((1:categ.nb)- l.seg, m2, (1:categ.nb)+ l.seg, m2, lwd=3, col="red") # draw medians or means of reduced variants
legend("topleft", inset=c(0, -(1 - par("plt")[4]) / (par("plt")[4] - par("plt")[3])), legend = c("Initial", "Reduced"), yjust = 0.5, pch=c(1, 1), col=c("black", "red"), bty="n", cex = amplif, pt.cex = 2, y.intersp=1.25)
}
par(xpd = FALSE)
}


################ iteration plotting


fun.iteration.plot <- function(rowsum.data, colsum.data, quantile.iter.f, down.space = 3, left.space = 3.5, up.space = 4, right.space = 1, orient = 1, dist.legend = 2, box.type = "l", tick.length = 0.5, amplif.label = 1, amplif.axis = 1, amplif.legend = 1, x.adj = "i", y.adj = "i", magnific.text.corner = 1, opt.text = ""){
# AIM:
# plot 2 graphs: iteration for rows and columns. In each graph, the quantiles of the rowsum (colsum) distributions are plotted for each step 
# REQUIRED FUNCTIONS
# none
# fun.graph.param() can not be used prior to this function for par() because of layout()
# ARGUMENTS
# rowsum.data: dataframe of iteration results obtained on row sums (iteration number as column 1 and quantiles.iter as quantiles)
# colsum.data: dataframe of iteration results obtained on col sums (iteration number as column 1 and quantiles.iter as quantiles)
# quantile.iter.f: quantiles set in quantile.iter
# up.space: upper vertical margin between plot region and grapical window defined by par(mar)
# down.space: lower vertical margin
# left.space: lower vertical margin
# right.space: lower vertical margin
# orient: for par(las)
# dist.legend: increase the number to move axis legends away
# box.type: see par()$bty
# tick.length: length of the ticks (1 means complete the distance between the plot region and the axis numbers, 0.5 means half the length, etc.
# amplif.label: increase or decrease the size of the text in legends
# amplif.axis: increase or decrease the size of the numbers in axis
# amplif.legend: increase or decrease the size of the legend characters
# x.adj: remove (i) or not (r) the 4% sup margin in x-axis
# y.adj: remove (i) or not (r) the 4% sup margin in y-axis
# magnific.text.corner: increase or decrease the size of the text
# opt.text.corner: optional text to add in corner text
# RETURN
# nothing returned
# EXAMPLES
# 
zone<-matrix(1:2, ncol=2)
layout(zone)
par( mar = c(down.space, left.space, up.space, right.space), las = orient, mgp = c(dist.legend, 1, 0), xpd = FALSE, bty= box.type, cex.lab = amplif.label, cex.axis = amplif.axis, xaxs = x.adj, yaxs = y.adj)
par(tcl = -par()$mgp[2] * tick.length) # tcl gives the length of the ticks as proportion of line text, knowing that mgp is in text lines. So the main ticks are a 0.5 of the distance of the axis numbers by default. The sign provides the side of the tick (negative for outside of the plot region)
for(z in c("rowsum.data", "colsum.data")){
tempo1 <- get(z)
plot(tempo1[, 1], tempo1[, 5], type="n", ylim = range(tempo1[, 2:(length(quantile.iter.f) + 1)]), xlab="Iteration", ylab="Distribution of Sum", col="red", lwd=2)
nb.areas <- (length(quantile.iter.f) - 1) / 2
for(h in 1:nb.areas){ # Beware: h takes values 1:3 if 7 quantiles but the coordinates in the matrix starts at col 2 to 8
polygon(c(tempo1[, 1], rev(tempo1[, 1])), c(tempo1[, h + 1], rev(tempo1[, length(quantile.iter.f) + 2 - h])), density = NA, border = NA, col = hsv(0, 0 + h / 10, 1))
}
lines(tempo1[, 1], tempo1[, nb.areas + 2], type="l", col="red", lwd=2) # +2 because 1 for the iteration column and 1 to reach the median
x.text <- par("usr")[2] + (par("usr")[2] -  par("usr")[1]) / (par("plt")[2] - par("plt")[1]) * (1 - par("plt")[2]) / 2
y.text <- (par("usr")[4] + (par("usr")[4] -  par("usr")[3]) / (par("plt")[4] - par("plt")[3]) * (1 - par("plt")[4]))
if(z == "rowsum.data"){
text.corner <- "ROW"
}else{
if(opt.text == ""){
text.corner <- paste0("COLUMN\nNull sums removed\nQuantiles ", paste(quantile.iter.f, collapse = ", "))
}else{
text.corner <- paste0("COLUMN\n", opt.text, "\nNull sums removed\nQuantiles ", paste(quantile.iter.f, collapse = ", "))
}
text.legend <- paste(colnames(tempo1)[2:(length(quantile.iter.f) + 1)], rev(colnames(tempo1)[2:(length(quantile.iter.f) + 1)]), sep = "-")[1:nb.areas]
legend("topright", legend = c("Median", text.legend), xjust = 1, yjust = 1, pch = c(NA, rep(15, nb.areas)), lty = c(1, rep(NA, nb.areas)), col = c("red", hsv(0, 0 + (1:nb.areas) / 10, 1)), bty="n", cex = amplif.legend, pt.cex = 1.25)
}
par(xpd = FALSE)
abline(v = par()$usr[1])
par(xpd=NA)
text(x = x.text, y = y.text, text.corner, adj = c(1, 1.2), cex = magnific.text.corner) # text at the topright corner, adj = c(1, 1) for right and top justification
}
}


################ stat plotting



fun.stat.plot <- function(data, displayed.nb = NULL, method.f = "", trim.dist.f = c(0.05, 0.975), down.space = 3, left.space = 3.5, up.space = 2, right.space = 1, orient = 1, dist.legend = 1.5, box.type = "l", amplif.label = 1, amplif.axis = 1, x.adj = "i", y.adj = "i", cex.pt = 0.5, col.box = hsv(0.55, 0.8, 0.8), x.nb.inter.tick = 4, y.nb.inter.tick = 0, tick.length = 0.5, text.corner = "", amplif.legend = 1, magnific.text.corner = 1, interval.disp = TRUE){
# AIM:
# plot 2 graphs: iteration for rows and columns. In each graph, the quantiles of the rowsum (colsum) distributions are plotted for each step 
# REQUIRED FUNCTIONS
# none
# require fun.mat.window.size() activated first (for color.scale.display)
# ARGUMENTS
# data: values to plot (either sum of row or col for raw matrices or p values for comparison matrix)
# displayed.nb: number of values displayed. If NULL, all the values are displayed. Otherwise, displayed.nb values are randomly selected for the display
# method.f: display the selected cutoffs for trimming. Write "" if not required. write "mean.sd" if mean +/- sd are required (BEWARE: only for normal distribution). Write "quantile" if trimming is based on quantile cut-offs. No other possibility allowed
# trim.dist.f: display the selected cutoffs for trimming. Write "" if not required. Use a couple of values c(lower, upper) indicating the lower and upper interval, which represent the interval of distribution kept (between 0 and 1). Exmaple: trim.dist.f = c(0.05, 0.975). What is strictly kept is ]lower , upper[, boundaries excluded. Using the "mean.sd" method, 0.025 and 0.975 represent 95% CI which is mean +/- 1.96 * sd
# up.space: upper vertical margin between plot region and grapical window defined by par(mar)
# down.space: lower vertical margin
# left.space: lower vertical margin
# right.space: lower vertical margin
# orient: for par(las)
# dist.legend: increase the number to move axis legends away
# amplif.label: increase or decrease the size of the text in legends
# amplif.axis: increase or decrease the size of the numbers in axis
# x.adj: remove (i) or not (r) the 4% sup margin in x-axis
# y.adj: remove (i) or not (r) the 4% sup margin in y-axis
# cex.pt: size of points in stripcharts
# col.box: color of boxplot
# x.nb.inter.tick: number of secondary ticks between main ticks on x-axis (only if not log scale). Zero means non secondary ticks
# y.nb.inter.tick: number of secondary ticks between main ticks on y-axis (only if not log scale). Zero means non secondary ticks
# tick.length: tick length (between 0 and 1)
# text.corner: text to add at the top right corner of the window
# amplif.legend: increase or decrease the size of the text of legend
# magnific.text.corner: increase or decrease the size of the text
# interval.disp: display sd and quantiles intervals on top of graphs ?
# RETURN
# nothing returned
# EXAMPLES
# data = tempo.sum ; down.space = 3 ; left.space = 3.5 ; up.space = 2 ; right.space = 1 ; orient = 1 ; dist.legend = 1.5 ; box.type = "l" ; amplif.label = amplif.test ; amplif.axis = amplif.test ; x.adj = "i" ; y.adj = "i" ; cex.pt = 0.5 ; col.box = hsv(0.55, 0.8, 0.8) ; x.nb.inter.tick = 4 ; y.nb.inter.tick = 0 ; text.corner = "" ; magnific.text.corner = amplif.test ; interval.disp = TRUE ; method.f = trim.method ; trim.dist.f = trim.dist ; quantiles.selection = c(0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 0.75, 0.9, 0.95, 0.975, 0.99)
# fun.stat.plot(data = matrix1, method.f = "quantile", trim.dist.f = c(0.05, 0.975))
color.cut <- hsv(0.75, 1, 1)  # color of interval selected
col.mean <- hsv(0.25, 1, 0.8) # color of interval using mean+/-sd
col.quantile <- "orange" # color of interval using quantiles
quantiles.selection <- c(0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 0.75, 0.9, 0.95, 0.975, 0.99) # quantiles used in axis to help for choosing trimming cutoffs
if(length(table(data)) == 1){
par(bty = "n", xaxt = "n", yaxt = "n", xpd = TRUE)
plot(1, pch = 16, col = "white", xlab = "", ylab = "")
text(x = 1, y = 1, paste0("No graphic displayed\nBecause data made of a single different value (", formatC(as.double(table(data))), ")"), cex = 2)
}else{
fun.rug <- function(){
if(x.nb.inter.tick > 0){
inter.tick.unit <- (par("xaxp")[2] - par("xaxp")[1]) / par("xaxp")[3]
par.ini <- par()$xpd
par(xpd = FALSE)
par(tcl = -par()$mgp[2] * tick.length) # tcl gives the length of the ticks as proportion of line text, knowing that mgp is in text lines. So the main ticks are a 0.5 of the distance of the axis numbers by default. The sign provides the side of the tick (negative for outside of the plot region)
suppressWarnings(rug(seq(par("xaxp")[1] - 10 * inter.tick.unit, par("xaxp")[2] + 10 * inter.tick.unit, by = inter.tick.unit / (1 + x.nb.inter.tick)), ticksize = NA, side = 1)) # ticksize = NA to allow the use of par()$tcl value
par(par.ini)
}
}
fun.add.cut <- function(data.f){
if(method.f != "" & all(trim.dist.f != "")){
par.ini <- par()$xpd
par(xpd = FALSE)
if(method.f == "mean.sd"){
abline(v = qnorm(trim.dist.f, mean(data, na.rm = TRUE), sd(data, na.rm = TRUE)), col = color.cut)
segments(qnorm(trim.dist.f[1], mean(data, na.rm = TRUE), sd(data, na.rm = TRUE)), par()$usr[4] * 0.75, qnorm(trim.dist.f[2], mean(data, na.rm = TRUE), sd(data, na.rm = TRUE)), par()$usr[4] * 0.75, col = color.cut)
}
if(method.f == "quantile"){
abline(v = quantile(data, probs = trim.dist.f, type = 7), col = color.cut)
segments(quantile(data, probs = trim.dist.f[1], type = 7), par()$usr[4] * 0.75, quantile(data, probs = trim.dist.f[2], type = 7), par()$usr[4] * 0.75, col = color.cut)
}
par(par.ini)
}
}
fun.interval.display <- function(data.f){ # intervals on top of graphs
par.ini <- par()[c("mgp", "xpd")]
par(mgp = c(0.25, 0.25, 0), xpd = NA)
axis(side = 3, at = c(par()$usr[1], par()$usr[2]), labels = rep("", 2), col = col.quantile, lwd.ticks = 0)
par(xpd = FALSE)
axis(side = 3, at = quantile(as.vector(data.f), probs = quantiles.selection, type = 7), labels = quantiles.selection, col.axis = col.quantile, col = col.quantile)
par(mgp = c(1.25, 1.25, 1), xpd = NA)
axis(side = 3, at = c(par()$usr[1], par()$usr[2]), labels = rep("", 2), col = col.mean, lwd.ticks = 0)
par(xpd = FALSE)
axis(side = 3, at = m + s * qnorm(quantiles.selection), labels = formatC(round(qnorm(quantiles.selection), 2)), col.axis = col.mean, col = col.mean, lwd.ticks = 1)
par(par.ini)
}
zone<-matrix(1:4, ncol=2)
layout(zone)
par(omd = c(0, 1, 0, 0.85), mar = c(down.space, left.space, up.space, right.space), las = orient, mgp = c(dist.legend, 0.5, 0), xpd = FALSE, bty= box.type, cex.lab = amplif.label, cex.axis = amplif.axis, xaxs = x.adj, yaxs = y.adj, tck = -0.05) # tck is the fraction of the plot region. Negative value for outside ticks
if(is.null(displayed.nb)){
sampled.data <- as.vector(data)
}else{
if(length(as.vector(data)) > displayed.nb){
sampled.data <- sample(as.vector(data), displayed.nb, replace = FALSE)
if(text.corner == ""){
text.corner <- paste0("BEWARE: ONLY ", displayed.nb, " VALUES ARE DISPLAYED AMONG THE ", length(as.vector(data)), " VALUES OF THE MATRIX ANALYZED")
}else{
text.corner <- paste0(text.corner, "\nBEWARE: ONLY ", displayed.nb, " VALUES ARE DISPLAYED AMONG THE ", length(as.vector(data)), " VALUES OF THE MATRIX ANALYZED")
}
}else{
sampled.data <- as.vector(data)
if(text.corner == ""){
text.corner <- paste0("BEWARE: THE DISPLAYED NUMBER OF VALUES PARAMETER ", deparse(substitute(displayed.nb)), " HAS BEEN SET TO ", displayed.nb, " WHICH IS ABOVE THE NUMBER OF VALUES OF THE MATRIX ANALYZED -> ALL VALUES DISPLAYED")
}else{
text.corner <- paste0(text.corner, "\nBEWARE: THE DISPLAYED NUMBER OF VALUES PARAMETER ", deparse(substitute(displayed.nb)), " HAS BEEN SET TO ", displayed.nb, " WHICH IS ABOVE THE NUMBER OF VALUES OF THE MATRIX ANALYZED -> ALL VALUES DISPLAYED")
}
}
}
stripchart(sampled.data, method="jitter", jitter=0.4, vertical=FALSE, ylim=c(0.5, 1.5), group.names = "", xlab = "Value", ylab="", pch=1, cex = cex.pt)
fun.rug()
boxplot(as.vector(data), horizontal=TRUE, add=TRUE, boxwex = 0.4, staplecol = col.box, whiskcol = col.box, medcol = col.box, boxcol = col.box, range = 0, whisklty = 1)
m <- mean(as.vector(data), na.rm = TRUE)
s <- sd(as.vector(data), na.rm = TRUE)
segments(m, 0.8, m, 1, lwd=2, col="red") # mean 
segments(m -1.96 * s, 0.9, m + 1.96 * s, 0.9, lwd=1, col="red") # mean 
graph.xlim <- par()$usr[1:2] # for hist() and qqnorm() below
if(interval.disp == TRUE){
fun.interval.display(data.f = data)
if(text.corner == ""){
text.corner <-  paste0("Multiplying factor displayed (mean +/- sd): ", paste(formatC(round(qnorm(quantiles.selection), 2))[-(1:(length(quantiles.selection) - 1) / 2)], collapse = ", "), "\nQuantiles displayed: ", paste(quantiles.selection, collapse = ", "))
}else{
text.corner <-  paste0(text.corner, "\nMultiplying factor displayed (mean +/- sd): ", paste(formatC(round(qnorm(quantiles.selection), 2))[-(1:(length(quantiles.selection) - 1) / 2)], collapse = ", "), "\nQuantiles displayed: ", paste(quantiles.selection, collapse = ", "))
}
}
fun.add.cut(data.f = data)
par(xpd = NA)
if(method.f != "" & all(trim.dist.f != "")){
if(interval.disp == TRUE){
legend(x = par()$usr[1], y = par()$usr[4] + ((par("usr")[4] -  par("usr")[3]) / (par("plt")[4] - par("plt")[3])) * par("plt")[3], legend = c(c("min, Q1, Median, Q3, max"), "mean +/- 1.96sd", paste0("Trimming interval: ", paste0(trim.dist.f, collapse = " , ")), "Mean +/- sd multiplying factor", "Quantile"), yjust = 0, lty=1, col=c(col.box, "red", color.cut, col.mean, col.quantile), bty="n", cex = amplif.legend)
}else{
legend(x = par()$usr[1], y = par()$usr[4] + ((par("usr")[4] -  par("usr")[3]) / (par("plt")[4] - par("plt")[3])) * par("plt")[3], legend = c(c("min, Q1, Median, Q3, max"), "mean +/- 1.96sd", paste0("Trimming interval: ", paste0(trim.dist.f, collapse = " , "))), yjust = 0, lty=1, col=c(col.box, "red", color.cut), bty="n", cex = amplif.legend, y.intersp=1.25)
}
}else{
if(interval.disp == TRUE){
legend(x = par()$usr[1], y = par()$usr[4] + ((par("usr")[4] -  par("usr")[3]) / (par("plt")[4] - par("plt")[3])) * par("plt")[3], legend = c(c("min, Q1, Median, Q3, max"), "mean +/- sd", "Mean +/- sd multiplying factor", "Quantile"), yjust = 0, lty=1, col=c(col.box, "red", col.mean, col.quantile), bty="n", cex = amplif.legend)
}else{
legend(x = par()$usr[1], y = par()$usr[4] + ((par("usr")[4] -  par("usr")[3]) / (par("plt")[4] - par("plt")[3])) * par("plt")[3], legend = c(c("min, Q1, Median, Q3, max"), "mean +/- sd"), yjust = 0, lty=1, col=c(col.box, "red"), bty="n", cex = amplif.legend, y.intersp=1.25)
}
}
par(xpd = FALSE, xaxs = x.adj)
hist(as.vector(data), main = "", breaks = seq(min(as.vector(data), na.rm = TRUE), max(as.vector(data), na.rm = TRUE), length.out = length(as.vector(data)) / 10), xlim = graph.xlim, xlab = "Value", ylab="Density", col = grey(0.25))
fun.rug()
if(interval.disp == TRUE){
fun.interval.display(data.f = data)
}
fun.add.cut(data.f = data)
par(xaxs = "r")
stripchart(rank(sampled.data), method="stack", vertical=FALSE, ylim=c(0.99, 1.3), group.names = "", xlab = "Rank of values", ylab="", pch=1, cex = cex.pt)
fun.rug()
x.text <- par("usr")[2] + (par("usr")[2] -  par("usr")[1]) / (par("plt")[2] - par("plt")[1]) * (1 - par("plt")[2]) / 2
y.text <- (par("usr")[4] + (par("usr")[4] -  par("usr")[3]) / (par("plt")[4] - par("plt")[3]) * (1 - par("plt")[4]))
par(xpd=NA)
text(x = x.text, y = y.text, paste0(text.corner), adj=c(1, -0.5), cex = magnific.text.corner) # text at the topright corner
par(xpd=FALSE)
par(xaxs = x.adj)
qqnorm(as.vector(sampled.data), main = "", datax = TRUE, ylab = "Value", pch = 1, col = "red", cex = cex.pt)
fun.rug()
if(diff(quantile(as.vector(data), probs = c(0.25, 0.75), na.rm = TRUE)) != 0){ # otherwise, error generated
qqline(as.vector(data), datax = TRUE)
}
if(interval.disp == TRUE){
fun.interval.display(data.f = data)
}
fun.add.cut(data.f = data)
# peut etre faire omd et mettre un espace en haut, puis xpd = NA et text corner, pour eviter que up.space affect les graphs du bas
}
}


################ Flat Pedigree Drawing


pedplot_fun <- function(data){
# AIM:
# plot a flat pedigree using the .tsv file made by the ped2tsv.py algorithm (developped by Freddy Cliquet, https://gitlab.pasteur.fr/ghfc/PediPlot)
# The ped2tsv.py script uses a classical pedfile (see protocol 72):

 


# REQUIRED FUNCTIONS
# param_check_fun()
# ARGUMENTS
# data: object to test
# RETURN
# a list containing:
# $width: the conputed width of the graphic window
# $height: the conputed heigth of the graphic window
# EXAMPLES
# data = 1:3 ; options = NULL ; class = NULL ; typeof = NULL ; mode = NULL ; prop = NULL ; length = 1
# test <- 1:3 ; param_check_fun(data = test, data.name = NULL, print = TRUE, options = NULL, all.options.in.data = FALSE, class = NULL, typeof = NULL, mode = NULL, prop = TRUE, length = NULL)
# argument checking
tempo <- param_check_fun(data = data, class = "data.frame", length = 1)
if(tempo$problem == TRUE){
tempo.cat <- paste0("\n\n================\n\nERROR: data argument MUST BE A DATA FRAME\n\n================\n\n")
stop(tempo.cat, "\n\n")
}


plot(1, 1, xlim = c(min(data$y, na.rm = TRUE), max(data$y, na.rm = TRUE)), ylim = c(-max(data$x, na.rm = TRUE) - 0.2, -min(data$x, na.rm = TRUE) + 0.2), type = "n", axes = FALSE, xlab = "", ylab = "")

# Links first
for (i in 1:length(data$x))
{
# Coordinates of the dot
x = data$x[i]
y = data$y[i]

# Setting maximum number of children for lines
max_children = 0
if (!is.na(data$x_c1[i])) # Have children
max_children = max(data[i, seq(10, length(data[i,]), 2)], na.rm = TRUE)

# Look for husband/wife and create i) vertical line between parents or down unique parent and ii) horizontal line covering all children
if (!is.na(data$x_conc[i])) # Two parents
{
lines(c(data$y[i], data$y_conc[i]), c(-data$x[i], -data$x_conc[i])) # Line between parents
if (!is.na(data$x_c1[i])) # Have children
{
lines(c((data$y[i] + data$y_conc[i]) / 2, (data$y[i] + data$y_conc[i]) / 2), c(-data$x[i], -data$x[i] - 0.5)) # Vertical line
lines(c((data$y[i] + data$y_conc[i]) / 2, max_children), c(-data$x[i] - 0.5, -data$x[i] - 0.5)) # Horizontal line covering all children
}
}
else # Only one parent
{
if (!is.na(data$x_c1[i])) # Has children
{
lines(c(data$y[i], data$y[i]), c(-data$x[i], -data$x[i] - 0.5)) # Vertical line
lines(c(data$y[i], max_children), c(-data$x[i] - 0.5, -data$x[i] - 0.5)) # Horizontal line covering all children
}
}

# Creating vertical lines to children
for (j in seq(9, length(data[1,]), 2))
if (!is.na(data[i, j]))
lines(c(data[i, j + 1], data[i, j + 1]), c(-data$x[i] - 0.5, -data$x[i] - 1))
}

# Individuals now
for (i in 1:length(data$x))
{
# Coordinates of the dot
x = data$x[i]
y = data$y[i]

# Shape/color of the dot depend on sex/status
pch = NA
if (data$sex[i] == 1 & data$pheno[i] == 1) # Unaffected Male: Empty square
pch = 22
if (data$sex[i] == 1 & data$pheno[i] == 2) # Affected Male: Filled square
pch = 15
if (data$sex[i] == 2 & data$pheno[i] == 1) # Unaffected Female: Empty circle
pch = 21
if (data$sex[i] == 2 & data$pheno[i] == 2) # Affected Female: Filled circle
pch = 19

# Draw the dot and corresponding individual ID below
points(y, -x, pch = pch, cex = 2, bg = "white")
if (!is.na(x))
text(y, -x - 0.2, strsplit(as.character(data$ID[i]), "-")[[1]][4], cex = 0.5)

# Special case: Dead individual
if (data$dead[i] == 2)
points(y, -x, pch = 4, cex = 3)
}
}


################ Manhattan plot


manhattan2 <- function(x, chr="CHR", bp="BP", p="P", snp="SNP", col=c("gray10", "gray60"), pch = 20, lwd = 1, type = "p", chrlabs=NULL, suggestiveline=-log10(1e-5), genomewideline=-log10(5e-8), highlight=NULL, logp=TRUE, annotatePval = NULL, annotateTop = TRUE, chromo.delim.plot = TRUE, delim.col = grey(0.75), return.output = FALSE, ylim = NULL, ...) {
# FROM:
# qqman: An R package for creating Q-Q and manhattan plots from GWAS results.
# http://www.r-pkg.org/badges/version/qqman)](http://cran.r-project.org/package=qqman)
# Turner, S.D. qqman: an R package for visualizing GWAS results using Q-Q and manhattan plots. [*biorXiv* DOI: 10.1101/005165](http://biorxiv.org/content/early/2014/05/14/005165).
# MODIFICATIONS BY Gael Millot:
# in blue
# AIM:
# display a manhattan plot, with points or bars or other types of the points() function
# REQUIRED FUNCTIONS
# none
# ARGUMENTS
# x: data frame
# chr: name of the Chromo column in x
# bp: name of the Physical position column in x
# p: name of the quantitative column in x (y value to plot)
# snp: name of the SNP column in x
# col: color (several allowed -> will the recycled)
# pch: kind of point. Only used when type ="p"
# lwd: line width. Only used when type ="l"
# type: type of manhattan plot. Only type argument of points() allowed
# chromo.delim.plot: plot chromosome delimitations?
# delim.col: color of the chromo delimiters
# return.output: return output?
# see below for the other arguments
# RETURN
# a draw and a list containing:
# $chr.pos: position of the chr label on the x-axis
# $chr.delim.pos: positions of chromo delimiter drawn on the manhattan plot (vertical grey lines)
# EXAMPLES
# user.data.ini <- read.table("Z:\\dyslexia\\20180320_lodscore_results\\20180320_lodscore_results_1521559069\\full_lodscore_1521559073.txt", header = TRUE) ; manhattan(user.data.ini, chr = "Chr", snp = "SNP", type = "h", bp = "Physical.position", p = "Lodscore", logp = FALSE, col = hsv(h = c(4,7)/8, s = 0.4, v = 0.8), ylab = "LODSCORE", genomewideline = 3, suggestiveline = FALSE, main = paste0("WHOLE GENOME"), ylim = range(a$Lodscore, na.rm = TRUE))
# x <- user.data.ini ; chr = chr ; snp = snp ; bp = bp ; p = p ; pch = pch ; type = type ; logp = logp ; col = col ; ylab = ylab ; genomewideline = 3 ; suggestiveline = FALSE ; main = NULL ; ylim = eval(ylim) ; return.output = TRUE

#' Creates a manhattan plot
#' 
#' Creates a manhattan plot from PLINK assoc output (or any data frame with 
#' chromosome, position, and p-value).
#' 
#' @param x A data.frame with columns "BP," "CHR," "P," and optionally, "SNP."
#' @param chr A string denoting the column name for the chromosome. Defaults to 
#'   PLINK's "CHR." Said column must be numeric. If you have X, Y, or MT 
#'   chromosomes, be sure to renumber these 23, 24, 25, etc.
#' @param bp A string denoting the column name for the chromosomal position. 
#'   Defaults to PLINK's "BP." Said column must be numeric.
#' @param p A string denoting the column name for the p-value. Defaults to 
#'   PLINK's "P." Said column must be numeric.
#' @param snp A string denoting the column name for the SNP name (rs number). 
#'   Defaults to PLINK's "SNP." Said column should be a character.
#' @param col A character vector indicating which colors to alternate.
#' @param chrlabs A character vector equal to the number of chromosomes
#'   specifying the chromosome labels (e.g., \code{c(1:22, "X", "Y", "MT")}).
#' @param suggestiveline Where to draw a "suggestive" line. Default 
#'   -log10(1e-5). Set to FALSE to disable.
#' @param genomewideline Where to draw a "genome-wide sigificant" line. Default 
#'   -log10(5e-8). Set to FALSE to disable.
#' @param highlight A character vector of SNPs in your dataset to highlight. 
#'   These SNPs should all be in your dataset.
#' @param logp If TRUE, the -log10 of the p-value is plotted. It isn't very 
#'   useful to plot raw p-values, but plotting the raw value could be useful for
#'   other genome-wide plots, for example, peak heights, bayes factors, test 
#'   statistics, other "scores," etc.
#' @param annotatePval If set, SNPs below this p-value will be annotated on the plot.
#' @param annotateTop If TRUE, only annotates the top hit on each chromosome that is below the annotatePval threshold. 
#' @param ... Arguments passed on to other plot/points functions
#'   
#' @return A manhattan plot.
#'   
#' @keywords visualization manhattan
#'   
#' @import utils
#' @import graphics
#' 
#' @examples
#' manhattan(gwasResults)
#'   
#' @importFrom calibrate textxy  
#'   
#' @export
    # Not sure why, but package check will warn without this.
    CHR=BP=P=index=NULL
    
    # Check for sensible dataset
    ## Make sure you have chr, bp and p columns.
    if (!(chr %in% names(x))) stop(paste("Column", chr, "not found!"))
    if (!(bp %in% names(x))) stop(paste("Column", bp, "not found!"))
    if (!(p %in% names(x))) stop(paste("Column", p, "not found!"))
    ## warn if you don't have a snp column
    if (!(snp %in% names(x))) warning(paste("No SNP column found. OK unless you're trying to highlight."))
    ## make sure chr, bp, and p columns are numeric.
    if (!is.numeric(x[[chr]])) stop(paste(chr, "column should be numeric. Do you have 'X', 'Y', 'MT', etc? If so change to numbers and try again."))
    if (!is.numeric(x[[bp]])) stop(paste(bp, "column should be numeric."))
    if (!is.numeric(x[[p]])) stop(paste(p, "column should be numeric."))
    
    # Create a new data.frame with columns called CHR, BP, and P.
    d=data.frame(CHR=x[[chr]], BP=x[[bp]], P=x[[p]])
    
    # If the input data frame has a SNP column, add it to the new data frame you're creating.
    if (!is.null(x[[snp]])) d=transform(d, SNP=x[[snp]])
    
    # Set positions, ticks, and labels for plotting
    ## Sort and keep only values where is numeric.
    #d <- subset(d[order(d$CHR, d$BP), ], (P>0 & P<=1 & is.numeric(P)))
    d <- subset(d, (is.numeric(CHR) & is.numeric(BP) & is.numeric(P)))
    d <- d[order(d$CHR, d$BP), ]
    #d$logp <- ifelse(logp, yes=-log10(d$P), no=d$P)
    if (logp) {
        d$logp <- -log10(d$P)
    } else {
        d$logp <- d$P
    }
    d$pos=NA
    
    
    # Fixes the bug where one chromosome is missing by adding a sequential index column.
    d$index=NA
    ind = 0
    for (i in unique(d$CHR)){
        ind = ind + 1
        d[d$CHR==i,]$index = ind
    }
    
    # This section sets up positions and ticks. Ticks should be placed in the
    # middle of a chromosome. The a new pos column is added that keeps a running
    # sum of the positions of each successive chromsome. For example:
    # chr bp pos
    # 1   1  1
    # 1   2  2
    # 2   1  3
    # 2   2  4
    # 3   1  5
    nchr = length(unique(d$CHR))
    if (nchr==1) { ## For a single chromosome
        ## Uncomment the next two linex to plot single chr results in Mb
        #options(scipen=999)
        #d$pos=d$BP/1e6
        d$pos=d$BP
        ticks=floor(length(d$pos))/2+1
        chr.delim.pos <- c(1, length(d$pos))
        xlabel = paste('Chromosome',unique(d$CHR),'position')
        labs = ticks
    } else { ## For multiple chromosomes
        lastbase=0
        ticks=NULL
        chr.min.pos <- NULL
        chr.max.pos <- NULL
        for (i in unique(d$index)) {
            if (i==1) {
                d[d$index==i, ]$pos=d[d$index==i, ]$BP
            } else {
                lastbase=lastbase+tail(subset(d,index==i-1)$BP, 1)
                d[d$index==i, ]$pos=d[d$index==i, ]$BP+lastbase
            }
            # Old way: assumes SNPs evenly distributed
            # ticks=c(ticks, d[d$index==i, ]$pos[floor(length(d[d$index==i, ]$pos)/2)+1])
            # New way: doesn't make that assumption
            ticks = c(ticks, (min(d[d$index == i,]$pos) + max(d[d$index == i,]$pos))/2 + 1)
            chr.min.pos <- c(chr.min.pos, min(d[d$index == i,]$pos))
            chr.max.pos <- c(chr.max.pos, max(d[d$index == i,]$pos))
        }
        chr.delim.pos <- c(min(chr.min.pos), (chr.min.pos[2:length(chr.min.pos)] + chr.max.pos[1:(length(chr.max.pos) - 1)]) / 2 + 1, max(chr.max.pos))
        xlabel = 'Chromosome'
        #labs = append(unique(d$CHR),'') ## I forgot what this was here for... if seems to work, remove.
        labs <- unique(d$CHR)
    }
    
    # Initialize plot
    # xmax = ceiling(max(d$pos) * 1.03)
    # xmin = floor(max(d$pos) * -0.03)
    xmax = max(d$pos)
    xmin = min(d$pos)
if( ! is.null(ylim)){
d$logp[d$logp < min(ylim, na.rm = TRUE)] <- min(ylim, na.rm = TRUE)
d$logp[d$logp > max(ylim, na.rm = TRUE)] <- max(ylim, na.rm = TRUE)
}else{
ylim <- c(0,ceiling(max(d$logp)))
}

    # The old way to initialize the plot
    # plot(NULL, xaxt='n', bty='n', xaxs='i', yaxs='i', xlim=c(xmin,xmax), ylim=c(ymin,ymax),
    #      xlab=xlabel, ylab=expression(-log[10](italic(p))), las=1, pch=pch, ...)

    
    # The new way to initialize the plot.
    ## See http://stackoverflow.com/q/23922130/654296
    ## First, define your default arguments
    def_args <- list(xaxt='n', bty='n', xaxs='i', yaxs='i', las=1, pch=pch,
                     xlim=c(xmin,xmax), ylim=ylim,
                     xlab=xlabel, ylab=expression(-log[10](italic(p))))
    ## Next, get a list of ... arguments
    #dotargs <- as.list(match.call())[-1L]
    dotargs <- list(...)
    ## And call the plot function passing NA, your ... arguments, and the default
    ## arguments that were not defined in the ... arguments.
    do.call("plot", c(NA, dotargs, def_args[!names(def_args) %in% names(dotargs)]))
    
    # If manually specifying chromosome labels, ensure a character vector and number of labels matches number chrs.
    if (!is.null(chrlabs)) {
        if (is.character(chrlabs)) {
            if (length(chrlabs)==length(labs)) {
                labs <- chrlabs
            } else {
                warning("You're trying to specify chromosome labels but the number of labels != number of chromosomes.")
            }
        } else {
            warning("If you're trying to specify chromosome labels, chrlabs must be a character vector")
        }
    }
    
    # Add an axis. 
    if (nchr==1) { #If single chromosome, ticks and labels automatic.
        axis(1, ...)
    } else { # if multiple chrs, use the ticks and labels you created above.
        axis(1, at=ticks, labels=labs, ...)
    }
    
    # Create a vector of alternatiting colors
    col=rep(col, max(d$CHR))
    # add the chromo delimiters
if(chromo.delim.plot == TRUE){
par()
abline(v = chr.delim.pos, col = delim.col, lty = "44")
}
# add a x-axis line
abline(h = par()$usr[3])
    # Add points to the plot
    if (nchr==1) {
        with(d, points(pos, logp, pch=pch, lwd = lwd, col=col[1], type = type, ...))
    } else {
        # if multiple chromosomes, need to alternate colors and increase the color index (icol) each chr.
        icol=1
        for (i in unique(d$index)) {
            with(d[d$index==unique(d$index)[i], ], points(pos, logp, col=col[icol], lwd = lwd, pch=pch, type = type, ...))
            icol=icol+1
        }
    }
    
    # Add suggestive and genomewide lines
    if (suggestiveline) abline(h=suggestiveline, col="blue")
    if (genomewideline) abline(h=genomewideline, col="red")
    
    # Highlight snps from a character vector
    if (!is.null(highlight)) {
        if (any(!(highlight %in% d$SNP))) warning("You're trying to highlight SNPs that don't exist in your results.")
        d.highlight=d[which(d$SNP %in% highlight), ]
        with(d.highlight, points(pos, logp, col="green3", pch=pch, lwd = lwd, type = type, ...)) 
    }
    
    # Highlight top SNPs
    if (!is.null(annotatePval)) {
        # extract top SNPs at given p-val
        topHits = subset(d, P <= annotatePval)
        par(xpd = TRUE)
        # annotate these SNPs
        if (annotateTop == FALSE) {
            with(subset(d, P <= annotatePval), 
                 textxy(pos, -log10(P), offset = 0.625, labs = topHits$SNP, cex = 0.45), ...)
        }
        else {
            # could try alternative, annotate top SNP of each sig chr
            topHits <- topHits[order(topHits$P),]
            topSNPs <- NULL
            
            for (i in unique(topHits$CHR)) {
                
                chrSNPs <- topHits[topHits$CHR == i,]
                topSNPs <- rbind(topSNPs, chrSNPs[1,])
                
            }
            textxy(topSNPs$pos, -log10(topSNPs$P), offset = 0.625, labs = topSNPs$SNP, cex = 0.5, ...)
        }
    }  
    par(xpd = FALSE)
if(return.output == TRUE){
output <- list(chr.pos = ticks, chr.delim.pos = chr.delim.pos)
return(output)
}
}



