# RNA-seq Pipeline for Novel Isoform Discovery in Yeast

configfile: "config.yaml"

# Sample names
SAMPLES = config["samples"]

# Final Deliverable
rule all:
    input:
        expand("results/qc/pretrim/{sample}_fastqc.html",  sample=SAMPLES),
        expand("results/qc/pretrim/{sample}_fastqc.zip",   sample=SAMPLES),
        expand("data/trimmed/{sample}_trimmed.fastq.gz",   sample=SAMPLES),
        expand("results/qc/posttrim/{sample}_trimmed_fastqc.html", sample=SAMPLES),
        expand("results/qc/posttrim/{sample}_trimmed_fastqc.zip",  sample=SAMPLES)
	# TODO: "results/qc/multiqc_report.html"	
	
# Quality control with FastQC
rule fastqc_raw:
    input:
        "data/raw/{sample}.fastq.gz"
    output:
        html="results/qc/pretrim/{sample}_fastqc.html",
        zip="results/qc/pretrim/{sample}_fastqc.zip"
    threads: config["threads"]["fastqc"]
    log:
        "logs/fastqc/pretrim/{sample}.log"
    shell:
        """
        fastqc {input} -o results/qc/pretrim > {log} 2>&1
        """

# TODO: Aggregate QC reports with MultiQC

# Trim and filter reads with fastp
rule fastp:
    input:
        "data/raw/{sample}.fastq.gz"
    output:
        trimmed="data/trimmed/{sample}_trimmed.fastq.gz",
        json="results/qc/{sample}_fastp.json",
        html="results/qc/{sample}_fastp.html"
    params:
        quality=config["params"]["fastp"]["quality"],
        min_length=config["params"]["fastp"]["min_length"]
    threads: config["threads"]["fastp"]
    log:
        "logs/fastp/{sample}.log"
    shell:
        """
        fastp -i {input} -o {output.trimmed} \
            -j {output.json} -h {output.html} \
            -q {params.quality} -l {params.min_length} \
            --thread {threads} > {log} 2>&1
        """

# Quality control with FastQC after trimming
rule fastqc_trimmed:
    input:
        "data/trimmed/{sample}_trimmed.fastq.gz"
    output:
        html="results/qc/posttrim/{sample}_trimmed_fastqc.html",
        zip="results/qc/posttrim/{sample}_trimmed_fastqc.zip"
    threads: config["threads"]["fastqc"]
    log:
        "logs/fastqc/posttrim/{sample}.log"
    shell:
        """
        fastqc {input} -o results/qc/posttrim > {log} 2>&1
        """
