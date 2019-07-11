SutroBOT
==================================

## Info
```
$ git clone https://github.com/Aethon-Labs/AtlasScientificI2C.git

```

### Settings Raspberry Pi

```
$ sudo raspi-config
```
Interfacing Option > P5 I2C | Enable

### Install required packages on the Raspberry Pi

```
$ sudo apt-get update
```

```
$ sudo apt-get upgrade
```

```
$ sudo apt-get install python-smbus i2c-tools
```

### Prepare the hardware
- Make sure your Raspberry Pi is powered off

- The EZO ORP Circuit support two protocols, UART and I2C. By default the selected protocol is UART. The I2C Toggler is a easy way to change this protocol. It can also be done with jumpers, but be carefull, you can break the chip. To change the protocol use the official manual from the I2C toggler.(https://www.whiteboxes.ch/docs/i2c-toggler/#/)

- Mount the supplied pcb standoffs to the Tentacle T3 for stability
- Plug your EZO circuits into the Tentacle T3
- Double-check the correct circuit orientation
- Power up the Raspberry Pi. Make sure all the EZ0 circuits are showing blue color. This indicates they are in I2C mode.
- Test I2C
In the terminal, type
```
sudo i2cdetect -y 1
```

Default I2C Addresses:

EZO DO: 97 (0x61)
EZO ORP: 98 (0x62)
EZO pH: 99 (0x63)
EZO EC: 100 (0x64)
EZO RTD: 102 (0x66)
EZO PMP: 103 (0x67)

### Setup Soracom Connectivity:
```
sudo ./soracom_setup.sh
```

### Execute script on Raspberry Pi

```
$ cd AtlacScientificI2C/src
```

```
$ python3 main.py
```

### Setup Crontab for repeated measurements:
```
* * * * * python3 /home/pi/Desktop/AtlasScientificI2C/main.py >> /home/pi/Desktop/AtlasScientificI2C/log.txt 
```
# TODO
- Hook up UI to main.py
- Update readme for setting up 3.5 inch LCD
