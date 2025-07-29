---
layout:     post
title:      Whisper on Flatpak Kdenlive
date:       2025-03-07
summary:    Getting Whisper speech to text to work on Kdenlive Flatpak
categories: linux
---

See: [https://bugs.kde.org/show_bug.cgi?id=499012]()

TLDR;

```
mkdir -p ~/.var/app/org.kde.kdenlive/cache/whisper
```

Then the whisper model download will work