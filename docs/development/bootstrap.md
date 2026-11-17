# ClaudeWatch Developer Bootstrap

## First-Time Setup
When cloning this repository for the first time, execute the bootstrap script to verify that all necessary CLIs and dependencies are available on your system.

## Bootstrap Script Usage
From the root of the repository, run:
```powershell
.\tools\bootstrap\bootstrap.ps1
```
This script audits your global `PATH` for Flutter, Dart, Git, Java, Android SDK tools, GitHub CLI, and AI agents.

## Health Check Usage
Run this script to perform a full system validation, analysis, testing, and APK build sequence:
```powershell
.\tools\bootstrap\health_check.ps1
```

## Expected Outputs
The Bootstrap script should return `[PASS]` for all components and output `Bootstrap Complete: READY`.
The Health Check script should return `Health Check: ALL SYSTEMS GO` after analyzing the code and compiling the debug APK.

## Troubleshooting
- If `adb` or `sdkmanager` fail, ensure the Android SDK `platform-tools` and `cmdline-tools/latest/bin` are added to your global `PATH`.
- If the Health Check fails on `flutter analyze`, resolve any warnings or lints.
- If MCP directories report warnings, refer to your Antigravity IDE configuration to install the required MCP servers.
