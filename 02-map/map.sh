#!/bin/bash -e

. $HOME/.virtualenvs/35/bin/activate
. ../common.sh

task=$1
log=$logDir/$task.log
bwadb=$HOME/scratch/genomes/homo-sapiens/homo-sapiens
fastq=$dataDir/$task.tr.fastq.gz
out=$task-unmapped.fastq.gz

echo "02-map on task $task started at `date`" >> $log
echo "  FASTQ is $fastq" >> $log

if [ ! -f $fastq ]
then
    echo "  FASTQ file '$fastq' does not exist." >> $log
    exit 1
fi

if [ ! -f $bwadb.bwt ]
then
    echo "  BWA database file '$bwadb.bwt' does not exist." >> $log
    exit 1
fi

function skip()
{
    # Copy our input FASTQ to our output unchanged.
    cp $fastq $out
}

function map()
{
    local sam=$task.sam
    local bamtmp=$task.tmp.bam
    local bam=$task.bam

    # Map FASTQ to human genome.
    echo "  bwa mem started at `date`" >> $log
    bwa mem -t 24 $bwadb $fastq > $sam
    echo "  bwa mem stopped at `date`" >> $log

    # Convert SAM to BAM.
    echo "  samtools sam -> bam conversion started at `date`" >> $log
    samtools view --threads 24 -bS $sam > $bamtmp
    rm $sam
    echo "  samtools sam -> bam conversion stopped at `date`" >> $log

    # Sort BAM.
    echo "  samtools sort started at `date`" >> $log
    samtools sort --threads 24 -o $bam $bamtmp
    rm $bamtmp
    echo "  samtools sort stopped at `date`" >> $log

    # Extract the unmapped reads.
    echo "  print-unmapped-sam.py started at `date`" >> $log
    print-unmapped-sam.py $bam | gzip > $out
    echo "  print-unmapped-sam.py stopped at `date`" >> $log
}


if [ $SP_SIMULATE = "1" ]
then
    echo "  This is a simulation." >> $log
else
    echo "  This is not a simulation." >> $log
    if [ $SP_SKIP = "1" ]
    then
        echo "  Mapping is being skipped on this run." >> $log
        skip
    elif [ -f $out ]
    then
        if [ $SP_FORCE = "1" ]
        then
            echo "  Pre-existing output file $out exists, but --force was used. Overwriting." >> $log
            map
        else
            echo "  Will not overwrite pre-existing output file $out. Use --force to make me." >> $log
        fi
    else
        echo "  Pre-existing output file $out does not exist. Mapping." >> $log
        map
    fi
fi

echo "02-map on task $task stopped at `date`" >> $log
echo >> $log
