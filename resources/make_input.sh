#!/bin/bash

# build input dir by creating softlinks and generating md5 if necessary

path_to_fastq="/fast/home/projects/ludwig_cubi/fastq/"
out="/fast/home/projects/ludwig_cubi/work/input/"
path_to_csv="/fast/home/projects/ludwig_cubi/work/fastq/"
extensions=("fastq.gz")

mkdir -p $out
cd $out

# Create Softlinks for samples with unspecified location
while IFS=',' read library_name fastq
do
  #Determine file type
  fname=$(basename "$fastq")
  extension=""
  for ext in "${extensions[@]}"; do
    if [[ "$fname" == *."$ext" ]]; then
      extension="$ext"
      break
    fi
  done
  if [[ -z "$extension" ]]; then
    echo "ERROR: Found file of invalid type. Something went wrong"
    exit 1 
  fi

  #Put file (and md5 if present) in correct dir
  mkdir -p $library_name/${extension}
  if [[ -f $path_to_fastq"$fname".md5 ]]; then
    ln -sF $path_to_fastq"$fname".md5 $library_name/${extension}/"$fname".md5
  fi
  ln -sF $path_to_fastq$fname $library_name/${extension}/"$fname"
done < $path_to_csv/map_ln_to_fastq.csv

# Create softlinks for all samples with specified location
while IFS=',' read sample_name path
do
  ln -sF $path_to_fastq/"$sample_name" $sample_name
done < $path_to_csv/map_locations.csv

#Generate all missing md5
find -L . -type f ! -name "*.md5" -exec bash -c '
for f do
  md5file="${f}.md5"
  if [ ! -f "$md5file" ]; then
    echo "generating $md5file"
    md5sum "$f" > "$md5file"
  fi
done
' bash {} +
