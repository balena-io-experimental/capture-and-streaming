# capture-and-streaming
Example of using gstreamer to take a camera output and stream with RTSP, then convert that into WebRTC.

## Usage
In the Device Configuration, add the custom configuration variable `BALENA_HOST_CONFIG_start_x` and set the value to `1`. You also need to increase the default "Define device GPU memory in megabytes" using the dashboard. 192 MB seems to be the minimum, but your results may vary.

### Capture Block

The Capture Block takes a video source (usually a camera) as an input and converts it to an RTSP stream.

Input: The block will search for a Pi Camera and use that by default. If it does not find a Pi Camera, it will look for a USB camera and use the first one it finds. If the camera supports YUYV it will use that, otherwise it will use mjpeg. You can override this automatic selection process by specifying your own Gstreamer pipeline using the device variable `GST_RTSP_PIPELINE`. 

A RTSP stream will be available on `rtsp://localhost:8554/server` to other containers in the application. (Replace localhost with the device's IP address to view the stream outside the device)

### Streaming Block

The Streaming Block takes an RTSP stream as an input and produces a WebRTC stream as an output. It will automatically use the Capture Block's RTSP stream as an input if it detects the Capture Block running on the same device. If you are not running the capture block, or you want to override the automatic use of the capture block input, you can specify an RTSP stream with the service variable ...

It uses [webrtc-streamer](https://github.com/mpromonet/webrtc-streamer) under the hood.

ssh into the streaming-block and issue the following command: 

`./webrtc-streamer rtsp://localhost:8554/server -H 0.0.0.0:80`

A webRTC stream is now available on port 80 of the device, or via the public URL.
