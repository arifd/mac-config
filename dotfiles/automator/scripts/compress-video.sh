
#!/usr/bin/env bash

notify() {
    osascript \
        -e 'on run argv' \
        -e 'display notification (item 1 of argv) with title (item 2 of argv)' \
        -e 'end run' \
        "$1" "$2"
}

fail() {
    notify "$1" "Video Compression Failed"
    exit "$2"
}

# Validate the selected file.
input_file="${1:-}"

[[ -f "$input_file" ]] ||
    fail "Select a video file in Finder, then run this Quick Action." 2

# Locate FFmpeg.
ffmpeg_bin=$(command -v ffmpeg) ||
    fail "FFmpeg isn't available to this Quick Action." 127

# Place the compressed video alongside the original.
output_file="${input_file%.*}_compressed.mp4"

# Run compression in Terminal.
compression_script=$(cat <<'EOF'
ffmpeg_bin="$1"
input_file="$2"
output_file="$3"

# Never overwrite an existing output.
if [[ -e "$output_file" ]]; then
    printf 'Output already exists: %s\n' "$output_file"
    exit 1
fi

# Create a temporary workspace beside the output.
temp_dir=$(mktemp -d "${output_file}.work.XXXXXXXX") || exit 1
temp_file="$temp_dir/video.mp4"

cleanup() {
    rm -f "$temp_file"
    rmdir "$temp_dir"
}

trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP

# Encode using software HEVC for better compression efficiency.
"$ffmpeg_bin" \
    -nostdin \
    -hide_banner \
    -loglevel error \
    -stats \
    -stats_period 1 \
    -i "$input_file" \
    -c:v libx265 \
    -crf 28 \
    -c:a aac \
    "$temp_file" || exit $?

# Publish only the completed video.
mv -n "$temp_file" "$output_file"
EOF
)

# Quote the script and arguments for Terminal.
printf -v terminal_command '%q ' \
    /bin/bash -c "$compression_script" _ \
    "$ffmpeg_bin" "$input_file" "$output_file"

osascript \
    -e 'on run argv' \
    -e 'tell application "Terminal" to do script (item 1 of argv)' \
    -e 'end run' \
    "$terminal_command"
