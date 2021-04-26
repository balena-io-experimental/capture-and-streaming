#!/bin/bash

# Set some values for using colored text
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

cd gst-rtsp-server/examples

if [[ -z $GST_RTSP_PIPELINE ]]
then
    rpicam=$(vcgencmd get_camera)
    substring="detected=1"
    if test "${rpicam#*$substring}" != "$rpicam"
    then
        echo "Rpi camera found, starting capture."
        ./launch --gst-debug=3 "( rpicamsrc bitrate=8000000 awb-mode=tungsten preview=false ! video/x-h264, width=640, height=480, framerate=30/1 ! h264parse ! rtph264pay name=pay0 pt=96 )"
    else
        echo "No Rpi camera found. Searching for USB cameras..."
        # below, a equals a device: list devices using v4l2 | get line below line matching *cam*(usb* | take the first line | remove leading spaces
        a=$(v4l2-ctl --list-devices | awk '/[cC]am.+\(usb/{getline; print}' | head -n 1 | sed -e 's/^[ \t]*//')
        echo "Found device ${a}."
        echo "Device supports the following formats:"
        v4l2-ctl --list-formats-ext
        if v4l2-ctl --list-formats-ext | grep -q "YUYV"
        then
            echo "${green}Starting capture of YUYV stream, 640x480, 15 fps...${reset}"
            ./launch --gst-debug=3 "( v4l2src device=$a !  v4l2convert ! video/x-raw,width=640,height=480,framerate=15/1 ! omxh264enc target-bitrate=6000000 control-rate=variable ! video/x-h264,profile=baseline ! rtph264pay name=pay0 pt=96 )" 
        else
            echo -e "${green}Starting capture of MJPG stream, 640x480, 10 fps...${reset}"
            ./launch --gst-debug=3 "( v4l2src device=$a ! image/jpeg,width=640,height=480,framerate=10/1 ! queue ! jpegdec ! omxh264enc target-bitrate=6000000 control-rate=variable ! video/x-h264,profile=baseline ! rtph264pay name=pay0 pt=96 )"
        fi
    fi

else
    echo "Custom pipeline found..."
    ./launch --gst-debug=3 "( $GST_RTSP_PIPELINE )"
fi
