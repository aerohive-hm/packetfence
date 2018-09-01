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

type CloudGetHeader struct {
	RdcUrl  string `json:"rdcUrl"`
	Region  string `json:"region"`
	OwnerId string `json:"ownerId"`
	VhmId   string `json:"vhmId"`
	Mode    string `json:"mode"`
}

type CloudGetData struct {
	Hostname        string `json:"hostname"`
	Status          string `json:"status"`
	LastContactTime string `json:"lastContactTime"`
}

type CloudGetInfo struct {
	Head CloudGetHeader `json:"header"`
	Data []CloudGetData `json:"data"`
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

func getRunMode() string {
	/*
		if a3config.CheckClusterEnable() {
			return "cluster"
		} else {
			return "standalone"
		}
	*/
	return ""
}

func handleGetCloudInfo(r *http.Request, d crud.HandlerData) []byte {
	var GetInfo CloudGetInfo
	//var memberArray []amac.MemberList
	var dataArray []CloudGetData
	var self CloudGetData

	var ctx = r.Context()
	log.LoggerWContext(ctx).Error("into handleGetCloudInfo")

	GetInfo.Head.RdcUrl = a3config.ReadCloudConf(a3config.RDCUrl)
	GetInfo.Head.OwnerId = a3config.ReadCloudConf(a3config.OwnerId)
	GetInfo.Head.VhmId = a3config.ReadCloudConf(a3config.Vhm)
	GetInfo.Head.Mode = getRunMode()
	GetInfo.Head.Region = amac.GetRdcRegin(GetInfo.Head.RdcUrl)

	self.Hostname = a3config.GetHostname()
	self.Status = amac.GetAMAConnStatus()
	self.LastContactTime = fmt.Sprintf("%v", amac.ReadLastConTime())

	dataArray = append(dataArray, self)

	//memberArray = amac.FetchNodeList()
	//for _, mem := range memberArray {

	//to do, call the API
	//}

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
	//var memberArray []amac.MemberList

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

		//memberArray = amac.FetchNodeList()
		//for _, mem := range memberArray {
		//to do, call the API to notify disable the cloud integration
		//}

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

		//memberArray = amac.FetchNodeList()
		//for _, mem := range memberArray {
		//to do, call the API to notify enable the cloud integration
		//}

	} else {
		ret = reason
	}

END:
	//start A3 all the services
	if code == "ok" {
		go a3share.StartService()
	}

	if err != nil {
		ret = err.Error()
	}
	return crud.FormPostRely(code, ret)
}
