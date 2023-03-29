# The main entry point of your workflow.
# After configuring, running snakemake -n in a clone of this repository should successfully execute a dry-run of the workflow.
import pandas as pd

report: "report/workflow.rst"
# Include rule files
include: "rules/common.smk"
# Variable declaration
OUTDIR = config["out"]
LOGDIR = config["log"]

try:
    samples = pd.read_csv(config["samples"], sep="\t", comment="#").set_index("sample", drop=False)
    validate(samples, schema="schemas/samples.schema.yaml")
except FileNotFoundError:
    warning(f"ERROR: the samples file ({config['samples']}) does not exist. Please see the README file for details. Quitting now.")
    sys.exit(1)

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
                "{OUTDIR}/s_{sample}.txt"], sample=samples['sample'], OUTDIR=OUTDIR)

# Rule files
include: "rules/general.smk"
