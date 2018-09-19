package utils

import (
	"bufio"
	"bytes"
	"context"
	"fmt"
	"io"
	"os"
	"os/exec"
	"regexp"
	"strings"

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

	log.LoggerWContext(ctx).Info(fmt.Sprintln(s))
	var out bytes.Buffer
	cmd.Stdout = &out

	err := cmd.Run()
	return out.String(), err
}

func ExecCmds(cmds []string) []Clis {
	var result = []Clis{}

	for _, cmd := range cmds {
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

	return strings.TrimRight(uuid, "\n")
}

func IsFileExist(path string) bool {
	if _, err := os.Stat(path); err != nil {
		return !os.IsNotExist(err)
	}
	return true
}

func IsFileZero(path string) bool {
	stat, err := os.Stat(path)
	if err != nil {
		return os.IsNotExist(err)
	}
	return stat.Size() == 0
}

func CreateClusterId() error {
	path := "/usr/local/pf/conf/clusterid.conf"
	if IsFileExist(path) {
		return nil
	}
	_, err := os.Create(path)
	if err != nil {
		return err
	}
	clusterid := GenClusterID()

	fmt.Println(len(clusterid), clusterid)
	cmd := fmt.Sprintf(`echo -n "%s" > %s`, clusterid, path)
	_, err = ExecShell(cmd)
	if err != nil {
		fmt.Println("%s:exec error", cmd)
		return err
	}
	return nil
}

func GetClusterId() string {
	cmd := "cat /usr/local/pf/conf/clusterid.conf"
	out, err := ExecShell(cmd)
	if err != nil {
		fmt.Println("%s:exec error", cmd)
		return ""
	}
	return out
}

func UseDefaultClusterConf() error {
	cmd := "cp -f /usr/local/pf/conf/cluster.conf.example /usr/local/pf/conf/cluster.conf"
	_, err := ExecShell(cmd)
	if err != nil {
		fmt.Println("%s:exec error", cmd)
		return err
	}
	/*delete clusterid.conf at same time*/
	path := "/usr/local/pf/conf/clusterid.conf"
	if IsFileExist(path) {
		cmd = "rm -f /usr/local/pf/conf/clusterid.conf"
		_, err = ExecShell(cmd)
		if err != nil {
			fmt.Println("%s:exec error", cmd)
			return err
		}
	}

	return nil
}

func ClearFileContent(path string) error {

	if IsFileExist(path) {
		cmd := "> " + path
		_, err := ExecShell(cmd)
		if err != nil {
			fmt.Println("%s:exec error", cmd)
			return err
		}
	}
	return nil
}

func GetDnsServer() []string {
	out, err := ExecShell(`cat /etc/resolv.conf`)
	if err != nil {
		return []string{}
	}
	re := regexp.MustCompile(`\b\s*[^#]?nameserver\s*([\d\.]+)`)
	ret := re.FindAllStringSubmatch(out, -1)

	if len(ret) == 0 {
		return []string{}
	}
	var dns []string
	for _, v := range ret {
		dns = append(dns, v[1])
	}
	return dns
}
