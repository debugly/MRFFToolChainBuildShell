#!/bin/bash

set -e

./make-pod.sh openssl 1.1.1l
./make-pod.sh lame 3.100
./make-pod.sh fdk-aac 2.0.2
./make-pod.sh x264 20210613
./make-pod.sh ffmpeg 4.4