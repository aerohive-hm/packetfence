package configurator

import (
	"context"
	"encoding/json"
	//"fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama/a3conf"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/client"
	"github.com/inverse-inc/packetfence/go/log"
)

type LicenseConf struct {
	Trial      string `json:"trial"`
	EulaAccept bool   `json:"eula_accept"`
	Key        string `json:"key"`
}

type LicenseEva struct {
	Count        int    `json:"endpointCount"`
	SubStart     string `json:"subStartDate"`
	SubEnd       string `json:"subEndDate"`
	SupportStart string `json:"supportStartDate"`
	SupportEnd   string `json:"supportEndDate"`
	Status       int    `json:"keyStatus"`
	Type         string `json:"keyType"`
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
	code := "fail"
	license := new(LicenseConf)
	err := json.Unmarshal(d.ReqData, license)
	if err != nil {
		log.LoggerWContext(ctx).Error("unmarshal error:" + err.Error())
		goto END
	}

	msg, err := apibackclient.VerifyLicense(license.Key)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		goto END
	}
	eva := new(LicenseEva)
	err = json.Unmarshal(msg, eva)
	if err != nil {
		goto END
	}
	fmt.Println(eva)

END:
	ret := ""
	if err != nil {
		ret = err.Error()
	}
	return crud.FormPostRely(code, ret)
}
