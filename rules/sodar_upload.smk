import glob
import os



rule sodar_creation:
    input:
        landing_finish = "{}/fastq/landing.finish".format(config['landing_dir'])
    output:
        irods_script= expand("{landing}/irods.txt", landing = config['landing_dir'])
    params:
        sample_ID=config['sample_id'],
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
        python3 sodar_upload.py {params.landing_dir}
        """

rule sodar_upload:
    input:
        irods_script= expand("{landing}/irods.txt", landing=config['landing_dir']) 
    output:
        upload_finish= expand("{landing}/sodar_upload.finish", landing = config['landing_dir'])
    params:
        sample_ID=config['sample_id'],
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
        bash {input.irods_script}
        touch {params.landing_dir}/sodar_upload.finish
        """
