#!/usr/bin/env bash
# sharkive [https://github.com/gabldotink/sharkive/]
# CC0 Public Domain [https://creativecommons.org/publicdomain/zero/1.0/]
#
# note to code readers: this is my first project, so comments are a bit
# gratuitous on occasion because otherwise I might forget what they do :/
#
# sharkive is a bash script to download online content,
# and optionally upload it to the Internet Archive [https://archive.org].

# unset relevant variables
unset flags_present
unset ia_present
unset ytdlp_present
unset ffmpeg_present

# import config file
source ./sharkive.config.sh

# invalid flags message
flags_invalid() {
	printf "invalid flags given\n"
}

# short usage text
usage_short() {
	printf "one of the flags [-hm] must be used\n"
	printf "use 'sharkive -h' for detailed help\n"
}

# usage text
usage() {
	printf "You're using sharkive; a bash script to download online content,\n"
	printf "and optionally upload it to the Internet Archive.\n"
	printf "\n"
	printf ""
}

# get flags
while getopts ':hm:s:u' flag; do
	case "$flag" in
	h) # help
		usage >&2
		exit 0
		;;
	m) # download method
		declare -l method="$OPTARG" # store value as lowercase
		printf "using method %s\n" "$method" >&1
		;;
	s) # download source
		dl_source+=("$OPTARG")
		printf "using source %s\n" "$dl_source" >&1
		;;
	u) # upload
		printf "uploading to the Internet Archive when finished\n"
		should_upload='yep'
		;;
	*) # invalid flags
		flags_invalid >&2
		usage_short >&2
		exit 1
		;;
	esac
	flags_present='yep'
done

# show short usage if no flags are given (this is a very insightful comment)
if [ "$flags_present" != 'yep' ]; then
	usage_short >&2
	exit 1
fi

# check if programs are installed
check_commands() {
	if command -v ia &> /dev/null ; then ia_present='yep' ; fi
	if command -v yt-dlp &> /dev/null ; then ytdlp_present='yep' ; fi
	if command -v ffmpeg &> /dev/null ; then ffmpeg_present='yep' ; fi
}

# archive from youtube
if [ "$method" == 'youtube' ]; then
	check_commands
	if [ "$ytdlp_present" != 'yep' ]; then
		printf "error: yt-dlp is not installed\n"
		exit 1
	fi
	if [ "$ffmpeg_present" != 'yep' ]; then
		printf "error: ffmpeg is not installed\n"
		exit 1
	fi
	printf "required applications are installed\n"
fi
