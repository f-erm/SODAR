# Description: This script generates the map_In_to_fastq.csv file necessary for uploading samples to the SODAR platforms
# Author: Coral Fustero-Torre
# email: coral.fustero@bih-charite.de

# -- Read input parameters -- #
path <- snakemake@params[["input_dir"]]
out <- snakemake@params[["out"]]
samples <- snakemake@params[["samples"]]

# -- Read samples file -- #
message("Reading samples.tsv")
samples <- read.table(samples, sep = "\t", header = T, check.names=FALSE)

# -- Read files in fastq folder -- #
message("Reading fastq files")
fastq_files <- list.files(path, pattern = "fastq.gz")
# -- Create final dataframe -- #
map_In_to_fastq <- data.frame("#LibraryName" = fastq_files,
                             "FastqFilenameWithNoPath" = fastq_files,
                             check.names = FALSE)
                                                  
for(x in samples$ 'scATAC-seq samples'){
  map_In_to_fastq[grep(x, fastq_files), "#LibraryName"] <- x
}
message("Saving map_ln_to_fastq file")                
write.table(map_In_to_fastq, file = file.path(out, "map_ln_to_fastq.csv"),
          sep=",", quote = FALSE, row.names = FALSE)#, col.names=FALSE)
