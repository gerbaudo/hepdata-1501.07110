#!/bin/env python

# Take the values from up/down tgraphs and add them as u/d errors

# The (obs) 1d limits from Alberto have an up/do error that is stored
# in a separate tgraph.  Take those values and attach them as a +/-
# error. Replace the original file with the modified one (and keep
# everything else as it is in the input).
#
# davide.gerbaudo@gmail.com
# Jun 2015

import re
import sys
import ROOT as R
R.gROOT.SetBatch(1)

def main():
    if len(sys.argv)<2:
        print "usage: {} input,root output.root".format(sys.argv[0])
        return

    input_filename  = sys.argv[1]
    output_filename = sys.argv[2]

    input_file = R.TFile.Open(input_filename)
    output_file = R.TFile.Open(output_filename, 'recreate')
    output_file.cd()

    input_file.ls()
    channels = ['bb', 'gg', 'ss', 'combi']
    for key in input_file.GetListOfKeys():
        keyname = key.GetName()
        obj = input_file.Get(keyname)
        name = obj.GetName()
        title = obj.GetTitle()
        to_be_zipped = name.startswith('obs_limit_')
        is_nominal = to_be_zipped and ('up' not in name) and ('down' not in name)
        if not to_be_zipped:
            obj.Write()
        elif is_nominal:
            gr_cen = obj
            gr_cen_err = R.TGraphAsymmErrors(gr_cen.GetN())
            gr_cen_err.SetName(gr_cen.GetName())
            gr_cen_err.SetTitle(gr_cen.GetTitle())
            gr_up_name = name.replace('_limit', '_limit_up')
            gr_do_name = name.replace('_limit', '_limit_down')
            gr_up = input_file.Get(gr_up_name)
            gr_do = input_file.Get(gr_do_name)
            if not gr_up or not gr_do:
                print "gr missing : %s"%(gr_do_name if not gr_do else gr_up_name)
                gr_cen.Write()
                continue
            for i in range(gr_cen.GetN()):
                x = gr_cen.GetX()[i]
                y = gr_cen.GetY()[i]
                print "x: %.2f y: %.2f + %.2f - %.2f"%(x, y, gr_up.GetY()[i]-y, gr_do.GetY()[i]-y)
                gr_cen_err.SetPoint(i, x, y)
                gr_cen_err.SetPointError(i, 0.0, 0.0, abs(gr_do.GetY()[i]-y), abs(gr_up.GetY()[i]-y))
            gr_cen_err.Write()
                
    output_file.Close()
    output_file.Delete()
    input_file.Close()

if __name__=='__main__':
    main()
