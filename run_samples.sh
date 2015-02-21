#!/bin/sh

SRC_FILES="./src/Extractor.vala ./src/Frame.vala ./src/Printer.vala ./src/Stacktrace.vala" 
OPTIONS="-g -X -rdynamic -X -w --pkg linux --pkg gee-0.8"

clear
# Null reference
rm ./samples/sample_sigsegv
valac ${OPTIONS} -o ./samples/sample_sigsegv ./samples/vala_file.vala ./samples/error_sigsegv.vala ./samples/module/OtherModule.vala ${SRC_FILES}
./samples/sample_sigsegv

# Uncaught error
rm ./samples/sample_sigtrap
valac ${OPTIONS} -o ./samples/sample_sigtrap ./samples/error_sigtrap.vala ${SRC_FILES}
./samples/sample_sigtrap

# Critical assert
rm ./samples/sample_sigabrt
valac ${OPTIONS} -o ./samples/sample_sigabrt ./samples/error_sigabrt.vala ${SRC_FILES}
./samples/sample_sigabrt

# Configure colors
rm ./samples/sample_colors
valac ${OPTIONS} -o ./samples/sample_colors ./samples/error_colors.vala ${SRC_FILES}
./samples/sample_colors