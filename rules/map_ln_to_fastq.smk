import glob
import os

rule map_In_to_fastq:
    output:
        csv=expand("{OUTDIR}/map_ln_to_fastq.csv", OUTDIR = OUTDIR)
    resources:    
        mem_mb=get_resource("default", "mem_mb"),
        walltime=get_resource("default", "walltime")
    params:
        samples = config["samples"],
        input_dir = config["input_dir"],
        input_format = config["input_format"],
        out = config["out"]
    log:
        "{}/map_ln_to_fastq.log".format(LOGDIR)
    conda:
        "../envs/r.yaml"
    benchmark:
        "{}/map_In_to_fastq.bmk".format(LOGDIR)
    threads:
        threads=get_resource("default", "threads")
    script:
        "../scripts/map_ln_to_fastq.R"

rule make_input:
    output:
        sh="{}/make_input.sh".format(OUTDIR)
    params:
        sample_ID=config['sample_id'],
        template="resources/make_input.sh"
    resources:
        mem_mb=get_resource("default", "mem_mb"),
        walltime=get_resource("default", "walltime")
    log:
        "{}/make_input.log".format(LOGDIR)
    benchmark:
        "{}/make_input.bmk".format(LOGDIR)
    threads: 
        threads=get_resource("default", "threads")
    shell:
        """
        sed 's/PXXXX/{params.sample_ID}/g' {params.template} > {output.sh}
        """

