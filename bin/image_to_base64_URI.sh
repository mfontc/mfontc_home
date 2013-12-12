#!/bin/bash

filename="$*"

mimetype=`file -b --mime-type "${filename}"`
encoded=`base64 -w 0 "${filename}"`
echo "data:$mimetype;base64,$encoded"

