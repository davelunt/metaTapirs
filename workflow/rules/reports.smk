# ==================================================
# METATAPIRS REPORT GENERATION
# ==================================================
# A workflow reporting on QC and taxonomic assignment
# fastp reports are written from the qc.smk rule

configfile: "config.yaml"
# report: "reports/snakemake-report.html"

# --------------------------------------------------
# Snakemake, report
# --------------------------------------------------

# rule snakemake_report:  # this only works when run after the workflow has completed, so unsure how to work it into the snakemake
#    conda:
#        "../envs/environment.yaml"
#     output:
#         "reports/snakemake-report.html"
#     shell:
#         "snakemake --report {output}"

# --------------------------------------------------
# Snakemake, plot DAG figure of workflow
# --------------------------------------------------

rule plot_workflow_DAG:
    output:
        "reports/dag_rulegraph.png"
    shell:
        "snakemake --rulegraph | dot -Tpng > {output}"

# --------------------------------------------------
# Conda, archive environment
# --------------------------------------------------

rule conda_archive-env:
    input:
        "envs/{ENVNAME}.yaml"
    output:
        "results/archived_envs/{ENVNAME}.yaml"
    shell:
        "conda env export -n {input} > {output}"

# --------------------------------------------------
# Seqkit, write report on 02_trimmed files
# for each library make a report on all files
# --------------------------------------------------

rule seqkit-stats_trimmedfiles:
    input:
        "results/02_trimmed/{LIBRARIES}/{SAMPLES}.fastq.gz"
    threads:
        4  # -j
    output:
        tsv = "results/seqkit/{LIBRARIES}/{SAMPLES}.trimmed.seqkit-stats.tsv",
        md = "results/seqkit/{LIBRARIES}/{SAMPLES}.trimmed.seqkit-stats.md",
    shell:
        """
        seqkit stats -i {input} -b -e -T -j {threads} -o {output.tsv} ;
        csvtk csv2md {output.tsv} -t -o {output.md}
        """


#---------------------------------------------------
# MultiQC, aggregate QC reports as html report
#-----------------------------------------------------

# rule multiqc:
#     conda:
#         "..envs/environment.yaml"
#     input:
#         "reports/fastp/{library}/"
#     output:
#         filename = "{library}.multiqc.html",  # report filename
#         outdir = directory("reports/multiqc/")
#     params:
#         overwrite = "-f",  # overwrite previous multiqc output
#         zip = "-z",  # compress the multiqc data dir
#         quiet = "-q", # only log errors
#         dirnames = "-dd 1",  # prepend library dir name to sample names
#     shell:
#         "multiqc {input} \
#           -n {output.filename} \
#           -o {output.outdir} \
#           {params.dirnames} \
#           {params.overwrite} \
#           {params.zip} \
#           {params.quiet} \
#           "
