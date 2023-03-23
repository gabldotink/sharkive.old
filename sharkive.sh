#!/usr/bin/env bash
# sharkive [https://github.com/gabldotink/sharkive/]
# CC0 Public Domain [https://creativecommons.org/publicdomain/zero/1.0/]
#
# this is the *nix version, for Unix and Unix-like systems such as
# Linux; MacOS; Cygwin; Termux; BSD; or, like, Solaris or something.
# a Windows version is, as they say, “in the works.”
# you can still use Cygwin on Windows, though.
#
# sharkive is a bash script to download online content,
# and optionally upload it to the Internet Archive [https://archive.org].

# invalid flags message
flags_invalid() {
	printf 'invalid flags given\n'
}

# short usage text
usage_short() {
	printf 'one of the flags [-hm] must be used\n'
	printf 'use ‘sharkive -h’ for detailed help\n'
}

# usage text
usage() {
	cat << 'eof'
usage: sharkive [-h] [-m method -s source] [-u]

you’re using sharkive; a bash script to download online content,
and optionally upload it to the Internet Archive.

flags:
  -h  print this help message
  -m  define “method” for downloading
  -s  define download source (URI)
      (use multiple times for multiple sources)
  -u  upload to the Internet Archive once download is finished
eof
}

# get flags
while getopts ':hm:s:u' flag; do
	case "${flag}" in
	h) # help
		usage >&2
		exit 2
		;;
	m) # download method
		declare -gl method="${OPTARG}" # store value as lowercase
		printf 'using method %s\n' "${method}"
		;;
	s) # download source
		declare -g dl_source+=("${OPTARG}")
		printf 'using source %s\n' "${dl_source[*]}"
		;;
	u) # upload
		printf 'uploading to the Internet Archive when finished\n'
		declare -g should_upload='yep'
		;;
	*) # invalid flags
		flags_invalid >&2
		usage_short >&2
		exit 1
		;;
	esac
	declare flags_present='yep'
done

# show short usage if no flags are given (this is a very insightful comment)
if [[ "${flags_present}" != 'yep' ]]; then
	usage_short >&2
	exit 1
fi

# check if programs are installed
check_commands() {
	if command -v ia &> /dev/null; then
	declare -g ia_exists='yep'; fi
	#if command -v ytarchive &> /dev/null; then
	#declare -g ytarchive_exists='yep'; fi
	#if command -v youtube-dl &> /dev/null; then
	#declare -g ytdl_exists='yep'; fi
	if command -v yt-dlp &> /dev/null; then
	declare -g ytdlp_exists='yep'; fi
	#if command -v you-get &> /dev/null; then
	#declare -g youget_exists='yep'; fi
	if command -v ffmpeg &> /dev/null \
	&& command -v ffprobe &> /dev/null; then
	declare -g ffmpeg_exists='yep'; fi
}

# archive from youtube
if [[ "${method}" == 'youtube' ]]; then
	check_commands
	if [[ "${ytdlp_exists}" != 'yep' ]]; then
		printf '[error] yt-dlp is not installed\n' >&2
		declare to_exit='yep'
	fi
	if [[ "${ffmpeg_exists}" != 'yep' ]]; then
		printf '[error] ffmpeg is not installed\n' >&2
		declare to_exit='yep'
	fi
	if [[ "${to_exit}" == 'yep' ]]; then
		printf '[error] required applications are not installed. exiting\n' >&2
		exit 1
	fi
	printf 'required applications are installed\n'

	if [[ -n "${dl_source[0]}" ]]; then
		# download raw data
		until yt-dlp "${dl_source[@]}" \
		--ignore-config --use-extractors youtube \
		--all-formats --allow-unplayable-formats \
		--concurrent-fragments 1 \
		--keep-fragments --abort-on-unavailable-fragment \
		--get-comments --verbose \
		--write-info-json --clean-info-json --no-continue \
		--write-subs --write-auto-subs --sub-langs all \
		--sleep-subtitles 0 --write-description \
		--write-thumbnail --write-all-thumbnails --no-overwrites \
		--ignore-no-formats-error --no-windows-filenames --no-restrict-filenames \
		--extractor-args 'youtube:player_client=all;include_incomplete_formats' \
		--output "${HOME}/.sharkive/dl/youtube/%(id)s/data/youtube-%(id)s.%(format_id)s.%(ext)s"
		do printf '[info] ran into an error, going again\n'; done
	fi
		# now make a bv+ba video with attachments
		until yt-dlp "${dl_source[@]}" \
		--format bv+ba
		--ignore-config --use-extractors youtube \
		--concurrent-fragments 1 \
		--abort-on-unavailable-fragment \
		--embed-info-json --clean-info-json --no-continue \
		--embed-subs --sub-langs all --verbose \
		--sleep-subtitles 0 \
		--embed-thumbnail --get-comments \
		--embed-metadata --embed-chapters --embed-info-json \
		--extractor-args 'youtube:player_client=all' --no-windows-filenames --no-restrict-filenames \
		--output "${HOME}/.sharkive/dl/youtube/%(id)s/%(title)s.%(id)s.%(ext)s"
			do printf '[info] ran into an error, going again\n'; done
		fi
	fi
	printf '\n\n[info] download successful\n'
fi
