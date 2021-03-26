# capture-block-demo
Demo of new video capture block and streaming block

## Usage
ssh into the capture-block and change to the `/usr/src/app/gst-rtsp-server/examples` folder. Issue the following command to start capturing from `dev/video0`:
`./test-launch --gst-debug=3 "( rpicamsrc bitrate=8000000 awb-mode=tungsten preview=false ! video/x-h264, width=640, height=480, framerate=30/1 ! h264parse ! rtph264pay name=pay0 pt=96 )"`
A RTSP stream is now available on `rtsp://127.0.0.1:8554/test`

ssh into the streaming-block and issue the following command: 
`./webrtc-streamer rtsp://localhost:8554/test -H 0.0.0.0:80`
A webRTC stream is now available on port 80 of the device, or via the public URL.
