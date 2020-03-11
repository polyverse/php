// Copyright (c) 2020 Polyverse Corporation

package main

//TODO: CLEAN UP, REFACTOR

import (
	"bufio"
	"bytes"
	"fmt"
	"log"
	"os"
	"strings"
)

var yakFile string
var lexFile string

const y_check = "zend_language_parser.y"
const l_check = "zend_language_scanner.l"
const zend_dir = "/Zend/"
const source_env_var = "PHP_SRC_PATH"


func init() {
	checkEnvs()
	InitChar()
	KeywordsRegex.Longest()
}

func main() {
	scanLines(lexFile, []byte("<ST_IN_SCRIPTING>"))
	fmt.Println("Mapping Built. \nLex Scrambled.")
	Buffer.Reset()
	scanLines(yakFile, []byte("%token T_"))
	fmt.Println("Yak Scrambled.")
	SerializeMap()
	fmt.Println("Map Serialized.")
}

func scanLines(fileIn string, flag []byte) {
	file, err := os.Open(fileIn)
	Check(err)

	fileScanner := bufio.NewScanner(file)

	for fileScanner.Scan() {
		line := fileScanner.Bytes()

		if bytes.HasPrefix(line, flag) && KeywordsRegex.Match(line) {
			getWords(&line)
		} else if bytes.HasPrefix(line, flag) && CharStrRegex.Match(line){
			getCharStr(&line)
		}
		if CharRegex.Match(line) {
			getChar(&line)
		}
		WriteLineToBuff(line)
	}

	WriteFile(fileIn)
	err = file.Close()
	Check(err)
}

func getWords(s *[]byte) {
	line := string(*s)
	matchedRegex := KeywordsRegex.FindString(line)

	for matchedRegex != "" {
		index := KeywordsRegex.FindStringIndex(line)
		suffix := string(line[index[1] - 1])
		prefix := string(line[index[0]])

		matchedRegex = strings.TrimSuffix(strings.TrimPrefix(matchedRegex, prefix), suffix)
		key := strings.TrimPrefix(matchedRegex, "\"")

		if _, ok := GetScrambled(key); !ok {
			AddToPolyWords(strings.ToLower(key))
			key, _ = GetScrambled(strings.ToLower(key))
		} else {
			key, _ = GetScrambled(key)
		}

		line = strings.Replace(line, strings.TrimPrefix(matchedRegex, "\""), key, 1)
		matchedRegex = KeywordsRegex.FindString(line)
	}
	*s = []byte(line)
}

func getChar(line *[]byte) {
	*line = CharRegex.ReplaceAllFunc(*line, replaceFunction)
}

func getCharStr(line *[]byte) {
	*line = CharStrRegex.ReplaceAllFunc(*line, replaceFunction)
}

func replaceFunction(src []byte) []byte {
	var replace string
	for i := 0;  i < len(src); i++ {
		char, _ := GetScrambled(string(src[i]))
		replace += char
	}
	return []byte(replace)
}

func checkEnvs() {
	var phpSrc = os.Getenv(source_env_var)

	if phpSrc == "" {
		l := log.New(os.Stderr, "", 0)
		l.Println("No PHP Source Path Found. Continuing in current directory.")
		yakFile = y_check
		lexFile = l_check
		return
	}
	yakFile = phpSrc + zend_dir + y_check
	lexFile = phpSrc + zend_dir + l_check
}
