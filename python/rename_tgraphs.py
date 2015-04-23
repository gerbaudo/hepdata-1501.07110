#!/bin/env python

# Format the input from Alberto as requied by hepconverter.py

# Extract from the canvas all the objects that have name 'TGraph', and
# save them with name = title.
#
# davide.gerbaudo@gmail.com
# Apr 2015

import re
import sys
import ROOT as R
R.gROOT.SetBatch(1)

def main():
    if len(sys.argv)<3:
        print "usage: {} input,root output.root [title1 title2 ...]".format(sys.argv[0])
        return

    input_filename  = sys.argv[1]
    output_filename = sys.argv[2]
    allowed_titles  = sys.argv[3:]
    input_file = R.TFile.Open(input_filename)
    output_file = R.TFile.Open(output_filename, 'recreate')
    output_file.cd()

    c1 = input_file.Get('c1')

    for p in c1.GetListOfPrimitives():
        print p.GetName(),' ',p.GetTitle()
        if p.GetName()!='Graph':
            continue
        title = p.GetTitle()
        if allowed_titles and title not in allowed_titles:
            print "skipping {}".format(title)
            continue
        p.SetName(title)
        p.Write()
        print "saving {}".format(title)
    output_file.Close()

if __name__=='__main__':
    main()
