#!/bin/bash

cd gst-rtsp-server/examples
rpicam=$(vcgencmd get_camera)
substring="detected=1"
if test "${rpicam#*$substring}" != "$rpicam"
then
    echo "Rpi camera found, starting capture."
    ./launch --gst-debug=3 "( rpicamsrc bitrate=8000000 awb-mode=tungsten preview=false ! video/x-h264, width=640, height=480, framerate=30/1 ! h264parse ! rtph264pay name=pay0 pt=96 )"
else
    echo "No Rpi camera found. Searching for USB cameras..."
    #a = list devices using v4l2 | get line below line matching *camera*(usb* | take the first line | remove leading spaces
    a=$(v4l2-ctl --list-devices | awk '/[cC]amera.+\(usb/{getline; print}' | head -n 1 | sed -e 's/^[ \t]*//')
    echo "Starting capture using $a"
    # put usb webcam capture here using device $a...
fi
