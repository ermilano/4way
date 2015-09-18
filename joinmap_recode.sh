#!/bin/bash

# Script to convert 4way JoinMap/ MapQTL genotype codes to 4way R/qtl genotype codes.
# Elizabeth R. Milano, August 2014

# Usage: joinmap_recode.sh <infile> <outfile>


touch $2
grep "<nnxnp>\t{-0}" $1 | sed 's/nn/7/g' | sed 's/np/8/g' >> $2
grep "<nnxnp>\t{-1}" $1 | sed 's/nn/8/g' | sed 's/np/7/g' >> $2
grep "<lmxll>\t{0-}" $1 | sed 's/ll/5/g' | sed 's/lm/6/g' >> $2
grep "<lmxll>\t{1-}" $1 | sed 's/ll/6/g' | sed 's/lm/5/g' >> $2
grep "<efxeg>\t{00}" $1 | sed 's/ee/1/g' | sed 's/ef/2/g' | sed 's/eg/3/g' | sed 's/fg/4/g' >> $2
grep "<efxeg>\t{10}" $1 | sed 's/ee/2/g' | sed 's/ef/1/g' | sed 's/eg/4/g' | sed 's/fg/3/g' >> $2
grep "<efxeg>\t{01}" $1 | sed 's/ee/3/g' | sed 's/ef/4/g' | sed 's/eg/1/g' | sed 's/fg/2/g' >> $2
grep "<efxeg>\t{11}" $1 | sed 's/ee/4/g' | sed 's/ef/3/g' | sed 's/eg/2/g' | sed 's/fg/1/g' >> $2
grep "<hkxhk>\t{00}" $1 | sed 's/hh/1/g' | sed 's/hk/10/g' | sed 's/kk/4/g' >> $2
grep "<hkxhk>\t{11}" $1 | sed 's/hh/1/g' | sed 's/hk/10/g' | sed 's/kk/4/g' >> $2
grep "<hkxhk>\t{10}" $1 | sed 's/hh/2/g' | sed 's/hk/9/g' | sed 's/kk/3/g' >> $2
grep "<hkxhk>\t{01}" $1 | sed 's/hh/3/g' | sed 's/hk/9/g' | sed 's/kk/2/g' >> $2
grep "<abxcd>\t{00}" $1 | sed 's/ac/1/g' | sed 's/bc/2/g' | sed 's/ad/3/g' | sed 's/bd/4/g' >> $2
grep "<abxcd>\t{10}" $1 | sed 's/ac/2/g' | sed 's/bc/1/g' | sed 's/ad/4/g' | sed 's/bd/3/g' >> $2
grep "<abxcd>\t{01}" $1 | sed 's/ac/3/g' | sed 's/bc/4/g' | sed 's/ad/1/g' | sed 's/bd/2/g' >> $2
grep "<abxcd>\t{11}" $1 | sed 's/ac/4/g' | sed 's/bc/3/g' | sed 's/ad/2/g' | sed 's/bd/1/g' >> $2

