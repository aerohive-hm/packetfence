package utils

import (
	"bufio"
	"bytes"
	"context"
	"fmt"
	"io"
	"os"
	"os/exec"

	"github.com/inverse-inc/packetfence/go/log"
)

const (
	A3Root        = "/usr/local/pf"
	A3Release     = A3Root + "/conf/pf-release"
	A3CurrentlyAt = A3Root + "/conf/currently-at"
)

type Clis struct {
	cmd    string
	ignore bool
	err    error
	out    string
}

var ctx = context.Background()

func ExecShell(s string) (string, error) {
	cmd := exec.Command("/bin/bash", "-c", s)

	var out bytes.Buffer
	cmd.Stdout = &out

	err := cmd.Run()
	return out.String(), err
}

func ExecCmds(cmds []string) []Clis {
	var result = []Clis{}

	for _, cmd := range cmds {
		log.LoggerWContext(ctx).Error(fmt.Sprintln(cmd))
		cli := Clis{cmd: cmd}
		cli.out, cli.err = ExecShell(cmd)

		if cli.err != nil {
			log.LoggerWContext(ctx).Error(cli.err.Error())
			log.LoggerWContext(ctx).Error(fmt.Sprintln(cli.out))
		}
		result = append(result, cli)
	}

	return result
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

func IsFileExist(path string) bool {
	if _, err := os.Stat(path); err != nil {
		return !os.IsNotExist(err)
	}
	return true
}
