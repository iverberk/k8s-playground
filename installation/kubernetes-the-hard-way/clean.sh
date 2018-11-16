#!/bin/sh

rm -rf bin/*

cd cert
./clean.sh

cd ../config
./clean.sh

cd ../
