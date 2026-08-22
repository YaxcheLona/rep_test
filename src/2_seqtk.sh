#SBATCH --partition=wanke
#SBATCH --output=logs/first.out
#SBATCH --erro=logs/second.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=1:00:00

#Definir variables
CONTAINER="containers/seqtk_latest.sif"

INPUT="data/raw"
OUTDIR="data/samp"

#Crear directorio de salida
mkdir -p ${OUTDIR}

#Crear loop con while
while read ID; do
       #Crear una muestra de 200k de lecturas para el archivo forward
        apptainer exec ${CONTAINER} \
    /opt/seqtk/seqtk \
    sample -s 10 \
    ${INPUT}/${ID}_1.fastq.gz \
    1000000 \
    | gzip -c > ${OUTDIR}/${ID}_1_s.fastq.gz\

       #Crear una muestra de 200k de lecturas para el archivo reverse
        apptainer exec ${CONTAINER} /opt/seqtk/seqtk\
        sample -s 10\
        ${INPUT}/${ID}_2.fastq.gz 1000000\
        | gzip -c  >  ${OUTDIR}/${ID}_2_s.fastq.gz
done < data/metadata/list.txt
