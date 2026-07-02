import glob
import os



rule sodar_creation:
    input:
        landing_finish = "{}/landing.finish".format(config['landing_dir'])
    output:
        irods_script= expand("{landing}/fastq/irods.txt", landing = config['landing_dir'])
    params:
        out = config["out"],
        sample_ID=config['sample_id'],
        template="resources/make_input.sh",
        landing_dir=config['landing_dir'],
    resources:
        mem_mb=get_resource("default", "mem_mb"),
        walltime=get_resource("default", "walltime")
    log:
        "{}/sodar_creation.log".format(LOGDIR)
    benchmark:
        "{}/sodar_creation.bmk".format(LOGDIR)
    threads: 
        threads=get_resource("default", "threads")
    shell:
        """
        python3 sodar_upload.py
        """

rule sodar_creation:
    input:
        irods_script= expand("{landing}/fastq/irods.txt", landing=config['landing_dir']) 
    output:
        sh= expand("{landing}/fastq/sodar_upload.finish", landing = config['landing_dir'])
    params:
        out = config["out"],
        sample_ID=config['sample_id'],
        template="resources/make_input.sh",
        landing_dir=config['landing_dir'],
    resources:
        mem_mb=get_resource("upload", "mem_mb"),
        walltime=get_resource("upload", "walltime")
    log:
        "{}/irods.log".format(LOGDIR)
    benchmark:
        "{}/irods.bmk".format(LOGDIR)
    threads: 
        threads=get_resource("upload", "threads")
    shell:
        """
        bash {irods}
        touch {params.landing_dir}/fastq/sodar_upload.finish
        """
