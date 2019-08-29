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

var badPronunciationWords = []string{
	"moat", "gourmand", "contract", "debacle", "disciplinary", "by ear",
	"fuchsia", "per diem", "divert", "fuchsia", "quiesce", "touche", "urinal",
	"perdure", "sesquipedalian", "desideratum", "appaling", "feng shui",
	"labyrinthian", "have at it", "compendium",
}

var properTranscriptionMap = map[string]string{
	"turquoise":    "ˈtɜrˌkɔɪz",
	"sisyphus":     "ˈsɪsəfəs",
	"nourish":      "'nɜrɪʃ",
	"gourmand":     "ˌɡɔrˈmɑnd",
	"commensurate": "kəˈmensrət",
	"debacle":      "dɪːbˈʌkl",
}

func main() {
	flag.Usage = func() {
		fmt.Printf("Usage: %s LLFILE\n", os.Args[0])
		flag.PrintDefaults()
	}

	flag.Parse()
	if flag.NArg() == 0 {
		log.Fatalln("Path to the LinguaLeo dictionary file must be supplied.")
	}

	filePath := &flag.Args()[0]
	if *filePath == "" {
		log.Fatalln("Path to the LinguaLeo dictionary file must be supplied.")
	}

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

		// Drop audio links for words with incorrect pronounciation
		for _, word := range badPronunciationWords {
			// Drop quotes for comparison with slice expressions
			if lineParts[0][1:len(lineParts[0])-1] == word {
				lineParts[5] = ""
				break
			}
		}

		// Replace incorrect transcriptions for some words
		for word, transcription := range properTranscriptionMap {
			// Drop quotes for comparison with slice expressions
			if lineParts[0][1:len(lineParts[0])-1] == word {
				lineParts[3] = transcription
				break
			}
		}

		// Drop <img src=''> enclosure from the image link
		if strings.HasPrefix(lineParts[2], "\"<img src='") {
			lineParts[2] = "\"" + lineParts[2][11:]
		}
		if strings.HasSuffix(lineParts[2], "'>\"") {
			lineParts[2] = lineParts[2][:len(lineParts[2])-3] + "\""
		}

		// Fix http:https:// links in image link field
		if strings.HasPrefix(lineParts[2], "\"http:http") {
			lineParts[2] = "\"" + lineParts[2][6:]
		}

		// Drop [sound:] enclosure from the audio link
		if strings.HasPrefix(lineParts[5], "\"[sound:") {
			lineParts[5] = "\"" + lineParts[5][8:]
		}
		if strings.HasSuffix(lineParts[5], "]\"") {
			lineParts[5] = lineParts[5][:len(lineParts[5])-2] + "\""
		}

		// Replace https:// links with http:// for audio links;
		// Anki for som reason does not handle https:// links
		if strings.HasPrefix(lineParts[5], "\"https") {
			lineParts[5] = "\"http" + lineParts[5][6:]
		}

		// Replace Russian ё with е
		lineParts[1] = strings.Replace(lineParts[1], "ё", "е", -1)

		// Drop the tag
		lineParts[6] = ""

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
