import glob
import os


if config["input_format"] in ["folder"]:
    rule execute_landing_folder:
        input:
            sh = "{}/make_input.sh".format(OUTDIR),
            csv = "{}/map_ln_to_fastq.csv".format(OUTDIR)
        output:
            fastq=directory(expand("{landing}/fastq", landing = config['landing_dir'])),
            input=expand("{landing}/fastq/landing.finish", landing = config['landing_dir'])
        resources:
            mem_mb=get_resource("landing", "mem_mb"),
            walltime=get_resource("landing", "walltime")
        params:
            folder = directory(expand("{landing}", landing = config['landing_dir'])),
            input_dir = config["input_dir"],
            landing = config['landing_dir'],
        log:
            "{}/landing_exec.log".format(LOGDIR)
        benchmark:
            "{}/landing_exec.bmk".format(LOGDIR)
        threads:
            threads=get_resource("landing", "threads")
        shell:
            """
            mkdir -p {output.fastq}
            #rsync -av --progress {params.input_dir}/*/*.fastq.gz {output.fastq} --exclude Undetermined*
            cp {params.input_dir}/*/*.fastq.gz {output.fastq}
            #rm -r {output.fastq}/Undertermined*
            mv {input.sh} {params.landing}/fastq
            mv {input.csv} {params.landing}/fastq
            bash {params.landing}/fastq/make_input.sh
            touch {params.landing}/fastq/landing.finish
            """

elif  config["input_format"] in ["list"]:
    rule execute_landing_list:
        input:
            sh = "{}/make_input.sh".format(OUTDIR),
            csv = "{}/map_ln_to_fastq.csv".format(OUTDIR)
        output:
            fastq=directory(expand("{landing}/fastq", landing = config['landing_dir'])),
            input=expand("{landing}/fastq/landing.finish", landing = config['landing_dir'])
        resources:
            mem_mb=get_resource("landing", "mem_mb"),
            walltime=get_resource("landing", "walltime")
        params:
            folder = directory(expand("{landing}", landing = config['landing_dir'])),
            input_dir = config["input_dir"],
            input_format = config["input_format"],
            landing = config['landing_dir']
        log:
            "{}/landing_exec.log".format(LOGDIR)
        benchmark:
            "{}/landing_exec.bmk".format(LOGDIR)
        threads:
            threads=get_resource("landing", "threads")
        shell:
            """
            mkdir -p {output.fastq}
            cp {params.input_dir}/*.fastq.gz {output.fastq}
            mv {input.sh} {params.landing}/fastq
            mv {input.csv} {params.landing}/fastq
            bash {params.landing}/fastq/make_input.sh
            touch {params.landing}/fastq/landing.finish
            """
