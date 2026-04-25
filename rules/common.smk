from snakemake.utils import validate
from pathlib import Path
import pandas as pd

##### load and validate config and sample sheets #####

configfile: "config.yaml"
validate(config, schema="../schemas/config.schema.yaml")

samples = pd.read_csv(config["samples"], sep="\t").
sample_type = df.columns[0]
sample_type_config = config["sample_type"]

if sample_type_config is "other":
    sample_type_config = "samples"

if sample_type is not sample_type_config:
    raise ValueError(
        f"Sample type of sample sheet '{sample_type}' does not match sample type of config file '{sample_type_config}"
    )

validate(samples, schema="../schemas/samples.schema.yaml")

##### print date and time #####

# prints date and time, e.g. '2020-07-14T10:03:08'
DATETIME = "date +'%Y-%m-%dT%H:%M:%S'"
