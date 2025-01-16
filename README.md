# Genome Assembly and Annotation Pipeline

## Overview
This pipeline automates the process of genome assembly, variant calling, and annotation using popular bioinformatics tools such as `minimap2`, `samtools`, `bcftools`, and `prokka`. The script processes a reference genome and a query genome, producing a clean assembly and annotated genome as outputs.

## Requirements
The following tools are required to run this pipeline:
- `minimap2 >= 2.24`
- `samtools >= 1.15`
- `bcftools >= 1.15`
- `prokka >= 1.14`

It is recommended to install these tools using Conda for compatibility.

## Installation

### Using Conda
1. Install Miniconda if not already installed:
   ```bash
   wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
   bash Miniconda3-latest-Linux-x86_64.sh
   ```
2. Create and activate the environment:
   ```bash
   conda create -n genome_pipeline -c bioconda minimap2 samtools bcftools prokka
   conda activate genome_pipeline
   ```

### Manual Installation
Ensure the tools are installed and accessible in your `PATH`.

## Usage

### Command
Run the pipeline as follows:
```bash
./pipeline.sh <reference.fasta> <query.fasta>
```

### Example
```bash
./pipeline.sh example_reference.fasta example_query.fasta
```

## Output
The pipeline produces the following outputs:

1. **Clean Assembly**:
   - `clean_assembly.fasta`: The final polished genome sequence.

2. **Annotation Results** (Prokka):
   - `prokka_output/clean_assembly_annotation.gff`: GFF file containing genome annotations.
   - `prokka_output/clean_assembly_annotation.gbk`: GenBank file.
   - `prokka_output/clean_assembly_annotation.faa`: Predicted protein sequences.
   - `prokka_output/clean_assembly_annotation.ffn`: Nucleotide sequences of predicted genes.

3. **Variants**:
   - `bcftools_output/variants.vcf.gz`: Compressed VCF file of called variants.
   - `bcftools_output/variants.vcf.gz.tbi`: Index of the VCF file.

4. **Intermediate Files**:
   - Alignment and indexing files in `minimap2_output/` and `samtools_output/`.

## Notes
- Ensure the input files are in valid FASTA format.
- Use small example datasets to test the pipeline before scaling up.
