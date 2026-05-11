import glob
import os


rule make_input:
    output:
        sh="{}/make_input.sh".format(OUTDIR)
    params:
        out = config["out"],
        sample_ID=config['sample_id'],
        template="resources/make_input.sh",
        landing_dir=config['landing_dir'],
        file_types=" ".join(f'"{x}"' for x in config["file_types"])
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
        cp {params.template} {params.out}/
        sed -i 's#/fast/home/projects/ludwig_cubi/fastq#{params.landing_dir}/fastq#g' {output.sh}
        sed -i 's#/fast/home/projects/ludwig_cubi/work#{params.landing_dir}#g' {output.sh}
        sed -i "s#extensions=(.*)#extensions=({params.file_types})#g" {output.sh}
        """

