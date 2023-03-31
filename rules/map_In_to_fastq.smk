import glob
import os

rule map_In_to_fastq:
    output:
        csv=expand("{OUTDIR}/map_In_to_fastq.csv", OUTDIR = OUTDIR)
    resources:    
        mem_mb=get_resource("default", "mem_mb"),
        walltime=get_resource("default", "walltime")
    params:
        input_dir = config["input_dir"],
        out = config["out"]
    log:
        "{}/map_In_to_fastq.log".format(LOGDIR)
    conda:
        "../envs/r.yaml"
    benchmark:
        "{}/map_In_to_fastq.bmk".format(LOGDIR)
    threads:
        threads=get_resource("default", "threads")
    script:
        "../scripts/map_In_to_fastq.R"
