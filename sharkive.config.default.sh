# sharkive configuration
# the default config can be restored from sharkive.config.default.sh

# maximum download threads to use
export dl_threads=2

# maximum retries of various types
export retries=50
export fragment_retries=50

# maximum retries on total yt-dlp failure
export failure_retries=999

# sharkive downloads location. no trailing slash!
export dl_location="$HOME/.sharkive/dl"
