# The main entry point of your workflow.
# After configuring, running snakemake -n in a clone of this repository should successfully execute a dry-run of the workflow.
import pandas as pd

# report: "report/workflow.rst"
include: "rules/common.smk"
# Variable declaration
OUTDIR = config["out"]
LOGDIR = config["log"]
UPLOAD = config["upload_to_sodar"]


# Auxiliary functions
def get_resource(rule,resource):
    try:
        return config["resources"][rule][resource]
    except KeyError:
        return config["resources"]["default"][resource]

# Final output 
all_inputs = [
    expand("{OUTDIR}/{sample}.zip",
           sample=config["sample_id"],
           OUTDIR=OUTDIR),
    expand("{landing}/fastq/landing.finish",
           landing=config["landing_dir"]),
]

if UPLOAD:
    all_inputs.extend([
        expand("{landing}/irods.txt",
               landing=config["landing_dir"]),
        expand("{landing}/sodar_upload.finish",
               landing=config["landing_dir"]),
    ])

rule all:
    input:
        all_inputs

# Rule files
include: "rules/text_files.smk"
include: "rules/make_input.smk"
include: "rules/landing_zone.smk"
if UPLOAD:
    include: "rules/sodar_upload.smk"
