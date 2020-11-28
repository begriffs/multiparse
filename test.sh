#! /bin/sh

for f in test/*.csv
do
	if ./driver_csv < "$f" ; then
		echo "x $f"
	else
		echo "FAIL: $f"
	fi
done
