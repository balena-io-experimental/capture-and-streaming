# Finds video devices that do capture
# Not used... yet.

for dev in `find /dev -iname 'video*' -printf "%f\n"`
do
  v4l2-ctl --info --device /dev/$dev | \
    grep -Pqzo '(?s)Device Caps.+Video Capture' && \
    echo $dev `cat /sys/class/video4linux/$dev/name`
done
