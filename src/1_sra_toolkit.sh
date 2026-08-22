#!/bin/bash
#SBATCH --job-name=sra_toolkit
#SBATCH --partition=ripley
#SBATCH --output=logs/%x_%j.out
#SBATCH --erro=logs/%x_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=1:00:00

# Definir variables

CONTAINER="../../contenedores/sra_toolkit_latest.sif"

OUTDIR1="data/sra"
OUTDIR2="data/raw"
# Crear directorio de resultados y de salida
mkdir results
mkdir -p ${OUTDIR1} ${OUTDIR2}

# Crear loop con while
while read ID; do
        #Buscar y descargar el archivo .sra
        apptainer exec ${CONTAINER} \
        prefetch \
        -p -v \
        ${ID}\
        -O ${OUTDIR1}/\
        #Separar el archivo .sra en un archivo forward y un archivo reverse
        apptainer exec ${CONTAINER}\
        fasterq-dump\
        ${OUTDIR1}/$ID/$ID.sra\
        --split-files --outdir ${OUTDIR2}\
        --threads $SLURM_CPUS_PER_TASK
done < data/metadata/list.txt

#Comprimir los datos resultantes
pigz -p $SLURM_CPUS_PER_TASK ${OUTDIR2}/*.fastq
