#!/bin/bash -e

. $HOME/.virtualenvs/35/bin/activate
. ../common.sh

log=$logFile

echo "ERROR!! SLURM pipeline finished at `date`" >> $log

touch $errorFile
rm -f $runningFile $doneFile
