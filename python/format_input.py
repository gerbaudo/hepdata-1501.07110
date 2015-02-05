#!/bin/env python

# take the root files generated with canvas.SaveAs(), find the relevant histograms, and save them in the format required by HepDataTools/hepconverter.py
#
# Get hepconverter.py with
#   svn co svn+ssh://svn.cern.ch/reps/atlasphys/Physics/SUSY/Tools/HepDataTools/trunk
# and follow the instructions at
#   https://twiki.cern.ch/twiki/bin/view/AtlasProtected/SUSYHepData
#
# davide.gerbaudo@gmail.com
# Jan 2015

import array
import os
import numpy as np
import ROOT as r
r.gROOT.SetBatch(True)

input_dir = 'input_from_suneet'
output_dir = 'input_formatted'

figure_files = {
    'figure_5': 'pred_DGWH_WH_CRSSZVFAKE_EM_DGWH_mEff.root',
    'figure_6_a' : 'kinematics_SR_1jNOHt_Ht.root',
    'figure_6_b' : 'kinematics_SR_23jNOHt_Ht.root',
    'figure_6_c' : 'kinematics_SR_1jNOmtmax_mtmax.root',
    'figure_6_d' : 'kinematics_SR_23jNOmtmax_mtmax.root',
    'figure_6_e' : 'kinematics_SR_1jNOmlj_mlj.root',
    'figure_6_f' : 'kinematics_SR_23jNOmljj_mljj.root',
}


def main():
    if not os.path.exists(output_dir) : os.makedirs(output_dir)
    for fig, input_filename in figure_files.iteritems():
        print "processing ",fig
        input_file = r.TFile.Open(os.path.join(input_dir, input_filename))                                  
        output_file = r.TFile.Open(os.path.join(output_dir, input_filename), 'recreate')
        move_everything_from_canvas_to_base(input_file, output_file)
        output_file.Write()
        output_file.Close()
        input_file.Close()

def move_everything_from_canvas_to_base(input_file, output_file, canvas_name='canvas', pad_name='canvas_1'):
    can = input_file.Get(canvas_name).FindObject(pad_name)
    keys = [k.GetName() for k in can.GetListOfPrimitives()]
    objects = [can.FindObject(k) for k in keys]
    objects = [o for o in objects if o.InheritsFrom('TH1') or o.InheritsFrom('TGraph')]
    bkg = get_bkg_error_band(objects)
    sig = get_sig_graph(objects)
    dat = clean_data_graph(get_data_graph(objects))
    print 'bkg ',print_entries(bkg)
    print 'sig ',print_entries(sig)
    print 'dat ',print_entries(dat)
    
    output_file.cd()
    bkg.SetName('bkg')
    sig.SetName('sig')
    dat.SetName('dat')
    for o in [bkg, sig, dat]:
        if hasattr(o, 'SetDirectory') : o.SetDirectory(output_file)
        o.Write()
    output_file.Close()
    # for k in keys:
    #     o = can.FindObject(k)
    #     if o.InheritsFrom('TH1') or o.InheritsFrom('TGraph'):
    #         if hasattr(o, 'SetDirectory') : o.SetDirectory(output_file)
    #         o.Write()
    #         print o.GetName(),' ',o.ClassName(),'marker style ',o.GetMarkerStyle(),' size ',o.GetMarkerSize(),' line color ',o.GetLineColor(),' style ',o.GetLineStyle(),' fill style ',o.GetFillStyle(),''
    # output_file.Close()

def print_entries(gr_or_h):
    o = gr_or_h
    values = ([o.GetY()[i] for i in range(o.GetN())] if o.InheritsFrom('TGraph') else
              [o.GetBinContent(i+1) for i in range(o.GetNbinsX())] if o.InheritsFrom('TH1') else
              [])
    return values

def get_bkg_error_band(objects, fill_style=3004):
    obj = None
    objects = [o for o in objects if o.GetFillStyle()==fill_style]
    if len(objects)!=1:
        print 'cannot find bkg'
    else:
        obj = objects[0]
    return obj

def get_sig_graph(objects, line_color=616, line_style=2):
    obj = None
    objects = [o for o in objects if o.GetLineColor()==line_color and o.GetLineStyle()==line_style]
    if len(objects)!=1:
        print 'cannot find sig'
    else:
        obj = objects[0]
    return obj

def get_data_graph(objects, marker_style=20, marker_color=1, line_color=1,  line_style=1):
    obj = None
    objects = [o for o in objects if o.GetLineColor()==line_color and o.GetLineStyle()==line_style]
    if len(objects)<1:
        print 'cannot find data'
    elif len(objects)>1:
        o = objects[0]
        y_values = [[[o.GetY()[i] for i in range(o.GetN())]] for o in objects]
        has_multiple_values = len([vs for vs in y_values[1:] if vs!=y_values[0]])>0
        if has_multiple_values:
            print 'warning, multiple data with multiple values : ',y_values
        else:
            obj = objects[0]
    else:
        obj = objects[0]
    return obj

def clean_data_graph(graph, default_zero_value=-10):
    "data points with 0 entries were set to a negative default value so that they wouldn't show up"
    for i in range(graph.GetN()):
        x, y = graph.GetX()[i], graph.GetY()[i]
        if y==default_zero_value:
            graph.SetPoint(i, x, 0.0)
    return graph


if __name__=='__main__':
    main()
