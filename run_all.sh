#!/bin/env bash

HEPCONV="/tmp/HepDataTools/hepconverter.py"
REPLACE="./python/replace_string.py"
SELECTION_REGIONS="sr1jee sr2jee sr1jem sr2jem sr1jmm sr2jmm" # same order as in fig 8 and 9

function get_hepdata_script() {
    echo "Getting the HepDataTool script..."
    svn co svn+ssh://svn.cern.ch/reps/atlasphys/Physics/SUSY/Tools/HepDataTools/trunk /tmp/HepDataTools
}

function format_root_files() {
    echo "Formatting the main figures"
    # (get the zip input file from Suneet, see email "stack and legend
    # order -- Fwd: ATLAS-SUSY-2013-23-002-COMMENT-001: Document Received"
    # from 2015-01-28)
    mkdir input_from_suneet
    unzip /tmp/whss_root_plots.zip -d input_from_suneet/
    ./python/format_input.py

    echo "Preparing the acceptance/efficiency inputs..."
    ./python/plot_acceptance_efficiency_TGraph2D.py
}

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
        figure_7_a) cap='One lepton and two b-jets channel: 95% CL limit on signal strength for C1N2 production for mN1 = 0 GeV.' ;;
        figure_7_b) cap='One lepton and two photons channel: 95% CL limit on signal strength for C1N2 production for mN1 = 0 GeV.' ;;
        figure_7_c) cap='Same-sign dilepton channel: 95% CL limit on signal strength for C1N2 production for mN1 = 0 GeV.' ;;
        figure_7_d) cap='Combination: 95% CL limit on signal strength for C1N2 production for mN1 = 0 GeV.' ;;
        figure_8_a) cap='One lepton and two b-jets channel: Expected/Observed 95% CL exclusion contour for chargino neutralino production via Wh' ;;
        figure_8_b) cap='One lepton and two photons channel: Expected/Observed 95% CL exclusion contour for chargino neutralino production via Wh' ;;
        figure_8_c) cap='Same-sign dilepton channel: Expected/Observed 95% CL exclusion contour for chargino neutralino production via Wh' ;;
        figure_8_d) cap='Combination: Expected/Observed 95% CL exclusion contour for chargino neutralino production via Wh' ;;
        figure_app_8_a) cap='Acceptance for the same-sign $ee$     channel with one jet.' ;;
        figure_app_8_b) cap='Acceptance for the same-sign $ee$     channel with two or three jets.' ;;
        figure_app_8_c) cap='Acceptance for the same-sign $e\mu$   channel with one jet.' ;;
        figure_app_8_d) cap='Acceptance for the same-sign $e\mu$   channel with two or three jets.' ;;
        figure_app_8_e) cap='Acceptance for the same-sign $\mu\mu$ channel with one jet.' ;;
        figure_app_8_f) cap='Acceptance for the same-sign $\mu\mu$ channel with two or three jets.' ;;
        figure_app_9_a) cap='Efficiency for the same-sign $ee$     channel with one jet.' ;;
        figure_app_9_b) cap='Efficiency for the same-sign $ee$     channel with two or three jets.' ;;
        figure_app_9_c) cap='Efficiency for the same-sign $e\mu$   channel with one jet.' ;;
        figure_app_9_d) cap='Efficiency for the same-sign $e\mu$   channel with two or three jets.' ;;
        figure_app_9_e) cap='Efficiency for the same-sign $\mu\mu$ channel with one jet.' ;;
        figure_app_9_f) cap='Efficiency for the same-sign $\mu\mu$ channel with two or three jets.' ;;
    esac
    echo ${cap}
}

function figure_wrong_caption () {
    # dummy values that the script puts in and that need to be replaced
    local cap=""
    case "$1" in
        figure_7_a) cap='exp_limit_bb' ;;
        figure_7_b) cap='exp_limit_gg' ;;
        figure_7_c) cap='exp_limit_ss' ;;
        figure_7_d) cap='exp_limit_combi' ;;
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
        ${HEPCONV} -i ${IN_} -y sig dat bkg -o output/${FNAME}
        ${REPLACE} ${OUT_} \
                   "*qual: . : GIVE COLUMN EXPLANATIONS, IF YOU USED OVERLAYS" \
                   "*qual: . : signal : data : background"
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

function acceptance_fignames() {
    # convert acceptance root fname to latex figure name
    local fig=""
    case "$1" in
        sr1jee) fig='figure_app_8_a' ;;
        sr2jee) fig='figure_app_8_b' ;;
        sr1jem) fig='figure_app_8_c' ;;
        sr2jem) fig='figure_app_8_d' ;;
        sr1jmm) fig='figure_app_8_e' ;;
        sr2jmm) fig='figure_app_8_f' ;;
    esac
    echo ${fig}
}

function efficiency_fignames() {
    # convert efficiency root fname to latex figure name
    local fig=""
    case "$1" in
        sr1jee) fig='figure_app_9_a' ;;
        sr2jee) fig='figure_app_9_b' ;;
        sr1jem) fig='figure_app_9_c' ;;
        sr2jem) fig='figure_app_9_d' ;;
        sr1jmm) fig='figure_app_9_e' ;;
        sr2jmm) fig='figure_app_9_f' ;;
    esac
    echo ${fig}
}

function acceptance_figures() {
    for FNAME in ${SELECTION_REGIONS}
    do
        local IN_="input_acc_eff/acceptance_${FNAME}.root"
        local FIG_=$(acceptance_fignames ${FNAME})
        local OUT_="output/${FIG_}"
        local OUTH_="output/${FIG_}.hep.dat"
        local CAP_=$(figure_caption ${FIG_})
        echo "${HEPCONV} -i ${IN_} -o ${OUT_}"
        ${HEPCONV} -i ${IN_} -o ${OUT_}
        ${REPLACE} ${OUTH_} \
                   "*qual: . : GIVE COLUMN EXPLANATIONS, IF YOU USED OVERLAYS" \
                   "*qual: . : acceptance"
        ${REPLACE} ${OUTH_} \
                   "*location: Figure GIVE FIGURE NUMBER" \
                   "*location: ${FIG_}"
        ${REPLACE} ${OUTH_} \
                   "*reackey: P P --> GIVE THE PRODUCTION PROCESSES" \
                   "*reackey: P P --> CHARGINO1 NEUTRALINO2 X"
        ${REPLACE} ${OUTH_} \
                   "*obskey: GIVE KEY FOR Y-AXIS VARIABLE" \
                   "*obskey: ACC"
        ${REPLACE} ${OUTH_} \
                   "*qual: RE : P P --> GIVE THE PRODUCTION PROCESSES + DECAYS (IF RELEVANT)" \
                   "*qual: RE : P P --> CHARGINO1 < W NEUTRALINO1 > NEUTRALINO2 < H NEUTRALINO1 > X"
        ${REPLACE} ${OUTH_} \
                   "*xheader:" \
                   "*xheader: M(CHARGINO1) IN GEV : M(NEUTRALINO1) IN GEV"
        ${REPLACE} ${OUTH_} \
                   "*yheader: " \
                   "*yheader: ACCEPTANCE"
        ${REPLACE} ${OUTH_} \
                   "*dscomment: Graph2D" \
                   "*dscomment: ${CAP_}"
        remove_header_footer ${OUTH_}
    done
}

function efficiency_figures() {
    for FNAME in ${SELECTION_REGIONS}
    do
        local IN_="input_acc_eff/efficiency_${FNAME}.root"
        local FIG_=$(efficiency_fignames ${FNAME})
        local OUT_="output/${FIG_}"
        local OUTH_="output/${FIG_}.hep.dat"
        local CAP_=$(figure_caption ${FIG_})
        echo "caption ${CAP_}"
        echo "${HEPCONV} -i ${IN_} -o ${OUT_}"
        ${HEPCONV} -i ${IN_} -o ${OUT_}
        ${REPLACE} ${OUTH_} \
                   "*qual: . : GIVE COLUMN EXPLANATIONS, IF YOU USED OVERLAYS" \
                   "*qual: . : efficiency"
        ${REPLACE} ${OUTH_} \
                   "*location: Figure GIVE FIGURE NUMBER" \
                   "*location: ${FIG_}"
        ${REPLACE} ${OUTH_} \
                   "*reackey: P P --> GIVE THE PRODUCTION PROCESSES" \
                   "*reackey: P P --> CHARGINO1 NEUTRALINO2 X"
        ${REPLACE} ${OUTH_} \
                   "*obskey: GIVE KEY FOR Y-AXIS VARIABLE" \
                   "*obskey: EFF"
        ${REPLACE} ${OUTH_} \
                   "*qual: RE : P P --> GIVE THE PRODUCTION PROCESSES + DECAYS (IF RELEVANT)" \
                   "*qual: RE : P P --> CHARGINO1 < W NEUTRALINO1 > NEUTRALINO2 < H NEUTRALINO1 > X"
        ${REPLACE} ${OUTH_} \
                   "*xheader:" \
                   "*xheader: M(CHARGINO1) IN GEV : M(NEUTRALINO1) IN GEV"
        ${REPLACE} ${OUTH_} \
                   "*yheader: " \
                   "*yheader: EFFICIENCY"
        ${REPLACE} ${OUTH_} \
                   "*dscomment: Graph2D" \
                   "*dscomment: ${CAP_}"
        remove_header_footer ${OUTH_}
    done
}

function merge_all_ss2l_parts() {
    cat \
    input_formatted/hepdata_header.txt \
    output/figure_5.hep.dat            \
    output/figure_6_a.hep.dat          \
    output/figure_6_b.hep.dat          \
    output/figure_6_c.hep.dat          \
    output/figure_6_d.hep.dat          \
    output/figure_6_e.hep.dat          \
    output/figure_6_f.hep.dat          \
    output/figure_app_8_a.hep.dat      \
    output/figure_app_8_b.hep.dat      \
    output/figure_app_8_c.hep.dat      \
    output/figure_app_8_d.hep.dat      \
    output/figure_app_8_e.hep.dat      \
    output/figure_app_8_f.hep.dat      \
    output/figure_app_9_a.hep.dat      \
    output/figure_app_9_b.hep.dat      \
    output/figure_app_9_c.hep.dat      \
    output/figure_app_9_d.hep.dat      \
    output/figure_app_9_e.hep.dat      \
    output/figure_app_9_f.hep.dat      \
    > output/hepdata_ss2l.hep.dat
}

function merge_all_parts() {
    cat \
    input_formatted/hepdata_header.txt \
    output/figure_2_a.hep.dat       \
    output/figure_2_b.hep.dat       \
    output/figure_2_c.hep.dat       \
    output/figure_2_d.hep.dat       \
    output/figure_2_e.hep.dat       \
    output/figure_2_f.hep.dat       \
    output/figure_3_a.hep.dat       \
    output/figure_3_b.hep.dat       \
    output/figure_3_c.hep.dat       \
    output/figure_3_d.hep.dat       \
    output/figure_4_a.hep.dat       \
    output/figure_4_b.hep.dat       \
    output/figure_4_c.hep.dat       \
    output/figure_4_d.hep.dat       \
    output/figure_5.hep.dat         \
    output/figure_6_a.hep.dat       \
    output/figure_6_b.hep.dat       \
    output/figure_6_c.hep.dat       \
    output/figure_6_d.hep.dat       \
    output/figure_6_e.hep.dat       \
    output/figure_6_f.hep.dat       \
    output/figure_7_a.hep.dat       \
    output/figure_7_b.hep.dat       \
    output/figure_7_c.hep.dat       \
    output/figure_7_d.hep.dat       \
    output/figure_8_a.hep.dat       \
    output/figure_8_b.hep.dat       \
    output/figure_8_c.hep.dat       \
    output/figure_8_d.hep.dat       \
    output/figure_app_14_a.hep.dat  \
    output/figure_app_14_b.hep.dat  \
    output/figure_app_15_a.hep.dat  \
    output/figure_app_15_b.hep.dat  \
    output/figure_19_a.hep.dat      \
    output/figure_19_b.hep.dat      \
    output/figure_19_c.hep.dat      \
    output/figure_19_d.hep.dat      \
    output/figure_app_4_a.hep.dat   \
    output/figure_app_4_b.hep.dat   \
    output/figure_app_4_c.hep.dat   \
    output/figure_app_4_d.hep.dat   \
    output/figure_app_5_a.hep.dat   \
    output/figure_app_5_b.hep.dat   \
    output/figure_app_5_c.hep.dat   \
    output/figure_app_5_d.hep.dat   \
    output/figure_app_8_a.hep.dat   \
    output/figure_app_8_b.hep.dat   \
    output/figure_app_8_c.hep.dat   \
    output/figure_app_8_d.hep.dat   \
    output/figure_app_8_e.hep.dat   \
    output/figure_app_8_f.hep.dat   \
    output/figure_app_9_a.hep.dat   \
    output/figure_app_9_b.hep.dat   \
    output/figure_app_9_c.hep.dat   \
    output/figure_app_9_d.hep.dat   \
    output/figure_app_9_e.hep.dat   \
    output/figure_app_9_f.hep.dat   \
    > output/hepdata.hep.dat
}

function format_alberto_input() {
    local rtg="./python/rename_tgraphs.py"
    local in_="input_from_alberto"
    local out_="input_formatted"
    ${rtg} "${in_}/1D_bb_noprelblackln.root"    "${out_}/figure_7_a.root"  exp_limit_bb    obs_limit_bb
    ${rtg} "${in_}/1D_gg_noprelblackln.root"    "${out_}/figure_7_b.root"  exp_limit_gg    obs_limit_gg
    ${rtg} "${in_}/1D_ss_noprelblackln.root"    "${out_}/figure_7_c.root"  exp_limit_ss    obs_limit_ss
    ${rtg} "${in_}/1D_combi_noprelblackln.root" "${out_}/figure_7_d.root"  exp_limit_combi obs_limit_combi
}

function limit1d() {
    local FIG_=""
    for FIG_ in figure_7_a figure_7_b figure_7_c figure_7_d
    do
        echo ${FIG_}
        local IN_="input_formatted/${FIG_}.root"
        local OUT_="output/${FIG_}"
        local OUTH_="output/${FIG_}.hep.dat"
        local CAP_=$(figure_caption ${FIG_})
        local CAP_WRONG=$(figure_wrong_caption ${FIG_})
        echo "caption ${CAP_}"
        echo "${HEPCONV} -i ${IN_} --overlay exp obs -o ${OUT_}"
        ${HEPCONV} -i ${IN_}  --overlay exp obs -o ${OUT_}
        ${REPLACE} ${OUTH_} \
                   "*qual: . : GIVE COLUMN EXPLANATIONS, IF YOU USED OVERLAYS" \
                   "*qual: . : expected : observed"
        ${REPLACE} ${OUTH_} \
                   "*location: Figure GIVE FIGURE NUMBER" \
                   "*location: ${FIG_}"
        ${REPLACE} ${OUTH_} \
                   "*reackey: P P --> GIVE THE PRODUCTION PROCESSES" \
                   "*reackey: P P --> CHARGINO1 NEUTRALINO2 X"
        ${REPLACE} ${OUTH_} \
                   "*obskey: GIVE KEY FOR Y-AXIS VARIABLE" \
                   "*obskey: UPPER LIMIT"
        ${REPLACE} ${OUTH_} \
                   "*qual: RE : P P --> GIVE THE PRODUCTION PROCESSES + DECAYS (IF RELEVANT)" \
                   "*qual: RE : P P --> CHARGINO1 < W NEUTRALINO1 > NEUTRALINO2 < H NEUTRALINO1 > X"
        ${REPLACE} ${OUTH_} \
                   "*xheader:" \
                   "*xheader: M(CHARGINO1,NEUTRALINO2) IN GEV"
        ${REPLACE} ${OUTH_} \
                   "*yheader: " \
                   "*yheader: UPPER LIMIT"
        ${REPLACE} ${OUTH_} \
                   "'*dscomment: ${CAP_WRONG}'" \
                   "'*dscomment: ${CAP_}'"
        remove_header_footer ${OUTH_}
    done
}

function format_sigve_input() {
    # special treatment, two islands for expected
    ./python/rename_semicolon.py input_from_sigve/hepData-1l2b.root        input_formatted/figure_8_a.root
    # nothing to do
    cp -p input_from_sigve/hepData-gg.root          input_formatted/figure_8_b.root
    cp -p input_from_sigve/hepData-SS-Zoom.root     input_formatted/figure_8_c.root
    cp -p input_from_sigve/hepData-combination.root input_formatted/figure_8_d.root
}

function limit2d() {
    local FIG_=""
    for FIG_ in figure_8_a figure_8_b figure_8_c figure_8_d
    do
        echo ${FIG_}
        local IN_="input_formatted/${FIG_}.root"
        local OUT_="output/${FIG_}"
        local OUTH_="output/${FIG_}.hep.dat"
        local CAP_=$(figure_caption ${FIG_})
        echo "caption ${CAP_}"
        echo "${HEPCONV} -i ${IN_} -o ${OUT_}"
        ${HEPCONV} -i ${IN_} -o ${OUT_}
        ${REPLACE} ${OUTH_} \
                   "*location: Figure GIVE FIGURE NUMBER" \
                   "*location: ${FIG_}"
        ${REPLACE} ${OUTH_} \
                   "*reackey: P P --> GIVE THE PRODUCTION PROCESSES" \
                   "*reackey: P P --> CHARGINO1 NEUTRALINO2 X"
        ${REPLACE} ${OUTH_} \
                   "*obskey: GIVE KEY FOR Y-AXIS VARIABLE" \
                   "*obskey: UPPER LIMIT"
        ${REPLACE} ${OUTH_} \
                   "*qual: RE : P P --> GIVE THE PRODUCTION PROCESSES + DECAYS (IF RELEVANT)" \
                   "*qual: RE : P P --> CHARGINO1 < W NEUTRALINO1 > NEUTRALINO2 < H NEUTRALINO1 > X"
        ${REPLACE} ${OUTH_} \
                   "*xheader: m_{#tilde{#chi}_{1}^{#pm}} [GeV]" \
                   "*xheader: M(CHARGINO1,NEUTRALINO2) IN GEV"
        ${REPLACE} ${OUTH_} \
                   "*yheader: m_{#tilde{#chi}_{1}^{0}} [GeV]" \
                   "*yheader: M(NEUTRALINO1) IN GEV"
        ${REPLACE} ${OUTH_} \
                   "'*dscomment:'" \
                   "'*dscomment: ${CAP_}'"
        remove_header_footer ${OUTH_}
    done
    echo "These files (figure_8_*) required some manual adjustment:"
    echo "- merge fig 8_a (two contours for exp)"
    echo "- caption : drop final 'WhMediated_contourExpected'"
    echo "- caption : pick Expected/Observed"
    echo ""
}
#-------------------
# main
#-------------------

echo "Preparing input files..."
get_hepdata_script
format_root_files
echo "Writing hepdata files..."
main_figures
acceptance_figures
efficiency_figures
merge_all_ss2l_parts

format_alberto_input
limit1d

format_sigve_input
limit2d
merge_all_parts
