#!/bin/bash

# Drive level into rig. Adjust if neccessary to get the ALC meter on your rig at around 30%.
OUTPUT_VOL={{ hamlib_output_volume }}

echo 'Initiating Ardop TNC...';
echo 'pcm.ARDOP {type rate slave {pcm "hw:CARD=CODEC,DEV=0" rate 48000}}' >> /home/pi/.asoundrc
AUDIOCARD=$(aplay -l |grep -i 'USB Audio CODEC' |grep -o 'card [0-9]*')
if [ "$(echo ${AUDIOCARD} |wc -l)" -lt "1" ]; then
  echo 'Problem detecting USB audio card. Is the device plugged in?';
  echo 'Exiting.';
  exit 1
fi

CARDNUM=$(echo ${AUDIOCARD} |cut -d' ' -f2)
echo 'Setting appropriate output volume level. If you find this is not driving your rig at the';
echo 'right level (should be about 30% on your rigs ALC meter) use alsamixer to adjust accordingly.';
echo 'You can also edit the OUTPUT_VOL variable at the top of this script for future runs.';
amixer -c ${CARDNUM} set PCM ${OUTPUT_VOL} > /dev/null
