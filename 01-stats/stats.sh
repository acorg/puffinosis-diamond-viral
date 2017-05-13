#!/bin/bash -e

. $HOME/.virtualenvs/35/bin/activate
. ../common.sh

task=$1
log=$logDir/$task.log
fastq=$dataDir/$task.tr.fastq.gz
countOut=$statsDir/$task.read-count
MD5Out=$statsDir/$task.md5
lengthDistributionOut=$statsDir/$task.read-lengths

if [ ! -f $fastq ]
then
    echo "  FASTQ file '$fastq' does not exist." >> $log
    exit 1
fi

function stats()
{
    # Write a file of frequency of read lengths.
    zcat $fastq | filter-fasta.py --fastq |
        awk 'NR % 4 == 2 {print length}' | sort | uniq -c | sort -nr > $lengthDistributionOut

    # The total number of reads is the sum of the above length frequencies.
    echo -n "$fastq " > $countOut
    awk '{sum += $1} END {print sum}' < $lengthDistributionOut >> $countOut

    md5sum $fastq > $MD5Out
}

echo "01-stats on task $task started at `date`" >> $log
echo "  FASTQ is $fastq" >> $log

if [ $SP_SIMULATE = "1" ]
then
    echo "  This is a simulation." >> $log
else
    echo "  This is not a simulation." >> $log
    if [ $SP_SKIP = "1" ]
    then
        echo "  Stats is being skipped on this run." >> $log
    elif [ -f $countOut -a -f $MD5Out -a -f $lengthDistributionOut ]
    then
        if [ $SP_FORCE = "1" ]
        then
            echo "  Pre-existing output files $countOut, $MD5Out, and $lengthDistributionOut exist, but --force was used. Overwriting." >> $log
            stats
        else
            echo "  Will not overwrite pre-existing output files $countOut, $MD5Out, and $lengthDistributionOut. Use --force to make me." >> $log
        fi
    else
        echo "  Pre-existing output files $countOut, $MD5Out, and $lengthDistributionOut do not all exist. Collecting stats." >> $log
        stats
    fi
fi

echo "01-stats on task $task stopped at `date`" >> $log
echo >> $log
