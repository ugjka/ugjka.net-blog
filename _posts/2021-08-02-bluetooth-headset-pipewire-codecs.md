---
layout:     post
title:      Bluetooth audio pains
date:       2021-07-26
summary:    Ditch pulseaudio and get better, more reliable audio on your bluetooth headset with pipewire
categories: bluetooth
---

## Gripe

Getting my Bluetooth headset to work on Linux reliably has always been a problematic adventure. There's always some kernel issue, power management issue, Bluez issue and then getting Pulseaudio to deliver the audio or capture the mic. And then I wanted AAC instead of the standard SBC codec for audio

## Kernel

It seems that the kernel issues are finally fixed for now, at least until someone again decide to meddle with the firmware handling [code](https://bugzilla.kernel.org/show_bug.cgi?id=210681). 

Power management... Need to disable that for my Bluetooth adapter with the `btusb.enable_autosuspend=n` kernel parameter. Otherwise my headset hiccups from time to time. And that also makes my Bluetooth mouse to wake up faster from sleep, which is nice.

## Bluez

What about Bluez? A couple config changes from the defaults, that *seem* to improve things. But I don't know for sure. 

Certainly, disabling the LE mode fixed things for [this](https://github.com/bluez/bluez/issues/157#issuecomment-865117100) guy during the previous Bluez apocalypse. I don't need the LE mode for now, so I'll stick with it. I don't even know if my bt adapter supports dual bredr/le configurations. It is a laptop from 2010, so probably not.

Another knob is `MultiProfile` setting, which I set to `multiple`. Apparently it helps with devices who have more than one operational mode. I guess, headsets fit the bill because they have HQ audio mode and the poorer quality, well, headset mode with mic.

So the config looks like this
```
/etc/bluetooth/main.conf
ControllerMode = bredr
MultiProfile = multiple
Experimental = true
```

The `Experimental` flag is just for fun, if something breaks again I'll probably disable it.

## Pulseaudio and codecs

Pulseaudio offers the standart SBC codec for A2DP profile and CVSD the default codec used with HSP a.k.a headset profile. You can live with SBC but the CVSD is *interesting* (brings back dial up memories).

Better codec support is in the [works](https://gitlab.freedesktop.org/pulseaudio/pulseaudio/-/merge_requests/440)  , supposedly

So, I set [it](https://wiki.archlinux.org/title/Bluetooth_headset#Headset_via_Bluez5/PulseAudio) up and it works most of the time. But because I use KDE's Bluedevil for managing my bt devices there are interesting bugs. Like my headset always dropping to the HSP mode upon reconnect. To fix that you, apparently, needs some hacky [scripts](https://github.com/pastleo/fix-bt-a2dp#usage). Or you need to uninstall any fancy Bluetooth managers and use the Bluez's vanilla `bluetoothctl` control centre for all your Bluetooth needs. That's more like Arch *way*, hehe. But even that turned out buggy sometimes and I eventually figured I need to get rid of Pulseaudio.

## Meet Pipewire

So I read the Arch wiki [again](https://wiki.archlinux.org/title/bluetooth_headset#Headset_via_Pipewire) and find this:

> [PipeWire](https://wiki.archlinux.org/title/PipeWire "PipeWire")  acts as a drop-in replacement for  [PulseAudio](https://wiki.archlinux.org/title/PulseAudio "PulseAudio")  and offers an easy way to set up Bluetooth headsets. It includes out-of-the-box support for A2DP sink profiles using SBC/SBC-XQ, AptX, LDAC or AAC codecs, and HFP/HSP.

>[Install](https://wiki.archlinux.org/title/Install "Install")  [pipewire-pulse](https://archlinux.org/packages/?name=pipewire-pulse)  (which replaces  [pulseaudio](https://archlinux.org/packages/?name=pulseaudio)  and  [pulseaudio-bluetooth](https://archlinux.org/packages/?name=pulseaudio-bluetooth)).

I swear this was some new edit but maybe it was a long time ago read it, but OK I went ahead and installed `pipewire-pulse`. 

I turn on my Headset and it connects. Whoo! I open up YouTube and start playing [1999](https://www.youtube.com/watch?v=6-v1b9waHWY) and I get beautiful audio. Nice! Then I check audio settings and Pipewire is using AAC! I didn't configure anything, it just did what I wanted out of the box! 

Changing to headset mode and testing the mic worked too. I don't talk much over the internet anyway but, at least, it is there when I need it.

So, yeah, no config, just works...

PS. If your headset supports it, there is a config for the experimental mSBC codec that you can [enable](https://www.redpill-linpro.com/techblog/2021/05/31/better-bluetooth-headset-audio-with-msbc.html) for better mic audio

