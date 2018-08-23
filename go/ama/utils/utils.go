package utils

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"os/exec"
)

func ExecShell(s string) (string, error) {
	cmd := exec.Command("/bin/bash", "-c", s)

	var out bytes.Buffer
	cmd.Stdout = &out

	err := cmd.Run()
	if err != nil {
		fmt.Println("exec error!" + s)
	}

	return out.String(), err
}

func execCommand(cmdName string, params []string) bool {
	cmd := exec.Command(cmdName, params...)

	fmt.Println(cmd.Args)
	stdout, err := cmd.StdoutPipe()

	if err != nil {
		fmt.Println(err)
		return false
	}

	cmd.Start()
	reader := bufio.NewReader(stdout)

	for {
		line, err := reader.ReadString('\n')
		if err != nil || io.EOF == err {
			break
		}
		fmt.Println(line)
	}

	cmd.Wait()
	return true
}

func GenClusterID() string {
	cmd := "uuidgen | tr '[:lower:]' '[:upper:]'"
	uuid, err := ExecShell(cmd)
	if err != nil {
		return ""
	}
	return uuid
}
