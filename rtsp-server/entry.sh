#!/bin/bash

cd gst-rtsp-server/examples
rpicam=$(vcgencmd get_camera)
substring="detected=1"
if test "${rpicam#*$substring}" != "$rpicam"
then
    echo "Rpi camera found, starting capture."
    ./launch --gst-debug=3 "( rpicamsrc bitrate=8000000 awb-mode=tungsten preview=false ! video/x-h264, width=640, height=480, framerate=30/1 ! h264parse ! rtph264pay name=pay0 pt=96 )"
else
    echo "No Rpi camera found. Searching video devices..."
    # Get lowest video device
    for dev in `find /dev -iname 'video*' -printf "%f\n"`
    do
      a=$dev
    done
    echo "Starting capture using $a"
    # put usb webcam capture here...
fi
