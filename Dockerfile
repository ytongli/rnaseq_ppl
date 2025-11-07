# Use Miniconda as base image
FROM continuumio/miniconda3:latest

# Metadata
LABEL maintainer="ytongli@umich.com"
LABEL description="RNA-seq pipeline with Snakemake for novel isoform discovery"
LABEL version="1.0"

# Set environment to non-interactive (prevents prompts during install)
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    curl \
    git \
    vim \
    nano \
    procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install mamba (faster than conda)
RUN conda install -n base -c conda-forge mamba -y

# Create environment with all tools
RUN mamba create -n rnaseq -c conda-forge -c bioconda \
    python=3.10 \
    snakemake-minimal \
    fastqc \
    fastp \
    star \
    samtools \
    stringtie \
    gffcompare \
    multiqc \
    sra-tools \
    pandas \
    -y && \
    conda clean -afy

# Make RUN commands use the conda environment
SHELL ["conda", "run", "-n", "rnaseq", "/bin/bash", "-c"]

# Activate conda environment in bash
RUN echo "source activate rnaseq" >> ~/.bashrc

# Set PATH so conda environment is used
ENV PATH=/opt/conda/envs/rnaseq/bin:$PATH

# Set working directory
WORKDIR /pipeline

# Entry point - activate environment and start bash
ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "rnaseq"]
CMD ["/bin/bash"]
