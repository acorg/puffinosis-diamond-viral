#!/bin/bash -e

. $HOME/.virtualenvs/35/bin/activate
. ../common.sh

# The log file is the top-level log file, seeing as this step is a
# 'collect' step that is only run once.
log=$logFile

echo "05-sample-count started at `date`" >> $log

sample=$(sampleName)

# Find the sequence files that correspond to this sample.
tasks=$(tasks $sample)

if [ -z "$tasks" ]
then
    echo "  No FASTQ matches for sample '$sample' found!" >> $log
    exit 1
fi

out=$statsDir/$sample.read-count

function skip()
{
    # We're being skipped. Make an output file with a zero count, if the
    # output file doesn't already exist.

    [ -f $out ] || echo "$sample 0" > $out
}

function sample_count()
{
    echo "  sample count started at `date`" >> $log
    for task in $tasks
    do
        cat $statsDir/$task.read-count
    done | awk '{sum += $2} END {printf "'$sample' %d\n", sum}' > $out
    echo "  sample count stopped at `date`" >> $log
}


if [ $SP_SIMULATE = "1" ]
then
    echo "  This is a simulation." >> $log
else
    echo "  This is not a simulation." >> $log
    if [ $SP_SKIP = "1" ]
    then
        echo "  Sample count is being skipped on this run." >> $log
        skip
    elif [ -f $out ]
    then
        if [ $SP_FORCE = "1" ]
        then
            echo "  Pre-existing output file $out exists, but --force was used. Overwriting." >> $log
            sample_count
        else
            echo "  Will not overwrite pre-existing output file $out. Use --force to make me." >> $log
        fi
    else
        echo "  Pre-existing output file $out does not exist. Summing reads for sample." >> $log
        sample_count
    fi
fi

echo "05-sample-count stopped at `date`" >> $log
echo >> $log
