# Description: This script generates the a, i and s files necessary for uploading samples to the SODAR platforms
# Author: Coral Fustero-Torre
# email: coral.fustero@bih-charite.de

# -- Read input parameters -- #
path <- snakemake@params[["input_dir"]]
sample_ID <- snakemake@params[["sample_id"]]
out <- snakemake@params[["out"]]
samples <- snakemake@params[["samples"]]
input_format <- snakemake@params[["input_format"]]
file_types <- snakemake@params[["file_types"]]
sample_type <- snakemake@params[["sample_type"]]

# -- Read samples file -- #
message("Reading samples.tsv")
samples <- read.table(samples, sep = "\t", header = T,  check.names=FALSE)

# -- Select technology type -- #
if (sample_type == "scRNA-seq"){
  pattern <- "scRNA-seq samples"
} else if (sample_type == "scATAC-seq"){
  pattern <- 'scATAC-seq samples'
} else if(sample_type == "Multiome-GEX"){
  pattern <- "Multiome-GEX samples"
} else if (sample_type %in% c("multiome", "scenith", "other")){
  pattern <- "samples"
} else {
  message("Sample type not regognise. Please choose between: 'scRNA-seq', 'scATAC-seq', 'samples', 'other'")
}

# -- Obtain file names -- #
 message("Obtaining file names")
if (input_format == "folder") {
  selected_folders <- unlist(lapply(samples[,pattern], function(x) list.files(path, paste(x,"_",sep=""))))
  selected_files <- unlist(lapply(selected_folders, function(x) list.files(file.path(path, x), pattern = "fastq.gz")))
} else if (input_format == "list") {
  selected_files <- unlist(lapply(samples[,pattern], function(x) list.files(path, paste(x,"_",sep=""))))
} else if (input_format == "recursive") {#Get all files of specified types, regardless of subdir

  file_pattern = paste0("(", paste(file_types, collapse = "|"), ")$")
  selected_files <- list.files(path, pattern = file_pattern, recursive = TRUE, full.names = FALSE)
  if (length(selected_files) != length(unique(basename(selected_files)))) {
    warning("There are duplicate file names in different subdirectories. File names need to be unique regardless of subdirectory")
  }
  file_names <- basename(selected_files)
} else {
  message("The input format wasn't recognised. Please choose between 'folder' or 'list'")
}


# --- Get name depending on naming scheme. Adjust this based on file type!!! --- #
#fastq
fastq <- selected_files[grep("\\.fastq.gz$", selected_files)]#aus mapln
fastq_names <- basename(fastq)
fastq_names <- unique(unlist(lapply(strsplit(fastq_names,split="\\.[0-9]"), "[", 1)))
#fastq_names <- unique(unlist(lapply(strsplit(fastq_names,split="_S[0-9]"), "[", 1)))
#md5  
md5 <- selected_files[grep("\\.md5$", selected_files)]
md5_names <- basename(md5)
md5_names <- unique(unlist(lapply(strsplit(md5_names,split="\\.[0-9]"), "[", 1)))
# Some other file type
# some_other_files <- ...

#kein md5 name? ja weil vergleich unten nicht mit md5 funktioniert.
file_names <- c(fastq_names) #, some_other_files)
file_paths <- c(fastq,md5) #, some_other_files)

#----------------------------------------------------------------------------------#

file_names <- unique(file_names)
library_name <- fastq_names

if(length(file_names) == dim(samples)[1]){
	# -- Generate a file -- #
	message("Generating a file")
	a <- data.frame("Sample Name" = samples[,pattern],
                "Protocol REF" = rep("Laboratory register archiving", dim(samples)[1]),
                "Parameter Value[Library ID]" = samples$ 'ID',
                "Parameter Value[Labregister Item ID]" = samples$ 'Lab Register ID',
                "Parameter Value[Prep Date]" = samples$ 'Date',
                "Parameter Value[Barcode Name]" = samples$ 'primer',
                "Library Name" = file_names, check.names = FALSE)
	write.table(a, file = file.path(out, paste0("a_", sample_ID, ".txt")), sep = "\t", 
		 quote = FALSE, row.names = FALSE)
 
	# -- Generate s file -- #
	message("Generating s file")
	s <- data.frame("Source Name" = file_names,
                "Sample Name" = samples[,pattern], check.names = FALSE)
	write.table(s, file = file.path(out, paste0("s_", sample_ID, ".txt")), sep = "\t", 
		quote = FALSE, row.names = FALSE)
        message("Saving a and s files")
  
  # -- Generate csv dataframe -- #
  map_In_to_fastq <- data.frame("#LibraryName" = file_paths,
                              "FastqFilenameWithNoPath" = file_paths,
                              check.names = FALSE)
                          
  #TODO Does this work for arbitrary naming scheme and md5?
  for(name in library_name){
    #map_In_to_fastq[grep(paste0(name, "_S"), fastq_files), "#LibraryName"] <- name
    #map_In_to_fastq[grep(paste0(name, "\\.[0-9]"), file_paths), "#LibraryName"] <- name
    map_In_to_fastq[grep(name, file_paths), "#LibraryName"] <- name
  }
  message("Saving map_ln_to_fastq file")                
  write.table(map_In_to_fastq, file = file.path(out, "map_ln_to_fastq.csv"),
            sep=",", quote = FALSE, row.names = FALSE, col.names=FALSE)
  
  message("Done! :)")
} else {
  warning("There is no agreement between the Nº of files detected samples.txt metadata.")
  message("Detected file names: ", paste(file_names, collapse = ", "))
  message("Detected sample names: ", paste(samples[,pattern], collapse = ", "))
}
