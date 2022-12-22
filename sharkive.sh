#!/usr/bin/env bash
# sharkive [https://github.com/gabldotink/sharkive/]
# CC0 Public Domain [https://creativecommons.org/publicdomain/zero/1.0/]
#
# sharkive is a bash script to download online content,
# and optionally upload it to the Internet Archive [https://archive.org].

# import config file
source ./sharkive.config.sh

# invalid flags message
flags_invalid () {
	printf "invalid flags given\n"
}

# short usage text
usage_short () {
	printf "usage:\n"
	printf "sharkive [-hm]\n"
	printf "use 'sharkive -h' for more detailed help\n"
}

# usage text
usage () {
	printf "You're using sharkive; a bash script to download online content,\n"
	printf "and optionally upload it to the Internet Archive.\n"
	printf "\n"
	printf ""
}

# get flags
while getopts ':hm:' flag; do
	case $flag in
	(h) usage >&1
	    exit 0 ;;
	(m) printf "m with $OPTARG\n" >&1 ;;
	(*) flags_invalid >&2
	    usage_short >&2
	    exit 1 ;;
	esac
	no_flags='false'
done

# show short usage if no flags are given (this is a very insightful comment)
if [ "$no_flags" != 'false' ] ; then usage_short ; exit 1 ; fi

printf "end of script\n"
