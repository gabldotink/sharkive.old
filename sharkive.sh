#!/usr/bin/env bash
# sharkive [https://github.com/gabldotink/sharkive/]
# CC0 Public Domain [https://creativecommons.org/publicdomain/zero/1.0/]
#
# sharkive is a bash script to download online content,
# and optionally upload it to the Internet Archive [https://archive.org].

# import config file
source ./sharkive.config.sh

# text for -h flag
sharkive_help () {
	printf "You're using sharkive; a bash script to download online content,\n"
	printf "and optionally upload it to the Internet Archive.\n"
	printf "\n"
}

# get flags
while getopts 'h' flag; do
	case "${flag}" in
		h) sharkive_help
	esac
done