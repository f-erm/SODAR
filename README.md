# SODAR
This snakemake pipeline aims at facilitating the uploading of samples to the **SODAR** platform.

<img src="resources/img/sodar_cacaolat_logo.png" width="100">

## Authors

* Original author: Coral Fustero-Torre
* Fork modifications: Ferdinand Ermel

## Changes
This fork adds the following features:
- Extend support from fastq.gz files to files of arbitrary file type 
- Support for different technology types, e.g PacBio instead of Illumina
- Allow for files in arbitrary depth, replacing the previous "list/folder" option
- Add python script to automatically handle SODAR project creation and file upload
- Allow for individual samples to be given by designated location
- Automatic validation of sample sheets
- Centralised file name adjustements, simplifying adaptation to unseen naming schemes 
- Confirm if MD5s already exist and only compute if not already present
- Add slurm script to run the pipeline
- Minor bug fixes

## Setup

For setting up the pipeline, two configuration files need to be modified. See the *Usage* section for more details.

### Configuration files

* **config.yaml** contains all pipeline parameters.
* **samples.tsv/txt**: contains metadata annotations. An example file is part of the repo. Keep in mind not all columns will be necessary.

## Usage

### 1. Set up the environment

**SODAR** requires the installation of the conda package manager in order to work. Please install conda by following the [bioconda installation instructions](http://bioconda.github.io/user/install.html#install-conda). In addition, it is essential to install Snakemake; following the steps in the [Snakemake documentation](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html).

To run the pipeline, the user needs to create the conda environments first, which will take some minutes. This step is done automatically using the following command:

    snakemake --use-conda --conda-create-envs-only --conda-frontend mamba


### 2. Download the **SODAR** repository from Github.
Use git clone command to create a local copy.

    git clone https://github.com/f-erm/SODAR.git

### 3. Configure the pipeline.

Before executing the pipeline, the users must configure it according to their samples.

#### **a. config.yaml**

This is the pipeline configuration file, where you can tune all the available parameters to customise the uploading of the samples. An example file ([config-example.yaml)](https://github.com/f-erm/SODAR/blob/main/config-example.yaml) is included in the repository. Rename it to `config.yaml` and edit its contents.


| **Field name** 	| **Description**                  |
|------------	|-----------------------------------------------------	|
| **samples**     	| Path to the *samples.tsv* file         	|
| **out**       	| Path to output location |
| **log**        	| Path to log files location  	|
| **input_dir**        	| Path to FASTQ file folder    |
| **sample_id**        	| Sample unique identifier    |
| **landing_dir**        	| Path to landing directory  |
| **file_types**        	| List of all file types you want to upload  |
| **sample_type**        	| Choose from available sample types  |


#### **c. samples.tsv**

This table contains the name of each sample and the experimental condition it belongs to.

An example file ([samples-example.tsv)](https://github.com/f-erm/SODAR/blob/main/samples-example.tsv) is included in the repository. Rename it to `samples.tsv` and edit its contents. Mandatory columns include:
* "scATAC-seq samples" or some other supported sample type 
* ID
* Lab Register ID
* Date
* primer

For PacBio files different columns are required. See the samples_pacbio.schema.yaml schema for required columns.

### 4. Run the pipeline.

Once the pipeline is configured and conda environments are created, the user just needs to run i**SODAR** as follows:

    snakemake --use-conda --jobs 3

The mandatory arguments are:
* **--use-conda**: to install and use the conda environemnts.
* **-j**: number of threads/jobs provided to snakemake.


## Adjustments and file selection

### Technology platform 
To upload PacBio files set 'sample_type' to 'PacBio'. Inside your samples.txt, the first column should be named 'Long_read'. PacBio files are usually matched to their corresponding sample by folder and not by file name. See the next section on how to match folders to samples via the 'location' column. 

To implement other technology platforms, follow these 3 steps:
1) Create a new i_investigation.txt file with corresponding info. Link it in rule 'i_file'
2) Create a new samples schema for validation. Link it in rule 'common'
3) Adjust generation of 'a' file in file_generation.R, to make use of your technology platforms paramters

### File selection
By default, this pipeline scans the directory given in 'input_dir' for all files matching one of the given file types (e.g 'fastq.gz'). These are then matched by name to their respective sample, given in the samples.txt. 

Sometimes, files might not follow a set naming scheme, making it difficult to match files to their respective sample. For each file type you have listed in config.yaml, you'll need to specify how to match files of this type to their respective sample name. This is done in the specified section of the file_generation.R script. 

If you want to exclude files from the initial scan, simply rename them to some file type not given in config.yaml (e.g rename exlcude_this_file.fastq.gz to exlcude_this_file.fastq.gz.no).

Sometimes it is easier to just specify a certain folder, containing all files for a specifc sample. For example, you're sample might consist of many different file types and adding them all to the config file will take too long. In this case, simply add a column named 'location' to your 'samples.txt'. For each sample you want to upload this way, add the name of the respective folder, relative to the input directory, to the location column. Files uploaded this way, do not need to match their respective samples name. 

Important: Files not contained in one of the specified locations need to have unique names!!

## Quality of life improvements

### Sodar upload script

This fork adds a small script, which creates the new SODAR project and landing zone. Run it directly after the pipeline finishes. The required info will be taken from config.yaml. To use this script, just add your SODAR credentials at the designated spot.

### Slurm script

This fork adds a small script to run this pipeline via slurm, without the need for e.g a screen session. Just adjust the __submit_snakemake.sh__ and follow the given instructions.