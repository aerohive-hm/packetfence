package apibackclient

import (
	"fmt"
	"time"

	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	//	"github.com/inverse-inc/packetfence/go/log"
)

const StdTimeiTFormat = "2006-01-02T15:04:05"

func VerifyLicense(key string) ([]byte, error) {
	a3Cfg := a3config.A3ReadFull("PF", "A3")["A3"]

	c := new(Client)
	url := a3Cfg["license_server"] + a3Cfg["entitlement_path"]
	sysId := utils.GetA3SysId()
	c.Token = genBasicToken(a3Cfg["license_username"], a3Cfg["license_password"])
	body := fmt.Sprintf(`{"systemId":"%s", "key":"%s"}`, sysId, key)

	err := c.Call("POST", url, body)
	return c.RespData, err
}

func RecordEula() ([]byte, error) {
	a3Cfg := a3config.A3ReadFull("PF", "A3")["A3"]

	c := new(Client)
	url := a3Cfg["license_server"] + a3Cfg["eula_path"] + "/" + utils.GetA3SysId()
	c.Token = genBasicToken(a3Cfg["license_username"], a3Cfg["license_password"])
	body := fmt.Sprintf(`{"timestamp":"%s"}`, time.Now().UTC().Format(StdTimeiTFormat))

	err := c.Call("POST", url, body)
	return c.RespData, err
}
