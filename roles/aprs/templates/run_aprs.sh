#!/bin/bash

# Starts up rigctld, then direwolf
# Make sure before running that you don't have anything else running (e.g. js8call) that is using your tranceiver.

# Drive level into rig. Adjust if neccessary to get the ALC meter on your rig at around 30%.
{% if use_micinput %}
OUTPUT_VOL='25%'
{% else %}
OUTPUT_VOL='59%'
{% endif %}

{% if use_rigctl %}
RIG='{{ hamlib_rigid }}' # IC-7300 (& IC-705, but change the CI-V address in your 705 to 94.
{% if hamilb_civ is defined %}
CIV='{{ civ }}'
{% endif %}
# run `rigctl -l` to find a list of other radio models and swap the 373 here with that number.
# Note that this script was writtin for and currently only supports the IC-705.
# You'll need to additionally update your Ardop config and also your ~/.wl2k/config.json file to use a different rig.

BAUD={{ hamlib_baud }}

echo 'Initiating connection with rig...';
sudo rigctl -m ${RIG} {% if hamlib_civ is defined %}-c $CIV{% endif %} -r {{ hamlib_device }} -s ${BAUD} f >/dev/null 2>&1
if [ "$?" -ne "0" ]; then
  echo 'Could not initiate connection with rig on {{ hamlib_device }}. Is it plugged in, with the correct CI-V address set?';
  read -p 'Hit Enter or close this terminal window.' k; #TODO: Only show these prompts when launched from desktop
  echo 'Exiting.';
  exit;
fi
sudo rigctld -m ${RIG} {% if hamlib_civ is defined %}-c $CIV{% endif %} -r {{ hamlib_device }} -s ${BAUD} > /tmp/rigctl.log &
sleep 2;
{% endif %} # use_rigctl

echo 'Initiating direwolf TNC...';
AUDIOCARD=$(aplay -l |grep -i 'USB Audio CODEC' |grep -o 'card [0-9]*')
if [ "$(echo ${AUDIOCARD} |wc -l)" -lt "1" ]; then
  echo 'Problem detecting USB audio card. Is the device plugged in?';
  read -p 'Hit Enter or close this terminal window.' k; #TODO: Only show these prompts when launched from desktop
  echo 'Exiting.';
  exit
fi
CARDNUM=$(echo ${AUDIOCARD} |cut -d' ' -f2)
echo 'Setting appropriate output volume level. If you find this is not driving your rig at the';
echo 'right level (should be about 30% on your rigs ALC meter) use alsamixer to adjust accordingly.';
echo 'You can also edit the OUTPUT_VOL variable at the top of this script for future runs.';
amixer -c ${CARDNUM} set PCM ${OUTPUT_VOL} > /dev/null

echo;

direwolf -p -c /etc/direwolf/direwolf.conf &

echo;
echo "Direwolf has launched.";
echo 'When finished, hit Enter or close this terminal window.';
read k;

echo 'Cleaning up...';
sudo killall direwolf;
{% if use_rigctl %}
sudo killall rigctld;
sudo rigctl -m ${RIG} {% if hamlib_civ is defined %}-c $CIV{% endif %} -r {{ hamlib_device }} -s ${BAUD} T 0 #ensure we stop TX if it got stuck
{% endif %} # use_rigctl
