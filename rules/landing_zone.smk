import glob
import os


rule execute_landing:
    input:
        sh = "{}/make_input.sh".format(OUTDIR),
        csv = "{}/map_ln_to_fastq.csv".format(OUTDIR),
        csv_locations = "{}/map_locations.csv".format(OUTDIR)
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

        # Copy and rename all files with given location
        PRUNE=""
        while IFS=',' read sample_name path
        do
          cp -r {params.input_dir}/$path {output.fastq}/$sample_name
          if [ -z "$PRUNE" ]; then
            PRUNE="-path \"$path\""
          else
            PRUNE="$PRUNE -o -path \"$path\""
          fi
        done < {input.csv_locations}
        if [ -n "$PRUNE" ]; then
          FIND_EXPR="( $PRUNE ) -prune -o"
        else
          FIND_EXPR=""
        fi

        # Copy all remaining files.
        for ft in {params.file_types}; do
            find {params.input_dir} $FIND_EXPR -type f -name "*$ft" -exec cp {{}} {output.fastq} \;
        done
        find {params.input_dir} $FIND_EXPR -type f -name "*.md5" -exec cp {{}} {output.fastq} \;

        # Setup and run make_input.sh
        mv {input.sh} {params.landing}/fastq
        mv {input.csv} {params.landing}/fastq
        mv {input.csv_locations} {params.landing}/fastq
        bash {params.landing}/fastq/make_input.sh
        touch {params.landing}/fastq/landing.finish
        #"""
