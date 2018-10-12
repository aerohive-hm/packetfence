package configurator

import (
	"context"
	"encoding/json"
	"net/http"
	"time"

	"github.com/inverse-inc/packetfence/go/ama/a3config"
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

func msg4WebUI(status int) string {
	var msg string
	if status == 409 {
		msg = "Entitlement key is already in use."
	} else if status > 500 {
		msg = "Unable to validate entitlement key at this time. Try again later."
	} else {
		msg = "Entitlement key does not exist or is not valid."
	}

	return msg
}


func handlePostLicenseConf(r *http.Request, d crud.HandlerData) []byte {
	var resp []byte
	var eva *LicenseEva
	var status int

	ctx := r.Context()
	code := "ok"
	msg := ""

	license := new(LicenseConf)
	err := json.Unmarshal(d.ReqData, license)
	if err != nil {
		log.LoggerWContext(ctx).Error("unmarshal error:" + err.Error())
		code = "fail"
		msg = "unknown POST data"
		goto END
	}

	if license.Trial == "1" {
		err = createTrial()
		if err != nil {
			code = "fail"
			msg = "Create Trial data into database failed"
		}
		a3config.RecordSetupStep(a3config.StepAerohiveCloud, code)
		goto END
	}

	if license.EulaAccept {
		log.LoggerWContext(ctx).Info("record Eula accept.")
		timestamp := utils.AhNowUtcFormated4License()
		_, err, status = apibackclient.RecordEula(timestamp)
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			code = "fail"
			msg = msg4WebUI(status)
			goto END
		}
		err = recordEula(timestamp)
		if err != nil {		
			code = "fail"
			msg = "Writing data to database failed"
		}
		a3config.RecordSetupStep(a3config.StepAerohiveCloud, code)
		goto END
	}

	resp, err, status = apibackclient.VerifyLicense(license.Key)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		code = "fail"
		msg = msg4WebUI(status)
		goto END
	}
	eva = new(LicenseEva)
	err = json.Unmarshal(resp, eva)
	if err != nil {
		code = "fail"
		msg = "Parsing respond data failed"
		goto END
	}

	err = create(license.Key, eva)
	if err == nil {
		a3config.RecordSetupStep(a3config.StepAgreement, code)
	} else {
		code = "fail"
		msg = "Writing License data to database failed"
	}

END:
	return crud.FormPostRely(code, msg)
}
