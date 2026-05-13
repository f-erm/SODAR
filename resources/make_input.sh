#!/bin/bash

# build input dir by creating softlinks and generating md5 if necessary

path_to_fastq="/fast/home/projects/ludwig_cubi/fastq/"
out="/fast/home/projects/ludwig_cubi/work/input/"
path_to_csv="/fast/home/projects/ludwig_cubi/work/fastq/"
extensions=("fastq.gz")

mkdir -p $out
cd $out
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

  #Put File in correct dir and generate md5 if necessary
  mkdir -p $library_name/${extension}
  # If MD5 does not exist already compute it
  if [[! -f $path_to_fastq"$fname".md5 ]]; then
    echo "Generating missing md5 for $fname"
    md5sum $path_to_fastq$fname > $path_to_fastq"$fname".md5
  fi
  ln -sF $path_to_fastq"$fname".md5 $library_name/${extension}/"$fname".md5
  ln -sF $path_to_fastq$fname $library_name/${extension}/"$fname"
done < $path_to_csv/map_ln_to_fastq.csv
