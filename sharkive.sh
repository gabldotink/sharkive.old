#!/usr/bin/env bash
# sharkive [https://github.com/gabldotink/sharkive/]
# CC0 Public Domain [https://creativecommons.org/publicdomain/zero/1.0/]
#
# this is the Unix version, for Unix and Unix-like systems such as
# Linux; MacOS; Cygwin; or, like, Solaris or something.
# a Windows version is, as they say, "in the works."
# you can still use Cygwin though; in fact, I'm using Cygwin
# to test this script.
#
# sharkive is a bash script to download online content,
# and optionally upload it to the Internet Archive [https://archive.org].

# unset variables
unset method
unset dl_source
unset should_upload
unset flags_present
unset ia_exists
unset ytdlp_exists
unset ffmpeg_exists

# import config file
source ./sharkive.config.default.sh

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
	printf "you're using sharkive; a bash script to download online content,\n"
	printf "and optionally upload it to the Internet Archive.\n"
	printf "\n"
	printf "flags:\n"
	printf "\t-h\tprint this help message\n"
	printf "\t-m\tdefine \"method\" for downloading\n"
	printf "\t-s\tdefine download source (URI)\n"
	printf "\t\t(use multiple times for multiple sources)\n"
	printf "\t-u\tupload to the Internet Archive once done\n"
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
		printf "using method %s\n" "$method"
		;;
	s) # download source
		dl_source+=("$OPTARG")
		printf "using source %s\n" "${dl_source[*]}"
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

# check if programs are installed. near-ubiquitous commands like
#   printf and wget are not checked
check_commands() {
	if command -v ia &>/dev/null; then ia_exists='yep'; fi
	if command -v yt-dlp &>/dev/null; then ytdlp_exists='yep'; fi
	if command -v ffmpeg &>/dev/null; then ffmpeg_exists='yep'; fi
}

# archive from youtube
if [ "$method" == 'youtube' ]; then
	check_commands
	if [ "$ytdlp_exists" != 'yep' ]; then
		printf "error: yt-dlp is not installed\n" >&2
		to_exit='yep'
	fi
	if [ "$ffmpeg_exists" != 'yep' ]; then
		printf "error: ffmpeg is not installed\n" >&2
		to_exit='yep'
	fi
	if [ "$to_exit" == 'yep' ]; then
		printf "error: required applications are not installed. exiting\n" >&2
		exit 1
	fi
	printf "required applications are installed\n"

	if [ -n "${dl_source[0]}" ]; then
		failure_retries_two="$failure_retries"
		# download raw data
		until yt-dlp "${dl_source[@]}" \
		--ignore-config --use-extractors youtube \
		--all-formats --allow-unplayable-formats \
		--concurrent-fragments "$dl_threads" \
		--retries "$retries" --fragment-retries "$fragment_retries" \
		--keep-fragments --abort-on-unavailable-fragment \
		--get-comments --verbose \
		--write-info-json --clean-info-json --no-continue \
		--write-subs --write-auto-subs --sub-langs all \
		--sleep-subtitles 0 --write-description \
		--write-thumbnail --write-all-thumbnails --no-overwrites \
		--ignore-no-formats-error --no-windows-filenames \
		--extractor-args "youtube:player_client=all;include_incomplete_formats" \
		--output "$dl_location/youtube/%(id)s/%(id)s.%(format_id)s.%(ext)s"
		do if [ "$failure_retries" -gt 0 ]; then
				# these go to stdout because it makes more sense when redirecting
				printf "unsuccessful download.\n"
				printf "retrying %s more times\n" "$failure_retries"
				failure_retries="$((failure_retries-1))"
			else
				printf "no more retries. exiting\n"
				exit 1
			fi
		done
		first_dl_success='yep'
		# now make a bv+ba video with attachments
		if [ "$first_dl_success" == 'yep' ]; then
			until yt-dlp "${dl_source[@]}" \
			--ignore-config --use-extractors youtube \
			--concurrent-fragments "$dl_threads" \
			--retries "$retries" --fragment-retries "$fragment_retries" \
			--abort-on-unavailable-fragment \
			--embed-info-json --clean-info-json --no-continue \
			--embed-subs --sub-langs all --verbose \
			--sleep-subtitles 0 \
			--embed-thumbnail --get-comments \
			--embed-metadata --embed-chapters --embed-info-json \
			--extractor-args "youtube:player_client=all" --no-windows-filenames \
			--output "$dl_location/youtube/%(id)s/full/%(title)s.%(id)s.%(ext)s"
			do if [ "$failure_retries_two" -gt 0 ]; then
					printf "unsuccessful download.\n"
					printf "retrying %s more times\n" "$failure_retries_two"
					failure_retries_two="$((failure_retries_two-1))"
				else
					printf "no more retries. exiting\n"
					exit 1
				fi
			done
		fi
	fi
	printf "\n\ndownload successful\n"
fi
