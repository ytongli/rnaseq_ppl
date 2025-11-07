# RNA-seq Pipeline Design Document
## Novel Isoform Discovery Using StringTie

---

## 1. Project Overview

### 1.1 Project Goal
Develop a Snakemake-based RNA-seq analysis pipeline to identify high-confidence novel isoforms from two replicated RNA-seq samples using reference-guided transcriptome assembly.

### 1.2 Research Question
**"What novel isoforms are consistently detected across both samples, and how do they compare to the reference annotation?"**

### 1.3 Expected Outcomes
- Assembled transcriptome with novel isoform annotations
- Classification of novel vs. known transcripts
- High-confidence novel isoforms supported by both samples
- Quality metrics and summary statistics

---

## 2. Input Data

### 2.1 Samples
| Sample ID | File Path | Description |
|-----------|-----------|-------------|
| SRR4238351 | `data/raw/SRR4238351.fastq.gz` | Sample 1 (single-end) |
| SRR4238352 | `data/raw/SRR4238352.fastq.gz` | Sample 2 (single-end) |

### 2.2 Reference Data Required
- Reference genome (FASTA)
- Reference annotation (GTF)
- STAR genome index (or files to build it)

---

## 3. Pipeline Architecture

### 3.1 Workflow Overview

```
Raw FASTQ files (SRR4238351, SRR4238352)
    ↓
FastQC (initial quality control)
    ↓
fastp (adapter trimming + quality filtering)
    ↓
STAR (alignment to reference genome)
    ↓
StringTie (per-sample transcriptome assembly)
    │
    ├── SRR4238351.gtf
    └── SRR4238352.gtf
    ↓
StringTie merge (combine both sample assemblies)
    ↓ merged.gtf
gffcompare (compare merged GTF to reference annotation)
    ↓
Filter for novel isoforms present in BOTH samples
    ↓
Summary report generation
    ↓
MultiQC (aggregate all QC metrics)
```

### 3.2 Pipeline Stages

#### Stage 1: Quality Control
- **Tool**: FastQC v0.11.9+
- **Input**: Raw FASTQ files
- **Output**: HTML reports with quality metrics
- **Purpose**: Assess read quality, adapter content, GC bias

#### Stage 2: Read Preprocessing
- **Tool**: fastp v0.23.0+
- **Input**: Raw FASTQ files
- **Output**: Trimmed FASTQ files, JSON/HTML reports
- **Parameters**:
  - Quality threshold: Q20
  - Minimum read length: 50bp
  - Adapter auto-detection enabled
- **Purpose**: Remove adapters, low-quality bases, short reads
