#!/bin/bash

cd "$(dirname "$0")"

TEST_PROFILE_NAME=$1
MAXN=$2
MAXND=$3
OUTPUT_DIRECTORY=$4
ACCURACY_TESTS=$5
SPEED_TESTS=$6

echo "Profile Name: ${TEST_PROFILE_NAME}"
echo "Max Problem Size: ${MAXN}"
echo "Max Multi-dimensional Problem Size: ${MAXND}"
echo "Output Directory: ${OUTPUT_DIRECTORY}"

PROGS=$(find . -name 'doit')

if [ ${ACCURACY_TESTS} -eq 1 ]; then
	for prog in ${PROGS}; do
		echo "Running accurary tests on ${prog}";
		sh benchmark --maxn=${MAXN} --maxnd=${MAXND} --accuracy ${prog} | tee -a ${OUTPUT_DIRECTORY}/${TEST_PROFILE_NAME}.accuracy
	done
fi

if [ ${SPEED_TESTS} -eq 1 ]; then
	for prog in ${PROGS}; do
		echo "Benchmarking ${prog}";
		time_min=$(${prog} --print-time-min);	
		sh writeinfo --time-min ${time_min} ${prog}
		sh benchmark --time-min ${time_min} ${prog} | tee -a ${OUTPUT_DIRECTORY}/${TEST_PROFILE_NAME}.speed
	done
fi
