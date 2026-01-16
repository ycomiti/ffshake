#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

#######################################
# Defaults
#######################################
INPUT=""
OUTPUT="output.mp4"
RESOLUTION="1920x1080"
ROTATION=true
DURATION=10  # default duration if the input is an image (seconds)

AMP_X=30
AMP_Y=30
ROT_DEG=4

SPEED_X=3
SPEED_Y=3.5
SPEED_ROT=4

CHROMA_CB=4
CHROMA_CR=-4

OVERSCAN_W=3000
OVERSCAN_H=1700

ARGS=()  # array for additional FFmpeg arguments

#######################################
# Usage
#######################################
usage() {
  cat <<EOF
Usage:
  $0 -i input_file [options]

Options:
  -o FILE        Output file (default: output.mp4)
  -r WxH         Output resolution (default: 1920x1080)
  --rotate       Enable rotation (default)
  --no-rotate    Disable rotation
  --duration N   Duration in seconds if input is an image (default 10)
  --amp-x N      Horizontal wiggle amplitude
  --amp-y N      Vertical wiggle amplitude
  --rot-deg N    Rotation amplitude (degrees)
  --speed-x N    Horizontal wiggle period (seconds)
  --speed-y N    Vertical wiggle period (seconds)
  --speed-rot N  Rotation period (seconds)
  --chroma-cb N  Chromatic aberration Cb shift
  --chroma-cr N  Chromatic aberration Cr shift
  --overscan WxH Overscan resolution (default 3000x1700)
  --args ARG...  Additional FFmpeg arguments (all arguments after --args are passed)
EOF
  exit 1
}

#######################################
# Parse command-line arguments
#######################################
while [[ $# -gt 0 ]]; do
  case "$1" in
    -i) INPUT="$2"; shift 2 ;;
    -o) OUTPUT="$2"; shift 2 ;;
    -r) RESOLUTION="$2"; shift 2 ;;
    --rotate) ROTATION=true; shift ;;
    --no-rotate) ROTATION=false; shift ;;
    --duration) DURATION="$2"; shift 2 ;;
    --amp-x) AMP_X="$2"; shift 2 ;;
    --amp-y) AMP_Y="$2"; shift 2 ;;
    --rot-deg) ROT_DEG="$2"; shift 2 ;;
    --speed-x) SPEED_X="$2"; shift 2 ;;
    --speed-y) SPEED_Y="$2"; shift 2 ;;
    --speed-rot) SPEED_ROT="$2"; shift 2 ;;
    --chroma-cb) CHROMA_CB="$2"; shift 2 ;;
    --chroma-cr) CHROMA_CR="$2"; shift 2 ;;
    --overscan) OVERSCAN_W="${2%x*}"; OVERSCAN_H="${2#*x}"; shift 2 ;;
    --args) shift
            while [[ $# -gt 0 && "$1" != --* ]]; do
              ARGS+=("$1")  # store extra FFmpeg arguments in array
              shift
            done ;;
    -h|--help) usage ;;
    *) echo "❌ Unknown option: $1"; usage ;;
  esac
done

#######################################
# Validation
#######################################
[[ -z "$INPUT" ]] && { echo "❌ Input file required"; usage; }
[[ ! -f "$INPUT" ]] && { echo "❌ Input file not found"; exit 1; }
[[ ! "$RESOLUTION" =~ ^[0-9]+x[0-9]+$ ]] && { echo "❌ Invalid resolution"; exit 1; }

W="${RESOLUTION%x*}"
H="${RESOLUTION#*x}"

#######################################
# Build FFmpeg filtergraph
#######################################
FILTERS=()
$ROTATION && FILTERS+=(
  "rotate=PI/180*(-${ROT_DEG}*sin(2*PI*t/${SPEED_ROT})):fillcolor=none"
)
FILTERS+=(
  "scale=${OVERSCAN_W}:${OVERSCAN_H}"
  "chromashift=cbh=${CHROMA_CB}:crh=${CHROMA_CR}"
  "crop=${W}:${H}:(iw-${W})/2+${AMP_X}*sin(2*PI*t/${SPEED_X}):(ih-${H})/2+${AMP_Y}*sin(2*PI*t/${SPEED_Y})"
  "format=yuv420p"
)
VF="$(IFS=,; echo "${FILTERS[*]}")"

#######################################
# Detect if input is an image
#######################################
EXT="${INPUT##*.}"
EXT="${EXT,,}" # convert to lowercase
IS_IMAGE=false
case "$EXT" in
  png|jpg|jpeg|webp|tiff|bmp) IS_IMAGE=true ;;
esac

#######################################
# Run FFmpeg
#######################################
if [[ "$IS_IMAGE" == true ]]; then
  # Loop image and apply filtergraph for duration
  ffmpeg -y -loop 1 -t "$DURATION" -i "$INPUT" \
    -vf "$VF" \
    "${ARGS[@]}" \
    "$OUTPUT"
else
  # Process video input with filtergraph
  ffmpeg -y -i "$INPUT" \
    -vf "$VF" \
    "${ARGS[@]}" \
    "$OUTPUT"
fi
