# Plantcam

A simple Raspberry Pi image timelapse setup.

## Materials

* Raspberry Pi
* Raspberry Pi Camera Module
* USB Storage (formatted as FAT32)

## Prepare the USB storage

Copy the files from this repository onto the USB storage, in a folder called `plantcam`.

## Initial config

If you haven't already configured your Raspberry Pi, run the configuration utility.

```
sudo raspi-config
```

1. Expand the filesystem
2. Change the root password
3. Internationalisation  
  * Change Locale: en_US-UTF-8 UTF-8 (and select it on the second screen)
  * Change Time Zone
  * Change Keyboard Layout to US
4. Enable the camera module
5. Finish (and don't reboot yet)

## Setup USB storage

Plug in the USB storage, and mount it to `/mnt/usb`.

```
sudo mkdir /mnt/usb
sudo mount -o uid=pi,gid=pi /dev/sda1 /mnt/usb
```

Edit the `/etc/fstab` to mount USB storage at boot.

```
sudo nano /etc/fstab
```

Add the following line at the bottom.

```
/dev/sda1		/mnt/usb		vfat		defaults,uid=pi,gid=pi		0		0
```

## Set the hostname

The value of `/etc/hostname` is used to keep source images from multiple RPi setups separate.

```
sudo nano /etc/hostname
```

Replace `raspberrypi` with something descriptive. Use all lowercase, with hyphens substituted for spaces.

For example, at Central Park:

```
central-park
```

Edit `/etc/hosts` to use your new hostname.

```
sudo nano /etc/hosts
```

Replace the line that refers to `raspberrypi` with your new hostname.

```
127.0.1.1		central-park
```

## Setup the cron job

```
crontab -e
```

Add the following line at the bottom to capture an image once per minute.

```
* * * * * /mnt/usb/plantcam/capture.sh >> /dev/null 2>&1
```

## Configure capture.sh

Adjust the settings at the top of `capture.sh`.

```
nano /mnt/usb/plantcam/capture.sh
```

Here are the default values.

```
width="1920"
height="1440"
quality="70"
min_time="80000"    # start at 8am
max_time="230000"   # end at 11pm
```
