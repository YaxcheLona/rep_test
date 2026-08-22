#!/bin/bash
#SBATCH --job-name=trim_galore
#SBATCH --partition=ripley
#SBATCH --output=logs/%x_%j.out
#SBATCH --erro=logs/%x_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=1:00:00

#Definir variables
CONTAINER1="containers/trim_galore.sif"
CONTAINER2="containers/seqtk_latest.sif"

INPUT="data/samp"
OUTDIR1="results/trim_galore"
OUTDIR2="results/fasta"
OUTDIR3="results/int_fasta"
#Crear directorios de salida
mkdir -p ${OUTDIR1} ${OUTDIR2} ${OUTDIR3}

#Crear loop while
while read ID; do
        #Remover adaptadores y bases con una calidad menor a 20
        apptainer exec ${CONTAINER1}\
        trim_galore\
        -q 20\
        --paired\
        -fastqc -gzip --illumina ${INPUT}/${ID}_1_s.fastq.gz ${INPUT}/${ID}_2_s.fastq.gz\
        --output_dir ${OUTDIR1}
done < data/metadata/list.txt

#Transformar archivo fastq a formato fasta
while read ID; do

        apptainer exec ${CONTAINER2}\
        /opt/seqtk/seqtk\
        seq -a ${OUTDIR1}/${ID}_1_s_val_1.fq.gz   ${OUTDIR2}\
        sed '/^>/ s/$/f/' ${OUTDIR2}/${ID}_1.fa > ${OUTDIR2}/${ID}_1_f.fa\

        apptainer exec ${CONTAINER2}\
        /opt/seqtk/seqtk\
        seq -a ${OUTDIR1}/${ID}_2_s_val_2.fq.gz   ${OUTDIR2}\
        sed '/^>/ s/$/r/' ${OUTDIR2}/${ID}_2.fa > ${OUTDIR2}/${ID}_2_r.fa
done < data/metadata/list.txt

#Juntar secuencias en un solo archivo .fasta
while read ID; do
apptainer exec ${CONTAINER2} /opt/seqtk/seqtk mergepe ${OUTDIR2}/${ID}_1_f.fa ${OUTDIR2}/${ID}_2_r.fa > ${OUTDIR3}/${ID}_interlaced.fa
done < data/metadata/list.txt
