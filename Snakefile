# The main entry point of your workflow.
# After configuring, running snakemake -n in a clone of this repository should successfully execute a dry-run of the workflow.
import pandas as pd

report: "report/workflow.rst"
include: "rules/common.smk"
# Variable declaration
OUTDIR = config["out"]
LOGDIR = config["log"]


# Auxiliary functions
def get_resource(rule,resource):
    try:
        return config["resources"][rule][resource]
    except KeyError:
        return config["resources"]["default"][resource]

# Final output 
rule all:
    input:
        # The first rule should define the default target files
        # Subsequent target rules can be specified below. They should start with all_*.
        expand(["{OUTDIR}/{sample}.zip", "{OUTDIR}/map_In_to_fastq.csv"], 
                sample = config['sample_id'], OUTDIR = OUTDIR), 
                directory(expand(["{landing}/{sample}/fastq",
                          "{landing}/{sample}/input"], landing = config['landing_dir'], 
                          sample = config['sample_id']))

# Rule files
include: "rules/text_files.smk"
include: "rules/map_In_to_fastq.smk"
include: "rules/landing_zone.smk"
