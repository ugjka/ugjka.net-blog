---
layout:     post
title:      Whisper on Flatpak Kdenlive
date:       2025-03-07
summary:    Getting Whisper speech to text to work on Kdenlive Flatpak
categories: linux
---

To ensure Whisper works with Kdenlive installed via Flatpak, follow these steps:

1. **Install Python and Pip**: Ensure Python and Pip are available in the Flatpak environment. You can use the `ensurepip` subcommand to set up Pip if it's not already installed.

   ```
   flatpak run --command=/bin/sh org.kde.kdenlive
   python -m ensurepip
   ```

2. **Install Whisper and Torch**: Use Pip to install the necessary packages, `openai-whisper` and `torch`.

   ```
   python -m pip install -U openai-whisper torch
   ```

3. **Run Whisper**: Download the turbo model by running Whisper with dummy load.

   ```
   /var/data/python/bin/whisper --model turbo /dev/null
   ```

4. **Exit the Shell**: Exit the Flatpak shell.

   ```
   exit
   ```

5. **Configure Environment Variables**: Use Flatseal to modify the environment variables for Kdenlive. Add the custom Python path to the `PATH` variable.

   ```
   PATH=/app/bin:/usr/bin:/var/data/python/bin
   ```

These steps should integrate Whisper with Kdenlive in a Flatpak environment.
