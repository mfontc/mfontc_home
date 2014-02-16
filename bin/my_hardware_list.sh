#!/bin/bash

sudo echo -n ''

for dmitype in bios system baseboard chassis processor memory cache connector slot; do
	echo "#"
	echo "# dmidecode --type $dmitype"
	echo "#"
	sudo dmidecode --type $dmitype
done

