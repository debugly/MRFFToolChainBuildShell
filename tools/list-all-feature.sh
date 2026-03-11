
SHELL_ROOT=$(cd "$(dirname "$0")" && pwd)

cd "$SHELL_ROOT"

cd ../build/src/macos

echo "## FFmpeg 7.1.1 Supported Protocols:$(./ffmpeg7-arm64/configure --list-protocols | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg7-arm64/configure --list-protocols
echo '```'

echo "## FFmpeg 6.1.1 Supported Protocols:$(./ffmpeg6-arm64/configure --list-protocols | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg6-arm64/configure --list-protocols
echo '```'

echo "## FFmpeg 5.1.6 Supported Protocols:$(./ffmpeg5-arm64/configure --list-protocols | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg5-arm64/configure --list-protocols
echo '```'

echo "## FFmpeg 4.0.5 Supported Protocols:$(./ffmpeg4-arm64/configure --list-protocols | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg4-arm64/configure --list-protocols
echo '```'

echo "## FFmpeg 7.1.1 Supported Encoders:$(./ffmpeg7-arm64/configure --list-encoders | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg7-arm64/configure --list-encoders
echo '```'

echo "## FFmpeg 6.1.1 Supported Encoders:$(./ffmpeg6-arm64/configure --list-encoders | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg6-arm64/configure --list-encoders
echo '```'

echo "## FFmpeg 5.1.6 Supported Encoders:$(./ffmpeg5-arm64/configure --list-encoders | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg5-arm64/configure --list-encoders
echo '```'

echo "## FFmpeg 4.0.5 Supported Encoders:$(./ffmpeg4-arm64/configure --list-encoders | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg4-arm64/configure --list-encoders
echo '```'

echo "## FFmpeg 7.1.1 Supported Decoders:$(./ffmpeg7-arm64/configure --list-decoders | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg7-arm64/configure --list-decoders
echo '```'

echo "## FFmpeg 6.1.1 Supported Decoders:$(./ffmpeg6-arm64/configure --list-decoders | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg6-arm64/configure --list-decoders
echo '```'

echo "## FFmpeg 5.1.6 Supported Decoders:$(./ffmpeg5-arm64/configure --list-decoders | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg5-arm64/configure --list-decoders
echo '```'

echo "## FFmpeg 4.0.5 Supported Decoders:$(./ffmpeg4-arm64/configure --list-decoders | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg4-arm64/configure --list-decoders
echo '```'

echo "## FFmpeg 7.1.1 Supported Demuxers:$(./ffmpeg7-arm64/configure --list-demuxers | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg7-arm64/configure --list-demuxers
echo '```'

echo "## FFmpeg 6.1.1 Supported Demuxers:$(./ffmpeg6-arm64/configure --list-demuxers | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg6-arm64/configure --list-demuxers
echo '```'

echo "## FFmpeg 5.1.6 Supported Demuxers:$(./ffmpeg5-arm64/configure --list-demuxers | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg5-arm64/configure --list-demuxers
echo '```'

echo "## FFmpeg 4.0.5 Supported Demuxers:$(./ffmpeg4-arm64/configure --list-demuxers | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg4-arm64/configure --list-demuxers
echo '```'

echo "## FFmpeg 7.1.1 Supported Muxers:$(./ffmpeg7-arm64/configure --list-muxers | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg7-arm64/configure --list-muxers
echo '```'

echo "## FFmpeg 6.1.1 Supported Muxers:$(./ffmpeg6-arm64/configure --list-muxers | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg6-arm64/configure --list-muxers
echo '```'

echo "## FFmpeg 5.1.6 Supported Muxers:$(./ffmpeg5-arm64/configure --list-muxers | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg5-arm64/configure --list-muxers
echo '```'

echo "## FFmpeg 4.0.5 Supported Muxers:$(./ffmpeg4-arm64/configure --list-muxers | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg4-arm64/configure --list-muxers
echo '```'

echo "## FFmpeg 7.1.1 Supported Filters:$(./ffmpeg7-arm64/configure --list-filters | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg7-arm64/configure --list-filters
echo '```'

echo "## FFmpeg 6.1.1 Supported Filters:$(./ffmpeg6-arm64/configure --list-filters | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg6-arm64/configure --list-filters
echo '```'

echo "## FFmpeg 5.1.6 Supported Filters:$(./ffmpeg5-arm64/configure --list-filters | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg5-arm64/configure --list-filters
echo '```'

echo "## FFmpeg 4.0.5 Supported Filters:$(./ffmpeg4-arm64/configure --list-filters | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg4-arm64/configure --list-filters
echo '```'

echo "## FFmpeg 7.1.1 Supported Bitstream Filters:$(./ffmpeg7-arm64/configure --list-bsfs | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg7-arm64/configure --list-bsfs
echo '```'

echo "## FFmpeg 6.1.1 Supported Bitstream Filters:$(./ffmpeg6-arm64/configure --list-bsfs | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg6-arm64/configure --list-bsfs

echo "## FFmpeg 5.1.6 Supported Bitstream Filters:$(./ffmpeg5-arm64/configure --list-bsfs | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg5-arm64/configure --list-bsfs
echo '```'

echo "## FFmpeg 4.0.5 Supported Bitstream Filters:$(./ffmpeg4-arm64/configure --list-bsfs | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg4-arm64/configure --list-bsfs
echo '```'

echo "## FFmpeg 7.1.1 Supported Protocols:$(./ffmpeg7-arm64/configure --list-protocols | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg7-arm64/configure --list-protocols
echo '```'

echo "## FFmpeg 6.1.1 Supported Protocols:$(./ffmpeg6-arm64/configure --list-protocols | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg6-arm64/configure --list-protocols
echo '```'

echo "## FFmpeg 5.1.6 Supported Protocols:$(./ffmpeg5-arm64/configure --list-protocols | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg5-arm64/configure --list-protocols
echo '```'

echo "## FFmpeg 4.0.5 Supported Protocols:$(./ffmpeg4-arm64/configure --list-protocols | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg4-arm64/configure --list-protocols
echo '```'

echo "## FFmpeg 7.1.1 Supported Devices:$(./ffmpeg7-arm64/configure --list-devices | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg7-arm64/configure --list-devices
echo '```'

echo "## FFmpeg 6.1.1 Supported Devices:$(./ffmpeg6-arm64/configure --list-devices | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg6-arm64/configure --list-devices
echo '```'

echo "## FFmpeg 5.1.6 Supported Devices:$(./ffmpeg5-arm64/configure --list-devices | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg5-arm64/configure --list-devices
echo '```'

echo "## FFmpeg 4.0.5 Supported Devices:$(./ffmpeg4-arm64/configure --list-devices | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg4-arm64/configure --list-devices
echo '```'

echo "## FFmpeg 7.1.1 Supported Hardware Accelerators:$(./ffmpeg7-arm64/configure --list-hwaccels | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg7-arm64/configure --list-hwaccels
echo '```'

echo "## FFmpeg 6.1.1 Supported Hardware Accelerators:$(./ffmpeg6-arm64/configure --list-hwaccels | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg6-arm64/configure --list-hwaccels
echo '```'

echo "## FFmpeg 5.1.6 Supported Hardware Accelerators:$(./ffmpeg5-arm64/configure --list-hwaccels | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg5-arm64/configure --list-hwaccels
echo '```'

echo "## FFmpeg 4.0.5 Supported Hardware Accelerators:$(./ffmpeg4-arm64/configure --list-hwaccels | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg4-arm64/configure --list-hwaccels
echo '```'

echo "## FFmpeg 7.1.1 Supported Input Devices:$(./ffmpeg7-arm64/configure --list-indevs | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg7-arm64/configure --list-indevs
echo '```'

echo "## FFmpeg 6.1.1 Supported Input Devices:$(./ffmpeg6-arm64/configure --list-indevs | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg6-arm64/configure --list-indevs
echo '```'

echo "## FFmpeg 5.1.6 Supported Input Devices:$(./ffmpeg5-arm64/configure --list-indevs | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg5-arm64/configure --list-indevs
echo '```'  

echo "## FFmpeg 4.0.5 Supported Input Devices:$(./ffmpeg4-arm64/configure --list-indevs | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg4-arm64/configure --list-indevs
echo '```'

echo "## FFmpeg 7.1.1 Supported Output Devices:$(./ffmpeg7-arm64/configure --list-outdevs | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg7-arm64/configure --list-outdevs
echo '```'

echo "## FFmpeg 6.1.1 Supported Output Devices:$(./ffmpeg6-arm64/configure --list-outdevs | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg6-arm64/configure --list-outdevs
echo '```'

echo "## FFmpeg 5.1.6 Supported Output Devices:$(./ffmpeg5-arm64/configure --list-outdevs | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg5-arm64/configure --list-outdevs
echo '```'

echo "## FFmpeg 4.0.5 Supported Output Devices:$(./ffmpeg4-arm64/configure --list-outdevs | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg4-arm64/configure --list-outdevs
echo '```'

echo "## FFmpeg 7.1.1 Supported Bitstream Filters:$(./ffmpeg7-arm64/configure --list-bsfs | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg7-arm64/configure --list-bsfs
echo '```'

echo "## FFmpeg 6.1.1 Supported Bitstream Filters:$(./ffmpeg6-arm64/configure --list-bsfs | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg6-arm64/configure --list-bsfs
echo '```'

echo "## FFmpeg 5.1.6 Supported Bitstream Filters:$(./ffmpeg5-arm64/configure --list-bsfs | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg5-arm64/configure --list-bsfs
echo '```'

echo "## FFmpeg 4.0.5 Supported Bitstream Filters:$(./ffmpeg4-arm64/configure --list-bsfs | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg4-arm64/configure --list-bsfs
echo '```'

echo "## FFmpeg 7.1.1 Supported Parsers:$(./ffmpeg7-arm64/configure --list-parsers | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg7-arm64/configure --list-parsers
echo '```'

echo "## FFmpeg 6.1.1 Supported Parsers:$(./ffmpeg6-arm64/configure --list-parsers | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg6-arm64/configure --list-parsers
echo '```'

echo "## FFmpeg 5.1.6 Supported Parsers:$(./ffmpeg5-arm64/configure --list-parsers | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg5-arm64/configure --list-parsers
echo '```'

echo "## FFmpeg 4.0.5 Supported Parsers:$(./ffmpeg4-arm64/configure --list-parsers | tr -s '[:space:]' '\n' | grep -v '^$' | wc -l | tr -s '[:space:]' ' ')"
echo '```'
./ffmpeg4-arm64/configure --list-parsers
echo '```'
