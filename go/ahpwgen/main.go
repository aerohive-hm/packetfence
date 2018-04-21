package main

import (
	"crypto/sha1"
	"fmt"
	"io"
)

const PREFIX  = "hHiMvSeHaEeLrLo"
const POSTFIX = "XeIvAiOhLoArNeBaOOA"

func main() {
	var system_id string
	fmt.Scanln(&system_id)

	h1 := sha1.New()
	h2 := sha1.New()

	io.WriteString(h1, PREFIX)
	io.WriteString(h1, system_id)

	io.WriteString(h2, fmt.Sprintf("%x", h1.Sum(nil)))
	io.WriteString(h2, POSTFIX)

	fmt.Printf("%x", h2.Sum(nil)[0:8])
}
