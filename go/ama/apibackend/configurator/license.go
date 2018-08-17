package configurator

import (
	"context"
	"encoding/json"
	//  "fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/log"
)

type LicenseConf struct {
	Trial      string `json:"trial"`
	EulaAccept bool   `json:"eula_accept"`
	Key        string `json:"key"`
}

type License struct {
	crud.Crud
}

func LicenseNew(ctx context.Context) crud.SectionCmd {
	license := new(Cloud)
	license.New()
	license.Add("GET", handleGetLicenseConf)
	license.Add("POST", handlePostLicenseConf)
	return license

}

func handleGetLicenseConf(r *http.Request, d crud.HandlerData) []byte {
	// Data for demo
	license := map[string]string{
		"trial": "0",
	}

	var ctx = r.Context()
	jsonData, err := json.Marshal(license)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return []byte(err.Error())
	}
	return jsonData
}

func handlePostLicenseConf(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	license := new(LicenseConf)
	err := json.Unmarshal(d.ReqData, license)
	if err != nil {
		log.LoggerWContext(ctx).Error("unmarshal error:" + err.Error())
		return []byte(`{"code":"fail"}`)
	}

	return []byte(crud.PostOK)
}
