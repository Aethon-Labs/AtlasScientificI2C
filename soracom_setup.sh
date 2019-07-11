#!/bin/bash

# setup.sh
# Soracom Starter Kit
# Raspberry Pi Zero + Huawei MS2131i connection setup
# Version 2019-02-08

update_ifupdown()
{
cat <<EOF >> /etc/network/interfaces

auto wlan0
allow-hotplug wlan0
iface wlan0 inet dhcp
wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
EOF
}

setup_modem()
{
for n in {1..5}
do
    usb_modeswitch -v 12d1 -p 14fe -J &>> /home/pi/soracom_setup.log
    sleep 2
    if lsusb | grep 12d1:1506 > /dev/null
    then
        return 0
    fi
done
return 1
}

test_modem()
{
for n in {1..30}
do
    if mmcli -L | grep MS2131 > /dev/null
    then
        return 0
    fi
    sleep 2
done
return 1
}

setup_route()
{
cat <<EOF > /etc/NetworkManager/dispatcher.d/90.soracom_route
#!/bin/bash

if [ "\$1" == "ppp0" ] && [ "\$2" == "up" ]
then
    echo "[\$(date '+%Y-%m-%d %H:%M:%S')] Modem connected" >> /home/pi/soracom_status.log

    /sbin/route add -net 100.127.0.0/16 dev ppp0 metric 0
    logger -s "Added Soracom service route 100.127.0.0/16 for ppp0 with metric 0"
    /sbin/route add -net 54.250.252.67/32 dev ppp0 metric 0
    logger -s "Added Soracom Endorse route 54.250.252.67/32 for ppp0 with metric 0"
    /sbin/route add -net 54.250.252.99/32 dev ppp0 metric 0
    logger -s "Added Soracom Krypton route 54.250.252.99/32 for ppp0 with metric 0"
elif [ "\$1" == "ttyUSB2" ] && [ "\$2" == "down" ]
then
    echo "[\$(date '+%Y-%m-%d %H:%M:%S')] Modem disconnected" >> /home/pi/soracom_status.log

    /sbin/route del -net 100.127.0.0/16 dev ppp0 metric 0
    logger -s "Deleted Soracom service route 100.127.0.0/16"
    /sbin/route del -net 54.250.252.67/32 dev ppp0 metric 0
    logger -s "Deleted Soracom Endorse route 54.250.252.67/32"
    /sbin/route del -net 54.250.252.99/32 dev ppp0 metric 0
    logger -s "Deleted Soracom Krypton route 54.250.252.99/32"
fi
EOF

chmod +x /etc/NetworkManager/dispatcher.d/90.soracom_route

touch /home/pi/soracom_status.log
}

# Showing progress with a bash spinner
# https://github.com/marascio/bash-tips-and-tricks/tree/master/showing-progress-with-a-bash-spinner
spin()
{
    local pid=$1
    local spinner='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinner#?}
        printf " [%c]  " "$spinner"
        local spinner=$temp${spinner%"$temp"}
        sleep 0.25
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}



# Begin setup
if [ $UID != 0 ]
then
    echo "You must run this script as root. Please try again using \"sudo ./setup.sh\""
    exit 1
fi



# Configure /etc/network/interfaces to manage wlan0
echo "---"
echo "Configuring wlan0..."
if cat /etc/network/interfaces | grep "auto wlan0" > /dev/null
then
    echo "wlan0 already configured!"
else
    printf "Adding wlan0 to /etc/network/interfaces..."
    (update_ifupdown) &
    spin $!
    printf " Done!\n"
fi
echo
sleep 1



# Install NetworkManager and usb_modeswitch
echo "---"
echo "Installing required packages (this may take a few minutes)..."
if [ ! -x /usr/bin/nmcli -o ! -x /usr/sbin/usb_modeswitch ]
then
    printf "Updating package list..."
    (apt-get update &>> /home/pi/soracom_setup.log) &
    spin $!
    printf " Done!\n"
    printf "Installing network-manager..."
    (apt-get install -y network-manager &>> /home/pi/soracom_setup.log) &
    spin $!
    printf " Done!\n"
    printf "Installing usb-modeswitch..."
    (apt-get install -y usb-modeswitch &>> /home/pi/soracom_setup.log) &
    spin $!
    printf " Done!\n"
else
    echo "Required packages already installed!"
fi
if ! nmcli --version > /dev/null
then
    printf "Starting NetworkManager..."
    (service NetworkManager start || exit 1) &
    spin $!
    printf " Done!\n"
fi
if ! mmcli --version > /dev/null
then
    printf "Starting ModemManager..."
    (service ModemManager start || exit 1) &
    spin $!
    printf " Done!\n"
fi
echo
sleep 1



# Setup modem
echo "---"
echo "Setting up modem..."
printf "Please plug in your modem now: "
until lsusb | grep 12d1 > /dev/null
do
    sleep 1
done
printf "Modem detected!\n"
if lsusb | grep 12d1:1506 > /dev/null
then
    :
elif lsusb | grep 12d1:14fe > /dev/null
then
    printf "Modem detected in mass storage mode. Switching modes..."
    (setup_modem) &
    spin $!
    if [ "$?" = "1" ]
    then
        echo "Modem was not setup properly. Please unplug the modem, then plug it in and try again."
        exit 1
    else
        printf " Done!\n"
    fi
fi
printf "Waiting until the modem is ready (this may take a minute)..."
(test_modem) &
spin $!
if [ "$?" = "1" ]
then
    echo "Modem was not initialized properly. Please wait or reboot, then try again."
    exit 1
fi
printf " Done!\n"
echo
sleep 1



# Add Soracom route rule
echo "---"
echo "Adding Soracom route rule..."
if [ -f /etc/NetworkManager/dispatcher.d/90.soracom_route ]
then
    echo "Soracom route rule already exists!"
else
    setup_route
    echo "Soracom route rule created: /etc/NetworkManager/dispatcher.d/90.soracom_route"
fi
echo
sleep 1



# Add Soracom connection profile
echo "---"
echo "Adding Soracom connection profile..."
if nmcli con show soracom &> /dev/null
then
    echo "Soracom connection profile already exists!"
    status=``
    if [ "$(nmcli dev | grep soracom | awk '{print $3}')" == "disconnected" ]
    then
        printf "Bringing up connection..."
        (nmcli con up soracom &>> /home/pi/soracom_setup.log) &
        spin $!
        printf " Done!\n"
    fi
else
    nmcli con add type gsm ifname "*" con-name soracom apn soracom.io user sora password sora &>> /home/pi/soracom_setup.log
    echo "Connection profile added: soracom"
fi
echo
sleep 1



# Finish script
cat <<EOF
---
Setup complete!

In a moment, your modem status light should change to solid blue or green,
indicating that you are now successfully connected to Soracom!

Tips:
- When you reboot or plug in your modem, it will automatically connect.
- When wifi is connected, the modem will be used only for Soracom services.
- You can manually disconnect and reconnect the modem using:
    sudo nmcli con down soracom
    sudo nmcli con up soracom

EOF
