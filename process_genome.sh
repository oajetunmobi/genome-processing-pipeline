#!/bin/bash

# Ensure the script exits if any command fails
set -e

# Usage check
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <reference.fasta> <query.fasta>"
    exit 1
fi

# Input arguments
REFERENCE=$1
QUERY=$2

# Base names for files
REFERENCE_BASE=$(basename "$REFERENCE" .fasta)
QUERY_BASE=$(basename "$QUERY" .fa)

# Create output directories
mkdir -p minimap2_output samtools_output bcftools_output prokka_output

# Step 1: Index the reference genome with minimap2
echo "Indexing reference genome..."
minimap2 -d minimap2_output/"$REFERENCE_BASE".mmi "$REFERENCE"

# Step 2: Align the query to the reference
echo "Aligning query to reference..."
minimap2 -ax asm5 minimap2_output/"$REFERENCE_BASE".mmi "$QUERY" > minimap2_output/"$QUERY_BASE"_vs_"$REFERENCE_BASE".sam

# Step 3: Convert SAM to BAM
echo "Converting SAM to BAM..."
samtools view -bS minimap2_output/"$QUERY_BASE"_vs_"$REFERENCE_BASE".sam > samtools_output/"$QUERY_BASE"_vs_"$REFERENCE_BASE".bam

# Step 4: Sort the BAM file
echo "Sorting BAM file..."
samtools sort -o samtools_output/"$QUERY_BASE"_vs_"$REFERENCE_BASE".sorted.bam samtools_output/"$QUERY_BASE"_vs_"$REFERENCE_BASE".bam

# Step 5: Index the sorted BAM file
echo "Indexing sorted BAM file..."
samtools index samtools_output/"$QUERY_BASE"_vs_"$REFERENCE_BASE".sorted.bam

# Step 6: Extract primary alignments
echo "Extracting primary alignments..."
samtools view -h -F 2048 samtools_output/"$QUERY_BASE"_vs_"$REFERENCE_BASE".sorted.bam > samtools_output/primary_alignments.sam

# Step 7: Generate variant calls
echo "Calling variants..."
samtools mpileup -uf "$REFERENCE" samtools_output/"$QUERY_BASE"_vs_"$REFERENCE_BASE".sorted.bam | \
bcftools call -c -v -o bcftools_output/variants.vcf

# Step 8: Compress and index the VCF file
echo "Compressing and indexing VCF..."
bgzip -c bcftools_output/variants.vcf > bcftools_output/variants.vcf.gz
bcftools index bcftools_output/variants.vcf.gz

# Step 9: Generate the clean assembly
echo "Generating clean assembly..."
cat "$REFERENCE" | bcftools consensus bcftools_output/variants.vcf.gz > clean_assembly.fasta

# Step 10: Annotate the clean assembly with Prokka
echo "Annotating clean assembly..."
prokka --outdir prokka_output --prefix clean_assembly_annotation --force clean_assembly.fasta

echo "Pipeline complete! Results are in the respective directories."
