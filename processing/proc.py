import cv2

#cap = cv2.VideoCapture('rtsp://192.168.1.237:8554/server')
cap = cv2.VideoCapture(0)
if not cap.isOpened():
    print("Not opened!")

sizeStr = str(int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))) + 'x' + str(int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT)))
fps = int(cap.get(cv2.CAP_PROP_FPS))

print("Video input size:{0}, fps:{1}".format(sizeStr, fps))

while True:
    ret, frame = cap.read()
    if ret == True:
        #cv2.imshow('video output', img)
        #k = cv2.waitKey(10)& 0xff
        #if k == 27:
        #    break

        # Our processing on the frame come here
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        
        #stream it back out...
        
    else:
        print("No return")
        break
cap.release()
#cv2.destroyAllWindows()
