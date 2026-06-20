# Converter

这是Subs的一部分模块，用于将字幕自动转换成UTF-8编码，使用go开发  
This is a module in Subs that automatically converts subtitles to UTF-8 encoding. It's developed with Go

使用下面的命令生成动态库  
Use the follwing command to generate dynamic library

```bash
# For macOS
go build -buildmode=c-shared -ldflags="-s -w" -o build/core.dylib

# For Windows
go build -buildmode=c-shared -ldflags="-s -w" -o build/core.dll
```