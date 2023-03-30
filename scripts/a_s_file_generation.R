# Description: This script generates the a, i and s files necessary for uploading samples to the SODAR platforms
# Author: Coral Fustero-Torre
# email: coral.fustero@bih-charite.de

# -- Read input parameters -- #
path <- snakemake@params[["input_dir"]]
sample_ID <- snakemake@params[["sample_id"]]
out <- snakemake@params[["out"]]

# -- Read samples file -- #
message("Reading samples.tsv")
samples <- read.table("samples.tsv", sep = "\t", header = T,  check.names=FALSE)

# -- Obtain file names -- #
message("Obtaining file names")
selected_files <- unlist(lapply(samples$ 'scATAC-seq samples', list.files(path, x)))
file_names <- lapply( strsplit(selected_files,split="_L0"), "[", 1)

# -- Generate a file -- #
message("Generating a file")
a <- data.frame("Sample Name" = samples$ 'scATAC-seq samples', 
                "Protocol REF" = rep("Laboratory register archiving", dim(samples)[1]), 
                "Parameter Value[Library ID]" = samples$ 'ID', 
                "Parameter Value[Labregister Item ID]" = samples$ 'Lab Register ID',
                "Parameter Value[Prep Date]" = samples$ 'Date',
                "Parameter Value[Barcode Name]" = samples$ 'primer',
                "Library Name" = file_names)
write.table(a, file = file.path(out, paste0("a_", sample_ID, ".txt")), sep = "\t", col.names = NA)

# -- Generate s file -- #
message("Generating s file")
s <- data.frame("Source Name" = file_names, 
                "Sample Name" = samples$ 'scATAC-seq samples')
write.table(s, file = file.path(out, paste0("s_", sample_ID, ".txt")), sep = "\t", col.names = NA)
