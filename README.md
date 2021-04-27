# capture-and-streaming
Blocks for capturing video, processing it, and streaming it over WebRTC. (Note: This is still a work in progress. Once completed it will be moved to a different Org. Do not rely on this repo while it is still in the Playground.)

## Usage
In the Device Configuration, add the custom configuration variable `BALENA_HOST_CONFIG_start_x` and set the value to `1`. You also need to increase the default "Define device GPU memory in megabytes" using the dashboard. (Or [device configuration variables](https://www.balena.io/docs/reference/OS/advanced/)) 192 MB seems to be the minimum, but your results may vary.

### Capture Block

The Capture Block takes a video source (usually a camera) as an input and converts it to an RTSP stream.

Input: The block will search for a Pi Camera and use that by default. If it does not find a Pi Camera, it will look for a USB camera and use the first one it finds. If the camera supports YUYV it will use that, otherwise it will use mjpeg. You can override this automatic selection process by specifying your own Gstreamer pipeline using the service variable `GST_RTSP_PIPELINE`. 

You can also use a custom pipeline to change the default height, width, and framerate. For instance, here is the default pipeline used when a Pi camera is detected:
`rpicamsrc bitrate=8000000 awb-mode=tungsten preview=false ! video/x-h264, width=640, height=480, framerate=30/1 ! h264parse ! rtph264pay name=pay0 pt=96`
To change the height and width when using a pi Camera, edit the values in the above pipeline and then set the `GST_RTSP_PIPELINE` to the edited pipeline.

For a standard USB webcam that uses YUYV:
`v4l2src device=/dev/video0 !  v4l2convert ! video/x-raw,width=640,height=480,framerate=15/1 ! omxh264enc target-bitrate=6000000 control-rate=variable ! video/x-h264,profile=baseline ! rtph264pay name=pay0 pt=96`

For an older webcam that only supports jpeg:
`v4l2src device=/dev/video0 ! image/jpeg,width=640,height=480,framerate=10/1 ! queue ! jpegdec ! omxh264enc target-bitrate=6000000 control-rate=variable ! video/x-h264,profile=baseline ! rtph264pay name=pay0 pt=96`

In fact, you can change almost any part of the pipeline to suit your needs, but make sure it ends with an rtp output such as `rtph264pay`. 

A RTSP stream will be available on `rtsp://localhost:8554/server` to other containers in the application. (Replace localhost with the device's IP address to view the stream outside the device)

### Streaming Block

The Streaming Block takes an RTSP stream as an input and produces a WebRTC stream as an output. The input stream is selected automatically but can be overriden. If a processing block is running on the device, it will use that block's RTSP output stream as an input. If no processing block is found, it will look for a capture block and use that as the input. If neither are found, or you want to override this behavior, you can specify an RTSP input stream with the service variable `WEBRTC_RTSP_INPUT`. By default, the output WebRTC stream will be on port 80, but you can change that by specifying the service variable `WEBRTC_PORT`.

The streaming block utilizes [webrtc-streamer](https://github.com/mpromonet/webrtc-streamer) so all of its features and API are available to use as well.

ssh into the streaming-block and issue the following command: 

`./webrtc-streamer rtsp://localhost:8554/server -H 0.0.0.0:80`

### Processing Block
The processing block allows you to transform an RTSP stream. It will automatically use the capture block as its input if it exists on the device. Otherwise, specify an RTSP input stream with the `PROC_RTSP_INPUT` service variable. The output of the processing block will be available on `rtsp://localhost:8558/proc` to other containers in the application. (Replace localhost with the device's IP address to view the stream outside the device.) This block is ideally suited for use with the capture and streaming blocks, and video will automatically be routed through this block if the other two are present.

An API is used to control the processing block. The block is written in python using OpenCV and it's relatively easy to add additional functionality. The base API supports:
```
/api/process
/api/flip
/api/mirror
/api/rotate
/api/negate
/api/monochrome
/api/text
```

