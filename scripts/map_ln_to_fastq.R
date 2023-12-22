# Description: This script generates the map_In_to_fastq.csv file necessary for uploading samples to the SODAR platforms
# Author: Coral Fustero-Torre
# email: coral.fustero@bih-charite.de

# -- Read input parameters -- #
path <- snakemake@params[["input_dir"]]
out <- snakemake@params[["out"]]
samples <- snakemake@params[["samples"]]
input_format <- snakemake@params[["input_format"]]
sample_type <- snakemake@params[["sample_type"]]

# -- Read samples file -- #
message("Reading samples.tsv")
samples <- read.table(samples, sep = "\t", header = T, check.names=FALSE)

# -- Select technology type -- #
if (sample_type == "scRNA-seq"){
    pattern <- "scRNA-seq samples"
} else if (sample_type == "scATAC-seq"){
    pattern <- 'scATAC-seq samples'
} else if(sample_type == "Multiome-GEX"){
    pattern <- "Multiome-GEX samples"
} else if (sample_type == "multiome"){
    pattern <- "samples"
} else {
    message("Sample type not regognise. Please choose between: 'scRNA-seq', 'scATAC-seq', 'samples'")
}

# -- Read files in fastq folder -- #
message("Reading fastq files")
if (input_format == "folder") {
  selected_folders <- unlist(lapply(samples[,pattern], function(x) list.files(path, x)))
  fastq_files <- unlist(lapply(selected_folders, function(x) list.files(file.path(path, x), pattern = "fastq.gz")))
  library_name <- list.files(path)[list.files(path) != "Undetermined"]
} else if (input_format == "list"){
  fastq_files <- list.files(path, pattern = "fastq.gz")
  library_name <- unique(unlist(lapply(strsplit(fastq_files, split="_S[0-9]"), "[", 1)))
# -- Create final dataframe -- #
} else {
  message("Ola, seniora, ké ase?")
}

# -- Create final dataframe -- #
map_In_to_fastq <- data.frame("#LibraryName" = fastq_files,
                              "FastqFilenameWithNoPath" = fastq_files,
                              check.names = FALSE)
                          
for(name in library_name){
  map_In_to_fastq[grep(paste0(name, "_S"), fastq_files), "#LibraryName"] <- name
}


message("Saving map_ln_to_fastq file")                
write.table(map_In_to_fastq, file = file.path(out, "map_ln_to_fastq.csv"),
          sep=",", quote = FALSE, row.names = FALSE, col.names=FALSE)
