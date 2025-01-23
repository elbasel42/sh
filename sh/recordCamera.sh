#!/bin/bash

# Output file name
OUTPUT_FILE="recording_$(date +%Y%m%d_%H%M%S).mp4"

# Camera device (change if needed, e.g., /dev/video0 for Linux)
CAMERA_DEVICE="/dev/video0"

# Recording duration in seconds (0 for infinite recording)
DURATION=0

# Frame rate and resolution
FRAME_RATE=30
RESOLUTION="1280x720"

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg could not be found. Please install it and try again."
    exit 1
fi

# Start recording
echo "Starting camera recording..."
if [ "$DURATION" -eq 0 ]; then
    ffmpeg -f v4l2 -framerate "$FRAME_RATE" -video_size "$RESOLUTION" -i "$CAMERA_DEVICE" "$OUTPUT_FILE"
else
    ffmpeg -f v4l2 -framerate "$FRAME_RATE" -video_size "$RESOLUTION" -i "$CAMERA_DEVICE" -t "$DURATION" "$OUTPUT_FILE"
fi

echo "Recording saved to $OUTPUT_FILE"

