#! /bin/sh

unit ()
{
	if ./driver_csv < "$1" ; then
		>&2 echo "PASS: $1"
	else
		>&2 echo "FAIL: $1"
	fi
}

if [ "$#" -eq 1 ] ; then
	unit "$1"
else
	for f in test/*.csv
	do
		unit "$f"
	done
fi
