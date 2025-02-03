---
layout:     post
title:      Woopker Mini Digital Amplifier X24 on Linux
date:       2025-02-02
summary:    Getting a cheap AliExpress amplifier to work on Linux
categories: linux
---

I recently inherited some Soviet-era speakers, so I was shopping for amplifiers I could use.

![speakers spec](/blog/images/speakers.png)

The speakers have the specs on them, and from what I could understand, they are 35W at 4 ohms. Naturally, I went on AliExpress and started looking around for an amplifier in such a range. After some looking around, only one of them seemed to fit the bill, the [Woopker Mini X24](https://www.aliexpress.com/item/1005005511246246.html). It is a 2x50W amplifier, plenty for my use case.

![woopker amplifier](/blog/images/woopker.png)

As always, you don't know what you'll get from AliExpress, especially if you are expecting it to work on Linux. The device arrived pretty fast, and the packaging was okay; it came with all the cables you'd expect.

Here is what `dmesg -w` shows when we connect the device with a USB cable to the computer:

```
[21858.948038] usb 1-3: new full-speed USB device number 8 using xhci_hcd
[21859.172771] usb 1-3: New USB device found, idVendor=8087, idProduct=1024, bcdDevice= 1.00
[21859.172777] usb 1-3: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[21859.172780] usb 1-3: Product: USB2.0 Device
[21859.172782] usb 1-3: Manufacturer: Generic
[21859.172784] usb 1-3: SerialNumber: 20170726905923
[21859.224772] usb 1-3: 2:0: bogus dB values (-12800/-12700), disabling dB reporting
```

Here is how it is represented in audio settings:

![woopker kde audio settings](/blog/images/woopkerkde.png)

Don't try the 5.1 profile unless you want a migraine ;)

The device uses this chip: [TPA3116](https://www.ti.com/product/TPA3116D2)

The amplifier has a knob for controlling the volume, but it seems to be buggy on Linux. There seems to be some sort of feedback loop when adjusting the volume from the Linux interface, as it will jump back to what the knob is set to. Also, vice versa, there is some weirdness when changing the volume with the knob.

The solution here is to disable the hardware mixer in Wireplumber so that the hardware volume knob becomes independent of the Linux volume settings.

```
[ugjka@ugjka ~]$ cat .config/wireplumber/wireplumber.conf.d/alsa-softmixer.conf 
monitor.alsa.rules = [
  {
    matches = [
      {
        device.name = "~alsa_card.*"
      }
    ]
    actions = {
      update-props = {
        api.alsa.soft-mixer = true
      }
    }
  }
]
```

This is also a problem when connecting over Bluetooth. To fix this with Bluetooth, you need to disable hardware volume (also known as absolute volume):

```
[ugjka@ugjka ~]$ cat .config/wireplumber/wireplumber.conf.d/bluetooth-no-hw.conf 
monitor.bluez.properties = {
  bluez5.enable-hw-volume = false
}
```

When connecting over Bluetooth, there are a couple of problems. I couldn't connect using KDE's Bluetooth manager; I had to use the [Blueman](https://archlinux.org/packages/extra/x86_64/blueman/) Bluetooth manager.

![blueman interface](/blog/images/woopkerbt.png)

The device will disconnect from Bluetooth when there is no audio sent. This is a problem on Linux because when there is silence, Pipewire will stop sending data, but fortunately, we can fix this with this Wireplumber config to keep sending data even if it is silence:

```
[ugjka@ugjka ~]$ cat .config/wireplumber/wireplumber.conf.d/alsa-no-idle.conf 
monitor.alsa.rules = [
  {
    matches = [
      {
        device.name = "~alsa_card.*"
      }
    ]
    actions = {
      update-props = {
        session.suspend-timeout-seconds = 0
        node.pause-on-idle = false
      }
    }
  }
]
```

I also tested the 3.5mm aux connection; it works, but it introduces noise because my computer isn't grounded (Soviet-era house with outdated wiring).

If you are getting low volume, it is also worth checking the PCM volume with the `alsamixer` command.

![woopker in action](/blog/images/woopkerinaction.jpg)

That's all. I hope this is helpful to anyone looking to buy this little gadget.