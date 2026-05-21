# Description: This script generates the a, i and s files necessary for uploading samples to the SODAR platforms
# Author: Coral Fustero-Torre
# email: coral.fustero@bih-charite.de

# -- Read input parameters -- #
path <- snakemake@params[["input_dir"]]
sample_ID <- snakemake@params[["sample_id"]]
out <- snakemake@params[["out"]]
samples <- snakemake@params[["samples"]]
file_types <- snakemake@params[["file_types"]]
sample_type <- snakemake@params[["sample_type"]]

# -- Read samples file -- #
message("Reading samples.tsv")
samples <- read.table(samples, sep = "\t", header = T,  check.names=FALSE )
rownames(samples) <- samples[[1]]

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
file_pattern = paste0("(", paste(file_types, collapse = "|"), ")$")
selected_files <- list.files(path, pattern = file_pattern, recursive = TRUE, full.names = FALSE)
if (length(selected_files) != length(unique(basename(selected_files)))) {
 stop("There are duplicate file names in different subdirectories. File names need to be unique regardless of subdirectory")
}

# -- Get all samples with fixed location and filter them out -- #
if ("location" %in% names(samples)) {
  locations <- samples[,"location"]
}else{
  locations <- rep(NA, nrow(samples))
  samples[["location"]] <- locations
}
locations_exist <- !is.na(locations) & locations != ""
selected_files <- Filter(function(f) #locations need to be given relative to sample dir
  !any(grepl(paste0("/", locations[locations_exist], "/"),f)),selected_files)



# --- Get name depending on naming scheme. Adjust this based on file type!!! --- #
#fastq
fastq <- selected_files[grep("\\.fastq.gz$", selected_files)]
fastq_names <- basename(fastq)
fastq_names <- unique(unlist(lapply(strsplit(fastq_names,split="\\.[0-9]"), "[", 1)))
#fastq_names <- unique(unlist(lapply(strsplit(fastq_names,split="_S[0-9]"), "[", 1)))

# Some other file type
# some_other_files <- ...
# some_other_files_names <- basename(some_other_files)
# some_other_files_names <- ...Filename adjustment depending on naming scheme

file_names <- c(fastq_names) #, some_other_files)
file_paths <- c(fastq) #, some_other_files)

file_names <- unique(file_names)
#----------------------------------------------------------------------------------#



# -- Sorting files according to samples
f_n <- character(0)
f_p <- character(0)
for (sample in samples[,pattern]){
  loc <- samples[sample,"location"]
  if (!is.na(loc) && loc != ""){
    f_n <- c(f_n, sample)
  }else{
    n <- file_names[grepl(sample, file_names,  fixed = TRUE)]
    f <- file_paths[grepl(sample, file_paths,  fixed = TRUE)]
    f_n <- c(f_n, n)
    f_p <- c(f_p, f)
  }
}
file_names <- f_n
file_paths <- f_p

# -- Generating all Files -- #
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
  map_In_to_fastq <- data.frame("LibraryName" = file_paths,
                              "FastqFilenameWithNoPath" = file_paths,
                              check.names = FALSE)
  for(name in file_names){
    map_In_to_fastq[grep(name, file_paths), "LibraryName"] <- name
  }
  message("Saving map_ln_to_fastq file")       
  write.table(map_In_to_fastq, file = file.path(out, "map_ln_to_fastq.csv"),
            sep=",", quote = FALSE, row.names = FALSE, col.names=FALSE)
  
  # -- Generate locations dataframe -- #
  map_locations <- data.frame("SampleName" = samples[locations_exist,pattern],
                                "Location" = samples[locations_exist,"location"],
                                check.names = FALSE)
  if (any(locations_exist)){
    map_locations$SampleName <- paste0(sample_ID,'_',map_locations$SampleName)
  }
  message("Saving map_locations file")                
  write.table(map_locations, file = file.path(out, "map_locations.csv"),
              sep=",", quote = FALSE, row.names = FALSE, col.names=FALSE)
  
  message("Done! :)")
} else {
  warning("There is no agreement between the Nº of files detected samples.txt metadata.")
  message("Detected file names: ", paste(file_names, collapse = ", "))
  message("Detected sample names: ", paste(samples[,pattern], collapse = ", "))
}
