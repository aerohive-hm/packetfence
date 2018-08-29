package configurator

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/client"
	"github.com/inverse-inc/packetfence/go/ama/database"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
)

const (
	sqlUpdateLicense = "replace into a3_entitlement(entitlement_key, type, status, endpoint_count," +
		"sub_start, sub_end, support_start, support_end)values(?,?,?,?,?,?,?,?)"
	sqlUpdateEula = "replace into a3_eula_acceptance(timestamp, is_synced)values(?,?)"
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
			sqlUpdateLicense,
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
	return db.Exec(sql)
}

func create(key string, eva *LicenseEva) error {
	sql := []amadb.SqlCmd{
		{
			sqlUpdateLicense,
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
	return db.Exec(sql)
}

func recordEula(timestamp string) error {
	sql := []amadb.SqlCmd{
		{
			sqlUpdateEula,
			[]interface{}{
				timestamp,
				true,
			},
		},
	}

	db := new(amadb.A3Db)
	return db.Exec(sql)
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
		err = createTrial()
		if err == nil {
			code = "ok"
		}
		goto END
	}

	if license.EulaAccept {
		log.LoggerWContext(ctx).Info("record Eula accept.")
		timestamp := utils.AhNowUtcFormated()
		resp, err := apibackclient.RecordEula(timestamp)
		if err != nil {
			goto END
		}
		err = recordEula(timestamp)
		if err == nil {
			code = "ok"
			log.LoggerWContext(ctx).Info(fmt.Sprintln(resp))

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
