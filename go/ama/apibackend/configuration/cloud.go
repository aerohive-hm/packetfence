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

	"errors"
	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/amac"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/event"
	innerClient "github.com/inverse-inc/packetfence/go/ama/client"
	"github.com/inverse-inc/packetfence/go/ama/share"
	"github.com/inverse-inc/packetfence/go/ama/utils"
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

	if a3config.CheckClusterEnable() {
		return "cluster"
	} else {
		return "standalone"
	}

	return ""
}

func handleGetCloudInfo(r *http.Request, d crud.HandlerData) []byte {
	var getInfo CloudGetInfo
	var dataArray []CloudGetData
	var self CloudGetData

	var ctx = r.Context()
	log.LoggerWContext(ctx).Info("into handleGetCloudInfo")

	getInfo.Head.RdcUrl = a3config.ReadCloudConf(a3config.RDCUrl)
	getInfo.Head.OwnerId = a3config.ReadCloudConf(a3config.OwnerId)
	getInfo.Head.VhmId = a3config.ReadCloudConf(a3config.Vhm)
	getInfo.Head.Mode = getRunMode()
	getInfo.Head.Region = amac.GetRdcRegin(getInfo.Head.RdcUrl)

	self.Hostname = utils.GetHostname()
	self.Status = amac.GetAMAConnStatus()
	self.LastContactTime = fmt.Sprintf("%v", amac.ReadLastConTime())

	dataArray = append(dataArray, self)

	nodeList := a3share.FetchNodesInfo()
	ownMgtIp := utils.GetOwnMGTIp()
	for _, node := range nodeList {
		other := CloudGetData{}
		if node.IpAddr == ownMgtIp {
			continue
		}
		amaStatus := ReqAMAStatusfromOneNode(ctx, node)
		if amaStatus == nil {
			log.LoggerWContext(ctx).Error(fmt.Sprintf("Can't get AMA status info from node %s.", node.IpAddr))
			continue
		}
		other.Hostname = amaStatus.Hostname
		other.Status = amaStatus.Status
		other.LastContactTime = amaStatus.LastConnTime
		dataArray = append(dataArray, other)
	}
	getInfo.Data = dataArray

	jsonData, err := json.Marshal(getInfo)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return []byte(err.Error())
	}
	return jsonData
}

func startService() {
	if utils.IsFileExist(utils.A3CurrentlyAt) {
		return
	}

	a3config.UpdateGaleraUser()
	a3config.UpdateWebservicesAcct()
	a3config.UpdateClusterFile()
	utils.InitStartService()
	amac.JoinCompleteEvent()
}
func HandlePostCloudInfo(r *http.Request, d crud.HandlerData) []byte {
	var ret string
	var reason string
	var result int

	ctx := r.Context()
	postInfo := new(CloudPostInfo)
	code := "fail"
	event := new(amac.MsgStru)

	log.LoggerWContext(ctx).Info("int HandlePostCloudInfo")

	ret = ""

	err := json.Unmarshal(d.ReqData, postInfo)
	if err != nil {
		log.LoggerWContext(ctx).Error("unmarshal error: " + err.Error())
		goto END
	}

	//This case means disable the cloud integration
	if postInfo.Url == "" {
		event.MsgType = amac.CloudIntegrateFunction
		event.Data = "disable"
		amac.MsgChannel <- *event
		code = "ok"
		ret = "disable cloud integration successfully"

		nodeList := a3share.FetchNodesInfo()
		ownMgtIp := utils.GetOwnMGTIp()
		for _, node := range nodeList {
			if node.IpAddr == ownMgtIp {
				continue
			}
			go EnableNodeConnGDC(ctx, node, false)
		}

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

		//Need discuss here: is the trigger time correct?
		amac.TriggerUpdateNodesToken(ctx, true)
	} else {
		ret = reason
	}

END:
	//start A3 all the services
	if code == "ok" {
		go startService()
		a3config.RecordSetupStep(a3config.StepStartingManagement, code)
	}

	if err != nil {
		ret = err.Error()
	}
	return crud.FormPostRely(code, ret)
}

//Request AMA status from one node.
func ReqAMAStatusfromOneNode(ctx context.Context, node a3share.NodeInfo) *event.AMAStatus {
	amaInfo := event.AMAStatus{}
	url := fmt.Sprintf("https://%s:9999/a3/api/v1/event/ama/status", node.IpAddr)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("Query AMA info from node %s", node.IpAddr))

	client := new(innerClient.Client)
	client.Host = node.IpAddr
	err := client.ClusterSend("GET", url, "")
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return nil
	}

	body := client.RespData

	err = json.Unmarshal([]byte(body), &amaInfo)
	if err != nil {
		log.LoggerWContext(ctx).Error(fmt.Sprintf("Json Unmarshal failed: %s", err.Error()))
		return nil
	}

	return &amaInfo
}

// Enable or DIsable special node connect to GDC.
func EnableNodeConnGDC(ctx context.Context, node a3share.NodeInfo, enable bool) error {
	action := event.AMAAction{}
	if enable == true {
		action.Action = "enable"
	} else {
		action.Action = "disable"
	}
	log.LoggerWContext(ctx).Info(fmt.Sprintf("Send POST message to %s node %s connects to GDC", action.Action, node.IpAddr))

	jsonData, _ := json.Marshal(action)
	url := fmt.Sprintf("https://%s:9999/a3/api/v1/event/ama/action", node.IpAddr)

	client := new(innerClient.Client)
	client.Host = node.IpAddr
	err := client.ClusterSend("POST", url, string(jsonData))
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return err
	}

	statusCode := client.Status
	if statusCode == 200 {
		respData := new(a3share.RespData)
		err = json.Unmarshal([]byte(client.RespData), respData)
		if err != nil {
			log.LoggerWContext(ctx).Error(fmt.Sprintf("Json Unmarshal failed: %s", err.Error()))
			return err
		}
		if respData.Code == "ok" {
			log.LoggerWContext(ctx).Info(fmt.Sprintf("%s node %s connects to GDC successfully.", action.Action, node.IpAddr))
			return nil
		} else {
			log.LoggerWContext(ctx).Error(fmt.Sprintf("%s node %s connects to GDC failed, return message %s.", action.Action, node.IpAddr, respData.Msg))
			errors.New(respData.Msg)
		}
	} else {
		log.LoggerWContext(ctx).Error(fmt.Sprintf("%s node %s connects to GDC failed, return code %d.", action.Action, node.IpAddr, statusCode))
	}
	return errors.New("Action error")
}
