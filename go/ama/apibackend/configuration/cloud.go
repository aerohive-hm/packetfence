//cloud.go implements handling REST API:
/*
 *      /a3/api/v1/configuration/cloud
 */

package configuration

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"

"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
"github.com/inverse-inc/packetfence/go/ama/amac"
"github.com/inverse-inc/packetfence/go/log"
)

type cloudPostReq struct {
    Url  string `json:"url"`
	User string `json:"user"`
	Pass string `json:"pass"`
}

type cloudPostRes struct {
    Code  string `json:"code"`
	Msg string `json:"msg"`
}

type CloudGetInfo struct {
    Url  string `json:"url"`
	User string `json:"user"`
	Vhm string `json:"vhm"`
	Status string `json:"status"`
	LastConnectTime string `json:"lastConnectTime"`
}

type Cloud struct {
	crud.Crud
}

func CloudNew(ctx context.Context) crud.SectionCmd {
	cloud := new(Cloud)
	cloud.New()
	cloud.Add("GET", handleGetCloudInfo)
	cloud.Add("POST", handlePostCloudInfo)
	return cloud
}

func handleGetCloudInfo(r *http.Request, d crud.HandlerData) []byte {
	var GetInfo CloudGetInfo

	var ctx = r.Context()
    GetInfo.Url = "https://10.155.100.17/acct-webapp"
    GetInfo.User = "admin%40cust001.com"
    GetInfo.Vhm = amac.VhmidStr
    GetInfo.Status = "connect"
    GetInfo.LastConnectTime = "8888888"

    fmt.Println("into handleGetCloudInfo")
	
	jsonData, err := json.Marshal(GetInfo)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return []byte(err.Error())
	}
	return jsonData
}

func handlePostCloudInfo(r *http.Request, d crud.HandlerData) []byte {
 var res []byte
/*
	ctx := r.Context()
	admin := new(AdminUserInfo)
	err := json.Unmarshal(d.ReqData, admin)
	if err != nil {
		log.LoggerWContext(ctx).Error("unmarshal error:" + err.Error())
		return []byte(`{"code":"fail"}`)
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("admin: %s, pass: %s", admin.User,
		admin.Pass))
	return []byte(crud.PostOK)
	*/
	return res
}

