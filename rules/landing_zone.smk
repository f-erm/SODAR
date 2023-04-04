import glob
import os

rule execute_landing:
    input:
        sh = "{}/make_input.sh".format(OUTDIR),
        csv = "{}/map_ln_to_fastq.csv".format(OUTDIR)
    output:
        folder = directory(expand("{landing}/{sample}",
            landing = config['landing_dir'], sample = config["sample_id"])),
        fastq=directory(expand("{landing}/{sample}/fastq",
            landing = config['landing_dir'], sample = config["sample_id"])),
        input=expand("{landing}/{sample}/fastq/landing.finish",
            landing = config['landing_dir'], sample = config["sample_id"])
    resources:
        mem_mb=get_resource("landing", "mem_mb"),
        walltime=get_resource("landing", "walltime")
    params:
        input_dir = config["input_dir"],
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
        mkdir -p {output.folder}
        mkdir -p {output.fastq}
        cp {params.input_dir}/*.fastq.gz {output.fastq}
        mv {input.sh} {params.landing}/{params.sample_id}/fastq
        mv {input.csv} {params.landing}/{params.sample_id}/fastq
        bash {params.landing}/{params.sample_id}/fastq/make_input.sh
        touch {params.landing}/{params.sample_id}/fastq/landing.finish
        """

