#!/bin/bash

set -e

export WORK_DIR=$HOME/workflows
if ls /local-scratch/ >/dev/null 2>&1; then
    export WORK_DIR=/local-scratch/$USER/workflows
fi
mkdir -p $WORK_DIR

export RUN_ID=freesurfer-`date +'%s'`

# create the site catalog from the template
envsubst < sites.xml.template > sites.xml

# generate the workflow
./workflow-generator.py "$@"

# make sure we also have access to the AMQP lib
export PYTHONPATH="$PYTHONPATH:/usr/lib/python2.6/site-packages"

# plan and submit the  workflow
pegasus-plan \
    --conf pegasus.conf \
    --dir $WORK_DIR \
    --relative-dir $RUN_ID \
    --sites condorpool \
    --output-site local \
    --dax freesurfer-osg.xml \
    --cluster horizontal \
    --submit



