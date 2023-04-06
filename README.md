# SODAR
This snakemake pipeline aims at facilitating the uploading of samples to the **SODAR** platform.

<img src="resources/img/sodar_cacaolat_logo.png" width="100">

## Authors

* Coral Fustero-Torre

## Setup

For setting up the pipeline, three configuration files need to be modified. See the *Usage* section for more details.

### Configuration files

* **config.yaml** contains all pipeline parameters.
* **samples.tsv**: contains metadata annotations. An example file can be downloaded, have in mind not all columns will be necessary.

# Usage

### 1. Set up the environment

**SODAR** requires the installation of the conda package manager in order to work. Please install conda by following the [bioconda installation instructions](http://bioconda.github.io/user/install.html#install-conda). In addition, it is essential to install Snakemake; following the steps in the [Snakemake documentation](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html).

To run the pipeline, the user needs to create the conda environments first, which will take some minutes. This step is done automatically using the following command:

    snakemake --use-conda --conda-create-envs-only --conda-frontend mamba


### 2. Download the **SODAR** repository from Github.
Use git clone command to create a local copy.

    git clone https://github.com/cfusterot/SODAR.git

### 3. Configure the pipeline.

Before executing the pipeline, the users must configure it according to their samples.

#### **a. config.yaml**

This is the pipeline configuration file, where you can tune all the available parameters to customise the uploading of the samples. An example file ([config-example.yaml)](https://github.com/cfusterot/SODAR/blob/main/config-example.yaml) is included in the repository. Rename it to `config.yaml` and edit its contents.


| **Field name** 	| **Description**                  |
|------------	|-----------------------------------------------------	|
| **samples**     	| Path to the *samples.tsv* file         	|
| **out**       	| Path to output location |
| **log**        	| Path to log files location  	|
| **input_dir**        	| Path to FASTQ file folder    |
| **sample_id**        	| Sample unique identifier    |
| **landing_dir**        	| Path to landing directory  |

#### **c. samples.tsv**

This table contains the name of each sample and the experimental condition it belongs to.

An example file ([samples-example.tsv)](https://github.com/cfusterot/SODAR/blob/main/samples-example.tsv) is included in the repository. Rename it to `samples.tsv` and edit its contents. Mandatory columns include:
* scATAC-seq samples
* ID
* Lab Register ID
* Date
* primer

### 4. Run the pipeline.

Once the pipeline is configured and conda environments are created, the user just needs to run i**SODAR** as follows:

    snakemake --use-conda --jobs 3

The mandatory arguments are:
* **--use-conda**: to install and use the conda environemnts.
* **-j**: number of threads/jobs provided to snakemake.
