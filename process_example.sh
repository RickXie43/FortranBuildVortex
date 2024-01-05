#!/bin/bash
INPUTDIR=~/Results/20230812_vortexdata_beta_1.3/2.13K_A_G3.8/VortexData_180721_7.5V_2.13K_A_2.67s_renamed
OUTPUTDIR=.
make clean
make
./buildvortex_series $INPUTDIR $OUTPUTDIR
make clean
make field
./buildvortex_field $INPUTDIR $OUTPUTDIR

#if you want to batch processing a series of INPUTDIR, use this:
#dir processing
INPUTDIR=~/dircontainsmanyvortexdatadir
OUTPUTDIR=~/outputdiryouwant
SUBDIRS=("$INPUTDIR"/*)
for dir in "${SUBDIRS[@]}";
do
	if [[ -d "$dir" ]]; then
		echo "Processing $dir"
		make clean
		make
		./buildvortex_series "$dir" $OUTPUTDIR
		echo "Finished processing $dir."
	fi
done
