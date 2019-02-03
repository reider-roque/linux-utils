package main

import (
	"errors"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"strings"
)

var filePath = flag.String("filepath", "",
	"Path to the LinguaLeo dictionary file")

func main() {
	flag.Parse()
	if *filePath == "" {
		log.Fatalln("Path to the LinguaLeo dictionary file must be supplied.")
	}

	wordsBadPronounciation := []string{"moat", "gourmand", "contract",
		"debacle", "disciplinary", "by ear", "fuchsia", "per diem", "divert",
		"fuchsia", "quiesce", "touche", "urinal", "perdure", "sesquipedalian",
		"desideratum", "appaling"}

	input, err := ioutil.ReadFile(*filePath)
	if err != nil {
		log.Fatalln(err)
	}

	// Create a backup
	backupFilePath, err := getBackupFilePath(*filePath)
	if err != nil {
		log.Fatalln(err)
	}
	err = ioutil.WriteFile(backupFilePath, []byte(input), 0644)
	if err != nil {
		log.Fatalln(err)
	}

	lines := strings.Split(string(input), "\n")

	for i, line := range lines {
		lineParts := strings.Split(line, ";")
		// Lowercase the word and translation
		lineParts[0] = strings.ToLower(lineParts[0])
		lineParts[1] = strings.ToLower(lineParts[1])

		// Drop links to audio with incorrect pronounciation
		for _, word := range wordsBadPronounciation {
			// Drop quotes for comparison with slice expressions
			if lineParts[0][1:len(lineParts[0])-1] == word {
				lineParts[5] = ""
				break
			}
		}

		// Replace https:// links with http:// for audio links;
		// Anki for som reason does not handle https:// links
		if strings.HasPrefix(lineParts[5], "\"https") {
			lineParts[5] = "\"http" + lineParts[5][6:]
		}

		lines[i] = strings.Join(lineParts, ";")
	}

	output := strings.Join(lines, "\n")
	err = ioutil.WriteFile(*filePath, []byte(output), 0644)
	if err != nil {
		log.Fatalln(err)
	}
}

func getBackupFilePath(filePath string) (string, error) {
	backupFilePath := filePath + ".backup"
	if _, err := os.Stat(backupFilePath); os.IsNotExist(err) {
		return backupFilePath, nil
	}

	for i := 1; i < 100; i++ {
		backupFilePath = fmt.Sprintf("%s.backup.%d", filePath, i)
		if _, err := os.Stat(backupFilePath); os.IsNotExist(err) {
			return backupFilePath, nil
		}
	}

	return "", errors.New("Too many backups have already been generated.")
}
