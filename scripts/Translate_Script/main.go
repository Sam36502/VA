package main

import (
	"fmt"
	"os"
)

func main() {

	// Set API key (Make sure to remove this before pushing to GitHub, if you do)
	// Oops, lol
	os.Setenv("DEEPL_API_KEY", "1bd10964-e2c1-a911-7373-d8084324b9d7:fx")

	str := "up"
	fmt.Printf("Translation:\n  %v ---> %v\n\n", str, Translate(str, English, German))

}
