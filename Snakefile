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
        expand(["{OUTDIR}/a_{sample}.txt", 
                "{OUTDIR}/s_{sample}.txt",
                "{OUTDIR}/i_Investigation.txt"], sample=config['sample_id'], OUTDIR=OUTDIR)

# Rule files
include: "rules/text_files.smk"
