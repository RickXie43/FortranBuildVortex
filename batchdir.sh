#!/bin/bash
#Set INPUTDIR and will create new directory in OUTPUTDIR to save result
#
#cone25_1K dir processing
INPUTDIR=~/Results/20240105_cone_results/cone25_1K
OUTPUTDIR=~/Results/20240105_cone_results/cone25_1K
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

#cone25_2K dir processing
INPUTDIR=~/Results/20240105_cone_results/cone25_2K
OUTPUTDIR=~/Results/20240105_cone_results/cone25_2K
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

#cone25_4K dir processing
INPUTDIR=~/Results/20240105_cone_results/cone25_4K
OUTPUTDIR=~/Results/20240105_cone_results/cone25_4K
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

#cone25_8K dir processing
INPUTDIR=~/Results/20240105_cone_results/cone25_8K
OUTPUTDIR=~/Results/20240105_cone_results/cone25_8K
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

#cone25_0.5K dir processing
INPUTDIR=~/Results/20240105_cone_results/cone25_0.5K
OUTPUTDIR=~/Results/20240105_cone_results/cone25_0.5K
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

#cone5_4K dir processing
INPUTDIR=~/Results/20240105_cone_results/cone5_4K
OUTPUTDIR=~/Results/20240105_cone_results/cone5_4K
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

#cone15_4K dir processing
INPUTDIR=~/Results/20240105_cone_results/cone15_4K
OUTPUTDIR=~/Results/20240105_cone_results/cone15_4K
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

