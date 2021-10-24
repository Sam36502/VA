package main

import (
	"context"
	"fmt"

	"github.com/DaikiYamakawa/deepl-go"
)

type Lang string

const (
	English = Lang("EN")
	German  = Lang("DE")
)

func Translate(text string, langA, langB Lang) string {
	cli, err := deepl.New("https://api-free.deepl.com", nil)
	if err != nil {
		fmt.Println(" [ERR] Failed to create client:\n", err)
		return ""
	}

	tResp, err := cli.TranslateSentence(context.Background(), text, string(langA), string(langB))
	if err != nil {
		fmt.Println(" [ERR] Failed to translate:\n", err)
		return ""
	}

	return tResp.Translations[0].Text
}
