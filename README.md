# capture-and-streaming
Example of using gstreamer to take a camera output and stream with RTSP, then convert that into WebRTC.

## Usage
In the Device Configuration, add the custom configuration variable `BALENA_HOST_CONFIG_start_x` and set the value to `1`. You also need to increase the default "Define device GPU memory in megabytes" using the dashboard. 192 MB seems to be the minimum, but your results may vary.

SSH into the capture-block and change to the `/usr/src/app/gst-rtsp-server/examples` folder. Issue the following command to start capturing from `dev/video0`:

`./launch --gst-debug=3 "( rpicamsrc bitrate=8000000 awb-mode=tungsten preview=false ! video/x-h264, width=640, height=480, framerate=30/1 ! h264parse ! rtph264pay name=pay0 pt=96 )"`

A RTSP stream is now available on `rtsp://127.0.0.1:8554/server`


ssh into the streaming-block and issue the following command: 

`./webrtc-streamer rtsp://localhost:8554/server -H 0.0.0.0:80`

A webRTC stream is now available on port 80 of the device, or via the public URL.
