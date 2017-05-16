#!/bin/bash -e

. ../common.sh

log=$logDir/sbatch.log

echo "05-sample-count sbatch.sh running at `date`" >> $log
echo "  Dependencies are $SP_DEPENDENCY_ARG" >> $log

if [ "$SP_SIMULATE" = "1" ]
then
    echo "  Simulating." >> $log
elif [ "$SP_SKIP" = "1" ]
then
    echo "  Skipping." >> $log
else
    echo "  Not simulating or skipping. Requesting exclusive node." >> $log
fi

jobid=`sbatch -n 1 $SP_DEPENDENCY_ARG submit.sh "$@" | cut -f4 -d' '`
echo "TASK: panel $jobid"

echo "  Job id is $jobid" >> $log
echo >> $log
