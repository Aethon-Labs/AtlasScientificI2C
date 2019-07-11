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

## Execute script on Raspberry Pi

```
$ cd AtlacScientificI2C/src
```

```
$ python3 main.py
```
# Setup Soracom Connectivity:
```
sudo ./soracom_setup.sh
```

# Setup Crontab for repeated measurements:
```
* * * * * python3 /home/pi/Desktop/AtlasScientificI2C/main.py >> /home/pi/Desktop/AtlasScientificI2C/log.txt 
```
