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
HEPCONV="/tmp/HepDataTools/hepconverter.py"
REPLACE="./python/replace_string.py"

function x_axis_label() {
    local label=""
    case "$1" in
        figure_5) label="MEFF IN GEV" ;;
        figure_6_a) label="MEFF IN GEV" ;;
        figure_6_b) label="MEFF IN GEV" ;;
        figure_6_c) label="MTMAX IN GEV" ;;
        figure_6_d) label="MTMAX IN GEV" ;;
        figure_6_e) label="MLJ IN GEV" ;;
        figure_6_f) label="MLJJ IN GEV" ;;
    esac
    echo ${label}
}

function y_axis_label() {
    local label=""
    case "$1" in
        figure_5) label="EVENTS / (50 GEV)" ;;
        figure_6_a) label="EVENTS / (50 GEV)" ;;
        figure_6_b) label="EVENTS / (50 GEV)" ;;
        figure_6_c) label="EVENTS / (25 GEV)" ;;
        figure_6_d) label="EVENTS / (25 GEV)" ;;
        figure_6_e) label="EVENTS / (30 GEV)" ;;
        figure_6_f) label="EVENTS / (30 GEV)" ;;
    esac
    echo ${label}
}

function figure_caption() {
    # shorten captions from
    # https://atlas.web.cern.ch/Atlas/GROUPS/PHYSICS/PAPERS/SUSY-2013-23/
    # based on the example from
    # http://hepdata.cedar.ac.uk/view/ins1339376/input
    local cap=""
    case "$1" in
        figure_5)   cap='Distribution of effective mass $m_{\rm eff}$ in the validation region of the same-sign $e\mu$ channel.' ;;
        figure_6_a) cap='Distribution of effective mass $m_{\rm eff}$ for the same-sign dilepton channel in the signal region with one jet.' ;;
        figure_6_b) cap='Distribution of effective mass $m_{\rm eff}$ for the same-sign dilepton channel in the signal region with two or three jets.' ;;
        figure_6_c) cap='Distribution of largest transverse mass $m_{\rm T}^{\rm max}$ for the same-sign dilepton channel in the signal region with one jet.' ;;
        figure_6_d) cap='Distribution of largest transverse mass $m_{\rm T}^{\rm max}$ for the same-sign dilepton channel in the signal region with two or three jets.' ;;
        figure_6_e) cap='Distribution of invariant mass of lepton and jet $m_{lj}$ for the same-sign dilepton channel in the signal regions with one jet.' ;;
        figure_6_f) cap='Distribution of invariant mass of lepton and jet $m_{lj}$ for the same-sign dilepton channel in the signal regions with one jet.' ;;
    esac
    echo ${cap}
}

function remove_header_footer() {
    # delete all lines starting from the 1st until encountering the pattern below
    sed -i -e '1,/*comment:\ CERN-LHC.\ INSERT ABSTRACT/d' ${1}
    # delete the last line
    sed -i -e '/*E$/d' ${1}
}

function main_figures() {
    MAIN_FIGURE_FILES=""
    MAIN_FIGURE_FILES+=" figure_5"
    MAIN_FIGURE_FILES+=" figure_6_a"
    MAIN_FIGURE_FILES+=" figure_6_b"
    MAIN_FIGURE_FILES+=" figure_6_c"
    MAIN_FIGURE_FILES+=" figure_6_d"
    MAIN_FIGURE_FILES+=" figure_6_e"
    MAIN_FIGURE_FILES+=" figure_6_f"
    for FNAME in ${MAIN_FIGURE_FILES}
    do
        local IN_="input_formatted/${FNAME}.root"
        local OUT_="output/${FNAME}.hep.dat"
        local XL_=$(x_axis_label ${FNAME})
        local YL_=$(y_axis_label ${FNAME})
        local CAP_=$(figure_caption ${FNAME})
        echo "caption ${CAP_}"
        echo "${HEPCONV} -i ${IN_} -y dat bkg sig -o output/${FNAME}"
        ${HEPCONV} -i ${IN_} -y dat bkg sig -o output/${FNAME}
        ${REPLACE} ${OUT_} \
                   "*qual: . : GIVE COLUMN EXPLANATIONS, IF YOU USED OVERLAYS" \
                   "*qual: . : data : background : signal"
        ${REPLACE} ${OUT_} \
                   "*location: Figure GIVE FIGURE NUMBER" \
                   "*location: ${FNAME}"
        ${REPLACE} ${OUT_} \
                   "*reackey: P P --> GIVE THE PRODUCTION PROCESSES" \
                   "*reackey: P P --> CHARGINO1 NEUTRALINO2 X"
        ${REPLACE} ${OUT_} \
                   "*obskey: GIVE KEY FOR Y-AXIS VARIABLE" \
                   "*obskey: N"
        ${REPLACE} ${OUT_} \
                   "*qual: RE : P P --> GIVE THE PRODUCTION PROCESSES + DECAYS (IF RELEVANT)" \
                   "*qual: RE : P P --> CHARGINO1 < W NEUTRALINO1 > NEUTRALINO2 < H NEUTRALINO1 > X"
        ${REPLACE} ${OUT_} \
                   "*xheader:" \
                   "*xheader: ${XL_}"
        ${REPLACE} ${OUT_} \
                   "*yheader:  :  :" \
                   "*yheader: ${YL_}"
        ${REPLACE} ${OUT_} \
                   "*dscomment: " \
                   "*dscomment: ${CAP_}"
        remove_header_footer ${OUT_}
    done
}

function acceptance_efficiency_figures() {
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
}


main_figures
acceptance_efficiency_figures
