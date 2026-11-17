# Android CLI Development Guide

## Connecting a Phone (USB & Wireless)
- **USB**: Run `.\tools\android\usb_debug.ps1` to restart the ADB server and list devices.
- **Wireless Debugging**: Run `.\tools\android\wireless_debug.ps1 -ip <IP> -port <PORT>`.

## Flutter Hot Reload & Restart
- **Hot Reload**: While running `flutter run`, press `r` in the terminal.
- **Hot Restart**: While running `flutter run`, press `R` in the terminal.

## Logs
- **Logcat**: Run `.\tools\android\logcat.ps1` or use `flutter logs`.

## Application Management
- **APK Install**: Run `.\tools\android\apk_install.ps1 -apkPath <path_to_apk>`
- **APK Uninstall**: Run `.\tools\android\apk_remove.ps1 -package com.claudewatch.claudewatch`

## Troubleshooting
- If device is unauthorized, check the phone for a prompt.
- If ADB hangs, run `adb kill-server` followed by `adb start-server`.
- For emulator issues, run a cold boot using `.\tools\emulator\cold_boot.ps1 -avdName <NAME>`.
