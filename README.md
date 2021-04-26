# capture-and-streaming
Example of using gstreamer to take a camera output and stream with RTSP, then convert that into WebRTC.

## Usage
In the Device Configuration, add the custom configuration variable `BALENA_HOST_CONFIG_start_x` and set the value to `1`. You also need to increase the default "Define device GPU memory in megabytes" using the dashboard. 192 MB seems to be the minimum, but your results may vary.

Input: The block will search for a Pi Camera and use that by default. If it does not find a Pi Camera, it will look for a USB camera and use the first one it finds. If the camera supports YUYV it will use that, otherwise it will use mjpeg. You can override this automatic selection process by specifying your own Gstreamer pipeline using the device variable `GST-RTSP-PIPELINE`.  - WIP, more details to follow.

Upon startup of the capture container, it will run the entry.sh script which executes the launch program in the /usr/src/app/gst-rtsp-server/examples folder.

A RTSP stream is now available on `rtsp://127.0.0.1:8554/server` (replace 127.0.0.1 with the device's IP address to view the stream outside the device)


ssh into the streaming-block and issue the following command: 

`./webrtc-streamer rtsp://localhost:8554/server -H 0.0.0.0:80`

A webRTC stream is now available on port 80 of the device, or via the public URL.
