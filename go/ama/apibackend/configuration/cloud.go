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

	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/amac"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/share"
	//	"github.com/inverse-inc/packetfence/go/ama/utils"
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
	GetInfo.LastConnectTime = fmt.Sprintf("%v", amac.ReadLastConTime())

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

	log.LoggerWContext(ctx).Error("int HandlePostCloudInfo")

	code = "fail"
	ret = ""

	err := json.Unmarshal(d.ReqData, postInfo)
	if err != nil {
		log.LoggerWContext(ctx).Error("unmarshal error: " + err.Error())
		goto END
	}

	//This case means disable the cloud integration
	if postInfo.Url == "" {
		err = a3config.UpdateCloudConf(a3config.Switch, "disable")
		if err != nil {
			log.LoggerWContext(ctx).Error("Update cloud switch error: " + err.Error())
		} else {
			event.MsgType = amac.DisableCloudIntegration
			event.Data = "disable"
			amac.MsgChannel <- *event
		}
		code = "ok"
		ret = "disable cloud integration successfully"
		goto END
	}

	err = a3config.UpdateCloudConf(a3config.GDCUrl, postInfo.Url)
	if err != nil {
		log.LoggerWContext(ctx).Error("Update cloud GDC URL error: " + err.Error())
		goto END
	}

	err = a3config.UpdateCloudConf(a3config.User, postInfo.User)
	if err != nil {
		log.LoggerWContext(ctx).Error("Update cloud username error: " + err.Error())
		goto END
	}

	err = a3config.UpdateCloudConf(a3config.Switch, "enable")
	if err != nil {
		log.LoggerWContext(ctx).Error("Update cloud config error: " + err.Error())
		goto END
	}

	result, reason = amac.LoopConnect(ctx, postInfo.Pass)
	if result == 0 {
		code = "ok"
		ret = "connect to cloud successfully"
	} else {
		ret = reason
	}

END:
	//start A3 all the services
	if code == "ok" {
		go a3share.StartService()
		/*
			if err != nil {
				log.LoggerWContext(ctx).Info(err.Error())
			}
		*/
	}
	if err != nil {
		ret = err.Error()
	}
	return crud.FormPostRely(code, ret)
}
