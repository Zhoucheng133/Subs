package utils

import (
	"bytes"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"

	"golang.org/x/net/html/charset"
)

func Convert(dirPath string) error {

	backupDir := filepath.Join(dirPath, "backup")
	entries, err := os.ReadDir(dirPath)
	if err != nil {
		return err
	}

	var bomPrefix = []byte{0xEF, 0xBB, 0xBF}

	for _, entry := range entries {
		if entry.IsDir() {
			continue
		}

		ext := strings.ToLower(filepath.Ext(entry.Name()))
		if ext != ".ass" && ext != ".srt" {
			continue
		}
		filePath := filepath.Join(dirPath, entry.Name())
		content, err := os.ReadFile(filePath)
		if err != nil {
			return err
		}
		enc, encName, _ := charset.DetermineEncoding(content, "text/plain")
		if strings.ToLower(encName) == "utf-8" {
			isBOM := bytes.HasPrefix(content, bomPrefix)
			if !isBOM {
				continue
			}
		}
		if err := os.MkdirAll(backupDir, 0755); err != nil {
			return err
		}
		reader := enc.NewDecoder().Reader(bytes.NewReader(content))
		utf8Content, err := io.ReadAll(reader)
		if err != nil {
			fmt.Printf("Decode file [%s] error: %v\n", entry.Name(), err)
			continue
		}
		backupPath := filepath.Join(backupDir, entry.Name())
		_ = os.Remove(backupPath)
		err = os.Rename(filePath, backupPath)
		if err != nil {
			return err
		}
		err = os.WriteFile(filePath, utf8Content, 0644)
		if err != nil {
			_ = os.Rename(backupPath, filePath)
			return err
		}
	}

	return nil
}
