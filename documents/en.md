# Subs

## Introduction

<img src="../assets/icon.png" width=100></img>

![License](https://img.shields.io/badge/License-MIT-dark_green)

This is a batch subtitle processing tool that helps you burn subtitles into multiple videos at once. For more details, see [Usage](#usage).

## Screenshots

<img src="../screenshots/en/1.png" width=500></img>  
<img src="../screenshots/en/2.png" width=500></img>

## Usage

1. Place the videos and subtitles into two separate folders, or keep them together in the same folder.
2. The number of subtitle files must match the number of video files to run (you can delete items or adjust their order after they are added).
3. Open the software, select the video and subtitle folders, or drag and drop them into the corresponding areas.
4. If you need to specify custom output configurations (such as resolution and codec), you can click the `Codec` configurations. By default, the output video codec is H264, the audio codec is AAC, and the resolution remains the same as the original.
5. Select the output directory at the bottom of the window.
6. Click Run to start.

## Build on Your Device
This project consists of three parts:
- FFmpeg binaries
- A dynamic library for subtitle encoding conversion, developed in Go
- The main application, developed in Flutter

### FFmpeg
You need to download the corresponding FFmpeg binary for your system, e.g. `FFmpeg.exe` into the `windows` folder, and `ffmpeg` into the `macos` folder.
Note your system architecture — the `macos` folder already includes a version of FFmpeg built for Apple Silicon (macOS ARM). You can replace it if needed.

### Dynamic Library

You need to have Go installed on your device and build the `libconverter` dynamic library.
Run the following command inside the `converter` directory to build the library:

```bash
# For Windows
go build -buildmode=c-shared -ldflags="-s -w" -o build/libconverter.dll
# For macOS
go build -buildmode=c-shared -ldflags="-s -w" -o build/libconverter.dylib
```

The dynamic library will be built in the `converter/build` directory.
You need to copy `libconverter.dll` or `libconverter.dylib` into the `windows` or `macos` folder respectively.

For Windows:
```
libconverter.dll -> windows/libconverter.dll
```

For macOS:
```
libconverter.dylib -> macos/libconverter.dylib
```

Pre-built dynamic library files are already included in the respective directories (the macOS version is built for Apple Silicon ARM). You may choose to use the pre-built libraries or replace them with your own.

### Main Application
You need to have Flutter installed on your device. This project was developed with Flutter 3.41; newer versions should also work.
Use the following commands to build the complete app:

```bash
# For Windows
flutter build windows
# For macOS
flutter build macOS
```

The build output can be found in `build/windows/build/Products/Release` or `build/macos/build/Products/Release`.