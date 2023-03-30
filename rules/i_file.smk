import glob
import os

rule i_file:
    input:
        sample_ID=
        template="resources/i_Investigation.txt"
    output:
        i="{}/sample}}/qc/fastqc/{{sample}}.{{unit}}.r{{read}}_fastqc.html".format(OUTDIR),
# the suffix _fastqc.zip is necessary for multiqc to find the file. If not using multiqc, you are free to choose an arbitrary filename
    resources:
        mem_mb=get_resource("i_file", "mem_mb"),
        walltime=get_resource("i_file", "walltime")
    log:
        "{}/{{sample}}/ifile.log".format(LOGDIR)
    benchmark:
        "{}/{{sample}}/ifile.bmk".format(LOGDIR)
    threads: 
        threads=get_resource("fastqc", "threads")
    shell:
        """
        sed '2~'s/$/\(.\{4\}\)//' myfile > newfile
        """
