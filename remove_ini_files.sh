#!/bin/sh

echo "removing desktop.ini files"
find . -type f -name 'desktop.ini' -exec rm -f {} \;

