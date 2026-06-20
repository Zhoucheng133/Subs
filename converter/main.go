package main

import "C"
import "convert/utils"

func Convert(dir *C.char) *C.char {
	err := utils.Convert(C.GoString(dir))
	if err != nil {
		return C.CString(err.Error())
	}
	return C.CString("")
}

func main() {
	utils.Convert("/Users/zhoucheng/Downloads/临时")
}
