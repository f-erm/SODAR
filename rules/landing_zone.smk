import glob
import os

rule landing_directory:
    output:
        fastq=directory(expand("{landing}/{sample}/fastq", 
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
        cp {params.input_dir}/*.fastq.gz {output.fastq}
        """

rule execute_landing:
    input:
        sh = "{}/make_input.sh".format(OUTDIR),
        csv = "{}/map_ln_to_fastq.csv".format(OUTDIR)
    output:
        input=expand("{landing}/{sample}/input/fastq/map_ln_to_fastq.csv", 
              landing = config['landing_dir'], sample = config["sample_id"])
    resources:
        mem_mb=get_resource("landing", "mem_mb"),
        walltime=get_resource("landing", "walltime")
    params:
        landing = config['landing_dir'],
        sample_id = config["sample_id"]
    log:
        "{}/landing_exec.log".format(LOGDIR)
    benchmark:
        "{}/landing_exec.bmk".format(LOGDIR)
    threads:
        threads=get_resource("landing", "threads")
    shell:
        """
        mv {input.sh} {params.landing}/{params.sample_id}/fastq
        mv {input.csv} {params.landing}/{params.sample_id}/fastq
        bash {params.landing}/{params.sample_id}/fastq/make_input.sh
        """

