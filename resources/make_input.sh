#!/bin/bash

path_to_fastq="/fast/home/projects/ludwig_cubi/fastq/"
out="/fast/home/projects/ludwig_cubi/work/input/"
path_to_csv="/fast/home/projects/ludwig_cubi/work/fastq/"

mkdir -p $out
cd $out
while IFS=',' read library_name fastq
do
  md5sum $path_to_fastq$fastq > $path_to_fastq"$fastq".md5
  mkdir -p $library_name/fastq
  cd $library_name/fastq
  ln -sF $path_to_fastq$fastq $fastq
  ln -sF $path_to_fastq"$fastq".md5 "$fastq".md5
  cd $out
done < $path_to_csv/map_ln_to_fastq.csv
