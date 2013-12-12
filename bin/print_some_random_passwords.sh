#!/bin/bash

which pwgen &> /dev/null || {
    echo "### No se ha encontrado el programa 'pwgen'" > /dev/stderr
    exit 1
}

pwgen --capitalize --numerals --secure --ambiguous 16 100

