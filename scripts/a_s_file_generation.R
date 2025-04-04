# Description: This script generates the a, i and s files necessary for uploading samples to the SODAR platforms
# Author: Coral Fustero-Torre
# email: coral.fustero@bih-charite.de

# -- Read input parameters -- #
path <- snakemake@params[["input_dir"]]
sample_ID <- snakemake@params[["sample_id"]]
out <- snakemake@params[["out"]]
samples <- snakemake@params[["samples"]]
input_format <- snakemake@params[["input_format"]]
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
  selected_folders <- unlist(lapply(samples[,pattern], function(x) list.files(path, x)))
  selected_files <- unlist(lapply(selected_folders, function(x) list.files(file.path(path, x), pattern = "fastq.gz")))
} else if (input_format == "list") {
  selected_files <- unlist(lapply(samples[,pattern], function(x) list.files(path, x)))
} else {
  message("The input format wasn't recognised. Please choose between 'folder' or 'list'")
}

file_names <- unique(unlist(lapply(strsplit(selected_files,split="_S[0-9]"), "[", 1)))
message(paste0(length(file_names), " unique file names detected."))

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
        message("Done! :)")
} else {
  warning("There is no agreement between the Nº of files detected sample.txt metadata. The list.files function might not be working properly?")
}

