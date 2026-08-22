#!/bin/bash
#SBATCH --job-name=test
#SBATCH --partition=wanke
#SBATCH --output=logs/repex.out
#SBATCH --error=logs/repex.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=20G
#SBATCH --time=04:00:00

#Definir variables
CONTAINER="containers/repeatexplorer_2.3.8.sif"

OUTDIR="results/rep_output"

#Crear directorios de salida
mkdir ${OUTDIR}

#Realizar todo el procedimiento de RepeatExplorer2
while read ID; do
        apptainer exec --bind /home/xa04/rep_test/results:/results\
        ${CONTAINER}\
        /repex_tarean/seqclust\
        -p -v ${OUTDIR}\
        /results/int_fasta/${ID}_interlaced.fa
done < data/metadata/list.txt
