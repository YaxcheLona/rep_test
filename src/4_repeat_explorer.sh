#!/bin/bash
#SBATCH --job-name=repex
#SBATCH --partition=ripley
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=20G
#SBATCH --time=04:00:00

#Definir variables
CONTAINER="../../contenedores/repeatexplorer_2.3.8.sif"

OUTDIR="results/rep_output"

#Crear directorios de salida
mkdir ${OUTDIR}

#Realizar todo el procedimiento de RepeatExplorer2
while read ID; do
        apptainer exec --bind /srv/bishop/phylogenomics/phylogen5/rep_test/results:/results\
        ${CONTAINER}\
        /repex_tarean/seqclust\
        -p -v ${OUTDIR}\
        /results/int_fasta/${ID}_interlaced.fa
done < data/metadata/list.txt
