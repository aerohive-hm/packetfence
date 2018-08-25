//cloud.go implements handling REST API:
/*
 *      /a3/api/v1/configuration/cloud
 */

package configuration

import (
	"context"
	"encoding/json"
	"net/http"
	"fmt"

	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/amac"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/log"
)

type cloudPostReq struct {
	Url  string `json:"url"`
	User string `json:"user"`
	Pass string `json:"pass"`
}

type cloudPostRes struct {
	Code string `json:"code"`
	Msg  string `json:"msg"`
}

type CloudGetInfo struct {
	Url             string `json:"url"`
	User            string `json:"user"`
	Vhm             string `json:"vhm"`
	Status          string `json:"status"`
	LastConnectTime string `json:"lastConnectTime"`
}

type CloudPostInfo struct {
	Url  string `json:"url"`
	User string `json:"user"`
	Pass string `json:"pass"`
}

type Cloud struct {
	crud.Crud
}

func CloudNew(ctx context.Context) crud.SectionCmd {
	cloud := new(Cloud)
	cloud.New()
	cloud.Add("GET", handleGetCloudInfo)
	cloud.Add("POST", HandlePostCloudInfo)
	return cloud
}

func handleGetCloudInfo(r *http.Request, d crud.HandlerData) []byte {
	var GetInfo CloudGetInfo

	var ctx = r.Context()
    log.LoggerWContext(ctx).Error("into handleGetCloudInfo")
	
	GetInfo.Url = a3config.ReadCloudConf(a3config.GDCUrl)
	GetInfo.User = a3config.ReadCloudConf(a3config.User)
	GetInfo.Vhm = a3config.ReadCloudConf(a3config.Vhm)
	GetInfo.Status = amac.GetAMAConnStatus()
	GetInfo.LastConnectTime = fmt.Sprintf("%v", amac.ReadLastContime())

	jsonData, err := json.Marshal(GetInfo)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return []byte(err.Error())
	}
	return jsonData
}

func HandlePostCloudInfo(r *http.Request, d crud.HandlerData) []byte {
    var ret string
    var reason string
    var result int
	ctx := r.Context()
	postInfo := new(CloudPostInfo)
	code := "fail"
	event := new(amac.MsgStru)

	code = "ok"
	ret = "connect to cloud successfully"

    log.LoggerWContext(ctx).Error("int HandlePostCloudInfo")

	err := json.Unmarshal(d.ReqData, postInfo)
	if err != nil {
		log.LoggerWContext(ctx).Error("unmarshal error: " + err.Error())
		goto END
	}

	err = a3config.UpdateCloudConf(a3config.GDCUrl, postInfo.Url)
	if err != nil {
		log.LoggerWContext(ctx).Error("Update cloud config error: " + err.Error())
		goto END
	}

	err = a3config.UpdateCloudConf(a3config.User, postInfo.User)
	if err != nil {
		log.LoggerWContext(ctx).Error("Update cloud config error: " + err.Error())
		goto END
	}

	event.MsgType = amac.GdcConfigChange
	event.Data = postInfo.Pass
	amac.MsgChannel <- *event
	result, reason = amac.LoopConnect(ctx, postInfo.Pass)
	if (result != 0) {
		code = "fail"
		ret = reason
		goto END		
	}

END:
	if err != nil {
		ret = err.Error()
	}
	return crud.FormPostRely(code, ret)
}
