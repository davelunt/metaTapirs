# ==============================================================================
# BLASTN ANALYSIS
# ==============================================================================

# ------------------------------------------------------------------------------
# BLAST, sequence similarity search
# ------------------------------------------------------------------------------

rule blast:
    input:
        query = "results/08_dechimera/{LIBRARIES}/{SAMPLES}.nc.fasta",
    output:
        blast = "results/blast/{LIBRARIES}/{SAMPLES}.blast.tsv"
    params:
        outformat = "'6 qseqid stitle sacc staxids pident qcovs evalue bitscore'",
        evalue = float(config["BLAST_min_evalue"])
    shell:
        "blastn \
        -query {input.query} \
        -db {config[blast_db]} \
        -outfmt {params.outformat} \
        -perc_identity {config[BLAST_min_perc_ident]} \
        -evalue {params.evalue} \
        -max_target_seqs {config[BLAST_max_target_seqs]} \
        -num_threads {config[BLAST_threads]} \
        -out {output.blast}"

# ------------------------------------------------------------------------------
# TAXONOMY TO BLAST
# ------------------------------------------------------------------------------

rule taxonomy_to_blast:
    input:
        config['taxdump'] + '/names.dmp',
        blast = "results/blast/{LIBRARIES}/{SAMPLES}.blast.tsv"
    params:
        taxdump = config['taxdump']
    output:
        blast_tax = "results/blast_tax/{LIBRARIES}/{SAMPLES}.blast.tax.tsv"
    script:
        "../scripts/taxonomy_to_blast.py"
