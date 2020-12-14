#! /bin/sh

unit ()
{
	echo "--- $1 ---"
	if ./driver_csv < "$1" ; then
		>&2 echo "PASS"
	else
		>&2 echo "FAIL"
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
