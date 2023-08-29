#!/bin/bash
len=$#
if [ $len -ne 1 ]; then
    echo "Usage ./newproj.sh projName";
    exit 1;
fi
cp -r ./Template ./$1
rm -rf $1/src_BSV/*
cd $1/Build
make full_clean