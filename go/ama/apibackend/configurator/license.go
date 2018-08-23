package configurator

import (
	"context"
	"encoding/json"
	//	"fmt"
	"net/http"
	"time"

	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/client"
	"github.com/inverse-inc/packetfence/go/ama/database"
	"github.com/inverse-inc/packetfence/go/log"
)

const (
	sqlUpdate = "replace into a3_entitlement(entitlement_key, type, status, endpoint_count," +
		"sub_start, sub_end, support_start, support_end)values(?,?,?,?,?,?,?,?)"
)

type LicenseConf struct {
	Trial      string `json:"trial"`
	EulaAccept bool   `json:"eula_accept"`
	Key        string `json:"key"`
}

type LicenseEva struct {
	Type         string `json:"keyType"`
	Status       int    `json:"keyStatus"`
	Count        int    `json:"endpointCount"`
	SubStart     string `json:"subStartDate"`
	SubEnd       string `json:"subEndDate"`
	SupportStart string `json:"supportStartDate"`
	SupportEnd   string `json:"supportEndDate"`
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

func createTrial() error {
	t := time.Now()
	timeStart := t.UTC().Format("2006-01-02 15:04:05")
	timeEnd := t.Add(30 * 24 * time.Hour).UTC().Format("2006-01-02 15:04:05")

	sql := []amadb.SqlCmd{
		{
			sqlUpdate,
			[]interface{}{
				"TRIAL",
				"Trial",
				2,
				100,
				timeStart,
				timeEnd,
				timeStart,
				timeEnd,
			},
		},
	}

	db := new(amadb.A3Db)
	err := db.Exec(sql)
	if err != nil {
		return err
	}
	return nil
}

func create(key string, eva *LicenseEva) error {
	sql := []amadb.SqlCmd{
		{
			sqlUpdate,
			[]interface{}{
				key,
				eva.Type,
				eva.Status,
				eva.Count,
				eva.SubStart,
				eva.SubEnd,
				eva.SupportStart,
				eva.SupportEnd,
			},
		},
	}

	db := new(amadb.A3Db)
	err := db.Exec(sql)
	if err != nil {
		return err
	}
	return nil
}

func handlePostLicenseConf(r *http.Request, d crud.HandlerData) []byte {
	var msg []byte
	var eva *LicenseEva

	ctx := r.Context()
	code := "fail"

	license := new(LicenseConf)
	err := json.Unmarshal(d.ReqData, license)
	if err != nil {
		log.LoggerWContext(ctx).Error("unmarshal error:" + err.Error())
		goto END
	}

	if license.Trial == "1" {
		log.LoggerWContext(ctx).Info("czhong: create trial")
		err = createTrial()
		if err == nil {
			code = "ok"
		}
		goto END
	}

	if license.EulaAccept {
		_, err = apibackclient.RecordEula()
		if err == nil {
			code = "ok"
		}
		goto END
	}

	msg, err = apibackclient.VerifyLicense(license.Key)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		goto END
	}
	eva = new(LicenseEva)
	err = json.Unmarshal(msg, eva)
	if err != nil {
		goto END
	}

	err = create(license.Key, eva)
	if err == nil {
		code = "ok"
	}

END:
	ret := ""
	if err != nil {
		ret = err.Error()
	}
	return crud.FormPostRely(code, ret)
}
