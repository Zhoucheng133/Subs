# Subs

Also available in English. Click [HERE](/documents/en.md) to view the English version of the README

## 简介

<img src="assets/icon.png" width=100></img>

![License](https://img.shields.io/badge/License-MIT-dark_green)

这是一个批量处理字幕的工具，帮助你批量压制多个视频+字幕，详细见[使用方法](#使用方法)

## 截图

<img src="screenshots/cn/1.png" width=500></img>  
<img src="screenshots/cn/2.png" width=500></img>

## 使用方法

1. 将视频和字幕分别放在两个文件夹，放在一起也行
2. 需要字幕文件数量和视频文件数量相同后才能运行（你可以在添加完成之后自行删除/调整顺序）
3. 打开本软件，选择视频文件夹和字幕文件夹或者拖入对应区域
4. 如果你需要指定输出视频配置（比如分辨率和编码）可以点击`编码`配置，默认情况下输出视频编码为H264，音频编码为acc，分辨率和原始相同
5. 在窗口底部选择输出目录
6. 点击运行即可

## 在你的设备上构建

本项目由三部分组成：
- FFmpeg二进制文件
- Go开发的字幕编码转换的动态库文件
- Flutter开发的主程序

### FFmpeg

你需要下载对应的FFmpeg二进制文件到对应的系统，比如`FFmpeg.exe`到`windows`文件夹，`ffmpeg`到`macos`文件夹  
注意你的系统架构，`macos`文件夹中已有针对Apple Silicon的macOS ARM架构版本FFmpeg，你可以替换它

### 动态库

你需要在你的设备上安装go，并且构建libconverter动态库

在`converter`目录内执行命令来构建动态库:

```bash
# 对于Windows系统
go build -buildmode=c-shared -ldflags="-s -w" -o build/libconverter.dll

# 对于macOS系统
go build -buildmode=c-shared -ldflags="-s -w" -o build/libconverter.dylib
```

动态库文件构建在`converter/build`目录中  
你需要将`libconverter.dll`或者`libconverter.dylib`复制到`windows`或者`macos`文件夹中

对于Windows系统
```
libconverter.dll -> windows/libconverter.dll
```
对于macOS系统
```
libconverter.dylib -> macos/libconverter.dylib
```

对应目录下已有我构建好的动态库文件（macos下是Apple Silicon的ARM架构版本），你可以选择使用我构建的动态库文件或替换它

### 主程序

你需要在你的设备上安装Flutter，本项目使用Flutter 3.41开发，你也可以使用更新的版本

使用下面的命令构建完整的App

```bash
# 对于Windows系统
flutter build windows

# 对于macOS系统
flutter build macOS
```

构建在`build/windows/build/Products/Release`或`build/macos/build/Products/Release`中