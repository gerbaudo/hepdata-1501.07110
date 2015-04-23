#!/bin/env python

# some of the objects are there with two name cycles (;1 and ;2): rename  the ';' with '_'

# davide.gerbaudo@gmail.com
# Apr 2015

import sys
import ROOT as R
R.gROOT.SetBatch(1)

def main():
    if len(sys.argv)<3:
        print "usage: {} input,root output.root".format(sys.argv[0])
        return

    input_filename  = sys.argv[1]
    output_filename = sys.argv[2]
    input_file  = R.TFile.Open(input_filename)
    output_file = R.TFile.Open(output_filename, 'recreate')
    output_file.cd()

    rewrite_objects = {
        'WhMediated_observed;2' : 'WhMediated_observed_2',
        'WhMediated_expected;2' : 'WhMediated_expected_2',
        'WhMediated_expected;1' : 'WhMediated_expected_1',
        }
    for k, v in rewrite_objects.iteritems():
        o = input_file.Get(k)
        o.SetName(v)
        o.Write()
    output_file.Close()

if __name__=='__main__':
    main()
