#!/usr/bin/env bash
flags_invalid(){
printf 'invalid flags given\n'
};usage_short(){
printf 'one of the flags [-hm] must be used\n';printf 'use ‘sharkive -h’ for detailed help\n'
};usage(){
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
};while getopts ':hm:s:u' flag;do case "${flag}" in
	h)
		usage >&2;exit 2;;
	m)
		declare -gl method="${OPTARG}";printf 'using method %s\n' "${method}";;
	s)
		declare -g dl_source+=("${OPTARG}");printf 'using source %s\n' "${dl_source[*]}";;
	u)
		printf 'uploading to the Internet Archive when finished\n';declare -g should_upload='yep';;
	*)
		flags_invalid>&2;usage_short>&2;exit 1;;
	esac
	flags_present='yep'
done
if [[ "${flags_present}" != 'yep' ]];then usage_short>&2;exit 1;fi;check_commands() {
if command -v ia&>/dev/null;then declare -g ia_exists='yep';fi;if command -v yt-dlp&>/dev/null;then declare -g ytdlp_exists='yep';fi;if command -v ffmpeg&>/dev/null && command -v ffprobe&>/dev/null;then declare -g ffmpeg_exists='yep';fi
};if [[ "${method}" == 'youtube' ]];then check_commands;if [[ "${ytdlp_exists}" != 'yep' ]]; then printf '[error] yt-dlp is not installed\n'>&2;declare to_exit='yep';fi;if [[ "${ffmpeg_exists}" != 'yep' ]];then printf '[error] ffmpeg is not installed\n'>&2;declare to_exit='yep';fi;if [[ "${to_exit}" == 'yep' ]];then;printf '[error] required applications are not installed. exiting\n'>&2;exit 1;fi;printf 'required applications are installed\n';if [[ -n "${dl_source[0]}" ]];then;until yt-dlp "${dl_source[@]}" --ignore-config --use-extractors youtube --all-formats --allow-unplayable-formats --concurrent-fragments 1 --keep-fragments --abort-on-unavailable-fragment --get-comments --verbose --write-info-json --clean-info-json --no-continue --write-subs --write-auto-subs --sub-langs all --sleep-subtitles 0 --write-description --write-thumbnail --write-all-thumbnails --no-overwrites --ignore-no-formats-error --no-windows-filenames --no-restrict-filenames --extractor-args 'youtube:player_client=all;include_incomplete_formats' --output "${HOME}/.sharkive/dl/youtube/%(id)s/data/youtube-%(id)s.%(format_id)s.%(ext)s";do printf '[info] ran into an error, going again\n';done;fi;until yt-dlp "${dl_source[@]}" --format bv+ba --ignore-config --use-extractors youtube --concurrent-fragments 1 --abort-on-unavailable-fragment --embed-info-json --clean-info-json --no-continue --embed-subs --sub-langs all --verbose --sleep-subtitles 0 --embed-thumbnail --get-comments --embed-metadata --embed-chapters --embed-info-json --extractor-args 'youtube:player_client=all' --no-windows-filenames --no-restrict-filenames --output "${HOME}/.sharkive/dl/youtube/%(id)s/%(title)s.%(id)s.%(ext)s";do printf '[info] ran into an error, going again\n';done;fi;fi;printf '\n\n[info] download successful\n';fi
