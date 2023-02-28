# sharkive configuration
# the default config can be restored from sharkive.config.default.sh

# maximum download threads to use
declare -i dl_threads
export dl_threads=2

# maximum retries of various types
declare -i retries
export retries=50
declare -i fragment_retries
export fragment_retries=50

# maximum retries on total yt-dlp failure
declare -i failure_retries
export failure_retries=999

# sharkive downloads location. no trailing slash!
export dl_location="${HOME}/.sharkive/dl"
