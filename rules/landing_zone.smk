import glob
import os

rule landing_directory:
    output:
        fastq=directory(expand("{landing}/{sample}/fastq", 
              landing = config['landing_dir'], sample = config["sample_id"])),
        input=directory(expand("{landing}/{sample}/input", 
              landing = config['landing_dir'], sample = config["sample_id"]))
    resources:
        mem_mb=get_resource("landing", "mem_mb"),
        walltime=get_resource("landing", "walltime")
    params:
        landing = config['landing_dir'],
        input_dir = config["input_dir"],
        sample_id = config["sample_id"]
    log:
        "{}/landing_directory.log".format(LOGDIR)
    benchmark:
        "{}/landing_directory.bmk".format(LOGDIR)
    threads:
        threads=get_resource("landing", "threads")
    shell:
        """
        mkdir {output.fastq}
        mkdir {output.input}
        cp {params.input_dir}/*.fastq.gz {output.fastq}
        """
