package apibackclient

import (
	"fmt"

	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	//	"github.com/inverse-inc/packetfence/go/log"
)


func VerifyLicense(key string) ([]byte, error, int) {
	a3Cfg := a3config.A3ReadFull("PF", "A3")["A3"]

	c := new(Client)
	url := a3Cfg["license_server"] + a3Cfg["entitlement_path"]
	sysId := utils.GetA3SysId()
	c.Token = genBasicToken(a3Cfg["license_username"], a3Cfg["license_password"])
	body := fmt.Sprintf(`{"systemId":"%s", "key":"%s"}`, sysId, key)

	err := c.Call("POST", url, body)
	return c.RespData, err, c.Status
}

func RecordEula(timestamp string) ([]byte, error, int) {
	a3Cfg := a3config.A3ReadFull("PF", "A3")["A3"]

	c := new(Client)
	url := a3Cfg["license_server"] + a3Cfg["eula_path"] + "/" + utils.GetA3SysId()
	c.Token = genBasicToken(a3Cfg["license_username"], a3Cfg["license_password"])
	body := fmt.Sprintf(`{"timestamp":"%s"}`, timestamp)

	err := c.Call("POST", url, body)
	return c.RespData, err, c.Status
}
