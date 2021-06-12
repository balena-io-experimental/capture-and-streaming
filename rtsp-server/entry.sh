#!/bin/bash

# Set some values for using colored text
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

# Get Device ID if not already set
BALENA_DEVICE_ID=$2
if ! [ "$BALENA_DEVICE_ID" ] ; then
	BALENA_DEVICE_ID=$(curl -sSL "$BALENA_API_URL/v3/device?\$select=id,uuid&\$filter=uuid%20eq%20'$BALENA_DEVICE_UUID'" -H "Authorization: Bearer $BALENA_API_KEY" | jq '.d[0].id')
fi

echo "Using Device ID $BALENA_DEVICE_ID"

# Use Device ID to set some configurations

# startX

echo "Setting BALENA_HOST_CONFIG_start_x"

d="{\"device\": \"$BALENA_DEVICE_ID\",\"name\": \"BALENA_HOST_CONFIG_start_x\",\"value\": \"1\"}"

curl -sSL -X POST \
"$BALENA_API_URL/v6/device_config_variable" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $BALENA_API_KEY" \
--data "$d"

# gpu Mem

echo "Setting BALENA_HOST_CONFIG_gpu_mem"

d="{\"device\": \"$BALENA_DEVICE_ID\",\"name\": \"BALENA_HOST_CONFIG_gpu_mem\",\"value\": \"192\"}"

curl -sSL -X POST \
"$BALENA_API_URL/v6/device_config_variable" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $BALENA_API_KEY" \
--data "$d"

# start app with proper pipeline

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
            if [ "$R_DEVICE" = "jetson-nano" ]
            then
                echo "${green}Starting capture of YUYV stream...${reset}"
                ./launch --gst-debug=3 "( v4l2src device=$a ! nvvidconv ! video/x-raw(memory:NVMM) ! omxh264enc bitrate=6000000 control-rate=variable ! video/x-h264,profile=baseline ! rtph264pay name=pay0 pt=96 )"
            else
                echo "${green}Starting capture of YUYV stream, 640x480, 15 fps...${reset}"
                ./launch --gst-debug=3 "( v4l2src device=$a !  v4l2convert ! video/x-raw,width=640,height=480,framerate=15/1 ! omxh264enc target-bitrate=6000000 control-rate=variable ! video/x-h264,profile=baseline ! rtph264pay name=pay0 pt=96 )"
            fi 
        else
            if [ "$R_DEVICE" = "jetson-nano" ]
            then
                echo -e "${green}Starting capture of MJPG stream, 640x480, 10 fps...${reset}"
                ./launch --gst-debug=3 "( v4l2src device=$a ! image/jpeg,width=640,height=480,framerate=10/1 ! queue ! jpegdec ! omxh264enc bitrate=6000000 control-rate=variable ! video/x-h264,profile=baseline ! rtph264pay name=pay0 pt=96 )"
            else
                echo -e "${green}Starting capture of MJPG stream, 640x480, 10 fps...${reset}"
                ./launch --gst-debug=3 "( v4l2src device=$a ! image/jpeg,width=640,height=480,framerate=10/1 ! queue ! jpegdec ! omxh264enc target-bitrate=6000000 control-rate=variable ! video/x-h264,profile=baseline ! rtph264pay name=pay0 pt=96 )"
            fi
        fi
    fi

else
    echo "Custom pipeline found..."
    ./launch --gst-debug=3 "( $GST_RTSP_PIPELINE )"
fi
