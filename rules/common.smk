from snakemake.utils import validate
from pathlib import Path
import pandas as pd

##### load and validate config and sample sheets #####

configfile: "config.yaml"
validate(config, schema="../schemas/config.schema.yaml")

samples = pd.read_csv(config["samples"], sep="\t", encoding="latin1")
sample_type = samples.columns[0]
sample_type_config = config["sample_type"]

if sample_type_config == "PacBio":  
  validate(samples, schema="../schemas/samples_pacbio.schema.yaml")
else:
  validate(samples, schema="../schemas/samples.schema.yaml")

##### print date and time #####

# prints date and time, e.g. '2020-07-14T10:03:08'
DATETIME = "date +'%Y-%m-%dT%H:%M:%S'"
