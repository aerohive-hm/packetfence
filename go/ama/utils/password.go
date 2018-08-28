package utils

import (
	"encoding/base64"

	"golang.org/x/crypto/bcrypt"
)

const (
	bcryptDefaultCost = 8
)

func AhBase64Enc(plantext string) string {
	return base64.StdEncoding.EncodeToString([]byte(plantext))
}

func AhBcryptHash(plantext string) string {
	bcryptBytes, err := bcrypt.GenerateFromPassword([]byte(plantext),
		bcryptDefaultCost)
	if err != nil {
		panic(err)
	}

	return string(bcryptBytes)
}

func AhCheckBcryptHash() {
}
