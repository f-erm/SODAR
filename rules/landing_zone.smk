import glob
import os


rule execute_landing:
    input:
        sh = "{}/make_input.sh".format(OUTDIR),
        csv = "{}/map_ln_to_fastq.csv".format(OUTDIR)
    output:
        fastq=directory(expand("{landing}/fastq", landing=config['landing_dir'])),
        input=expand("{landing}/fastq/landing.finish", landing=config['landing_dir'])
    resources:
        mem_mb=get_resource("landing", "mem_mb"),
        walltime=get_resource("landing", "walltime")
    params:
        folder=directory(expand("{landing}", landing=config['landing_dir'])),
        input_dir=config["input_dir"],
        landing=config['landing_dir'],
        file_types = config["file_types"]
    log:
        "{}/landing_exec.log".format(LOGDIR)
    benchmark:
        "{}/landing_exec.bmk".format(LOGDIR)
    threads:
        threads=get_resource("landing", "threads")
    shell:
        r"""
        mkdir -p {output.fastq}
        # Copy all files of correct type from any depth under input_dir
        for ft in {params.file_types}; do
            find {params.input_dir} -type f -name "*$ft" -exec cp {{}} {output.fastq} \;
        done
        find {params.input_dir} -type f -name "*.md5" -exec cp {{}} {output.fastq} \;
        mv {input.sh} {params.landing}/fastq
        mv {input.csv} {params.landing}/fastq
        bash {params.landing}/fastq/make_input.sh
        touch {params.landing}/fastq/landing.finish
        #"""
