#!/bin/env bash

echo "Getting the HepDataTool script..."
svn co svn+ssh://svn.cern.ch/reps/atlasphys/Physics/SUSY/Tools/HepDataTools/trunk /tmp/HepDataTools


echo "Formatting the main figures"
# (get the zip input file from Suneet, see email "stack and legend
# order -- Fwd: ATLAS-SUSY-2013-23-002-COMMENT-001: Document Received"
# from 2015-01-28)
mkdir input_from_suneet
unzip /tmp/whss_root_plots.zip -d input_from_suneet/
./python/format_input.py

echo "Preparing the acceptance/efficiency inputs..."
./python/plot_acceptance_efficiency_TGraph2D.py

echo "Writing hepdata files..."
# main figures
HEPCONV="/tmp/HepDataTools/hepconverter.py"
for X in $(ls input_formatted/*root)
do
    FNAME=$(basename ${X})
    OUTNAME="output/${FNAME/.root/}"
    echo "/tmp/HepDataTools/hepconverter.py -i ${X} -o ${OUTNAME}"
    ${HEPCONV} -i ${X} -o ${OUTNAME}
done
# acceptance+efficiency
INPUT_ACC=""
INPUT_ACC+=" input_acc_eff/acceptance_sr1jee.root"
INPUT_ACC+=" input_acc_eff/acceptance_sr2jee.root"
INPUT_ACC+=" input_acc_eff/acceptance_sr1jem.root"
INPUT_ACC+=" input_acc_eff/acceptance_sr2jem.root"
INPUT_ACC+=" input_acc_eff/acceptance_sr1jmm.root"
INPUT_ACC+=" input_acc_eff/acceptance_sr2jmm.root"
INPUT_EFF=""
INPUT_EFF+=" input_acc_eff/efficiency_sr1jee.root"
INPUT_EFF+=" input_acc_eff/efficiency_sr2jee.root"
INPUT_EFF+=" input_acc_eff/efficiency_sr1jem.root"
INPUT_EFF+=" input_acc_eff/efficiency_sr2jem.root"
INPUT_EFF+=" input_acc_eff/efficiency_sr1jmm.root"
INPUT_EFF+=" input_acc_eff/efficiency_sr2jmm.root"

${HEPCONV} -i ${INPUT_ACC} -o output/figure_app_8
${HEPCONV} -i ${INPUT_EFF} -o output/figure_app_9
