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

# exit trap
exit_trap () {
    printf '[error] exit signal received, ending\n'
    exit 1
}

trap 'exit_trap' SIGINT

# invalid flags message
flags_invalid () {
    printf 'invalid flags given\n'
}

# short usage text
usage_short () {
    printf 'one of the flags [-hm] must be used\n'
    printf 'use ‘sharkive -h’ for detailed help\n'
}

# usage text
usage () {
    cat << 'eof'
usage: sharkive [-h] [-m method -s source] [-u]

you’re using sharkive; a bash script to download online content,
and optionally upload it to the Internet Archive.

flags:
  -h  print this help message
  -m  define “method” for downloading
  -s  define download source (URI)
      (use multiple times for multiple sources)
  -u  upload to the Internet Archive
      once download is finished
eof
}

unset method
unset source
unset to_upload
unset to_exit
unset flags_present

# get flags
while getopts ':hm:s:u' flag; do
    case "${flag}" in
    h) # help
        usage >&2
        exit 2
        ;;
    m) # download method
        declare -l method="${OPTARG}"
        ;;
    s) # download source
        declare -a source+=("${OPTARG}")
        ;;
    u) # upload
        declare to_upload='yep'
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

# show user-declared options
show_options () {
    if [[ -n "${method}" ]]; then
        printf '[info] using method %s\n' "${method}"
    else
        printf '[error] no method defined\n'
        declare -g to_exit='yep'
    fi
    if [[ -n "${source}" ]]; then
        printf '[info] using source %s\n' "${source}"
    else
        printf '[error] no source defined\n'
        declare -g to_exit='yep'
    fi
    if [[ "${to_upload}" == 'yep' ]]; then
        printf '[info] uploading to the Internet Archive when finished\n'
    fi
    if [[ "${to_exit}" == 'yep' ]]; then
        printf '[error] required options are not defined, exiting\n'
        exit 1
    fi
}

show_options

# check if programs are installed
check_commands () {
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
        printf '[error] required applications are not installed, exiting\n' >&2
        exit 1
    fi

    if [[ -n "${dl_source[0]}" ]]; then
        # download raw data
        until yt-dlp \
            --abort-on-unavailable-fragment \
            --allow-unplayable-formats \
            --clean-info-json \
            --concurrent-fragments 1 \
            --dump-json \
            --dump-pages \
            --dump-single-json \
            --extractor-args \
             'youtube:player_client=all;include_incomplete_formats' \
            --fixup 'warn' \
            --format 'all' \
            --geo-bypass \
            --get-comments \
            --ignore-config \
            --ignore-no-formats-error \
            --keep-fragments \
            --keep-video \
            --list-formats \
            --list-subs \
            --max-sleep-interval 0 \
            --newline \
            --no-audio-multistreams \
            --no-call-home \
            --no-check-formats \
            --no-clean-info-json \
            --no-config-locations \
            --no-continue \
            --no-cookies \
            --no-cookies-from-browser \
            --no-embed-chapters \
            --no-embed-info-json \
            --no-embed-metadata \
            --no-embed-subs \
            --no-embed-thumbnail \
            --no-exec \
            --no-force-keyframes-at-cuts \
            --no-format-sort-force \
            --no-include-ads \
            --no-mark-watched \
            --no-overwrites \
            --no-playlist-reverse \
            --no-post-overwrites \
            --no-prefer-avconv \
            --no-prefer-free-formats \
            --no-remove-chapters \
            --no-restrict-filenames \
            --no-simulate \
            --no-split-chapters \
            --no-sponsorblock \
            --no-sponskrub \
            --no-sponskrub-cut \
            --no-sponskrub-force \
            --no-video-multistreams \
            --no-windows-filenames \
            --output \
             "${HOME}/.sharkive/dl/youtube/%(id)s/youtube-%(id)s.%(format_id)s.%(ext)s" \
            --prefer-ffmpeg \
            --print 'description' \
            --print 'duration_string' \
            --print 'filename' \
            --print 'format' \
            --print 'id' \
            --print 'thumbnail' \
            --print 'title' \
            --print 'urls' \
            --print-traffic \
            --progress \
            --sleep-interval '0' \
            --sleep-requests '0' \
            --sleep-subtitles '0' \
            --sponsorblock-mark '-all' \
            --sponsorblock-remove '-all' \
            --sub-langs 'all' \
            --use-extractors 'youtube' \
            --verbose \
            --write-all-thumbnails \
            --write-annotations \
            --write-auto-subs \
            --write-description \
            --write-desktop-link \
            --write-info-json \
            --write-pages \
            --write-subs \
            --write-thumbnail \
            --write-url-link \
            --write-webloc-link \
            --youtube-include-dash-manifest \
            --youtube-include-hls-manifest \
            --youtube-print-sig-code \
            -- "${dl_source[@]}"
        do printf '[info] ran into an error, going again\n'; done
    fi
    printf '\n\n[info] download successful\n'
fi
