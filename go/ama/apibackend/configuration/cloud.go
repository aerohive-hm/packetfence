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
	"strings"

	"errors"
	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/amac"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/event"
	innerClient "github.com/inverse-inc/packetfence/go/ama/client"
	"github.com/inverse-inc/packetfence/go/ama/share"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/ama/database"
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

type NodesInfo struct {
	Head CloudGetHeader `json:"header"`
	Data []CloudGetData `json:"data"`
}

type CloudConf struct {
	GdcUrl string `json:"gdcurl"`
	User   string `json:"user"`
}

type GetNodesInfo struct {
	MsgType string    `json:"msgtype"`
	Body    NodesInfo `json:"body"`
}

type GetCloudConf struct {
	MsgType string    `json:"msgtype"`
	Body    CloudConf `json:"body"`
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

	if a3config.ClusterNew().CheckClusterEnable() {
		return "cluster"
	} else {
		return "standalone"
	}

	return ""
}

type CloudGetHandler interface {
	getValue(context.Context)
	convertToJson(ctx context.Context) []byte
}

func (nodes *GetNodesInfo) getValue(ctx context.Context) {
	var self CloudGetData

	nodes.MsgType = "nodesInfo"

	nodes.Body.Head.RdcUrl = a3config.ReadCloudConf(a3config.RDCUrl)
	nodes.Body.Head.OwnerId = a3config.ReadCloudConf(a3config.OwnerId)
	nodes.Body.Head.VhmId = a3config.ReadCloudConf(a3config.Vhm)
	nodes.Body.Head.Mode = getRunMode()
	nodes.Body.Head.Region = a3config.ReadCloudConf(a3config.Region)

	self.Hostname = utils.GetHostname()
	self.Status = amac.GetAMAConnStatus()
	self.LastContactTime = fmt.Sprintf("%v", amac.ReadLastConTime().Format("2006-01-02 15:04:05 MST"))
	nodes.Body.Data = append(nodes.Body.Data, self)

	nodeList := a3config.ClusterNew().FetchNodesInfo()
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
		log.LoggerWContext(ctx).Info(fmt.Sprintf("Fetch node %s info: %s,%s,%s", node.IpAddr, other.Hostname, other.Status, other.LastContactTime))
		nodes.Body.Data = append(nodes.Body.Data, other)
	}
}

func (conf *GetCloudConf) getValue(ctx context.Context) {
	conf.MsgType = "cloudConf"
	conf.Body.GdcUrl = a3config.ReadCloudConf(a3config.GDCUrl)
	conf.Body.User = a3config.ReadCloudConf(a3config.User)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("Fetch cloud conf info: %s,%s", conf.Body.GdcUrl, conf.Body.User))
}

func (nodesInfo *GetNodesInfo) convertToJson(ctx context.Context) []byte {
	jsonData, err := json.Marshal(nodesInfo)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return []byte(err.Error())
	}
	return jsonData
}

func (cloudConf *GetCloudConf) convertToJson(ctx context.Context) []byte {
	jsonData, err := json.Marshal(cloudConf)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return []byte(err.Error())
	}
	return jsonData
}

func handleGetCloudInfo(r *http.Request, d crud.HandlerData) []byte {
	var handler CloudGetHandler
	ctx := r.Context()
	switchConf := a3config.ReadCloudConf(a3config.Switch)

	if switchConf == "enable" {
		nodesInfo := new(GetNodesInfo)
		nodesInfo.getValue(ctx)
		handler = nodesInfo
	} else {
		cloudConf := new(GetCloudConf)
		cloudConf.getValue(ctx)
		handler = cloudConf
	}

	return handler.convertToJson(ctx)
}

func startService() {
	if utils.IsFileExist(utils.A3CurrentlyAt) {
		return
	}

	clusterEnable := a3config.ClusterNew().CheckClusterEnable()

	if clusterEnable {
		a3config.UpdateClusterFile()
	}

	utils.InitStartService(clusterEnable)
}

func forceUrlStartWithHttps(s string) string {
	str := strings.Replace(s, " ", "", -1)
	if str[0:5] == "https" {
		return str
	} else if str[0:4] == "http" {
		s1 := strings.Replace(str, "http", "https", 1)
		return s1
	} else {
		s2 := strings.Join([]string{"https://", str}, "")
		return s2
	}
}
func HandlePostCloudInfo(r *http.Request, d crud.HandlerData) []byte {
	var ret, s string
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
		ret = "Parsing posted cloud info failed"
		goto END
	}

	//This case means disable the cloud integration
	if postInfo.Url == "" {
		var sysIDs []string
		nodeList := a3config.ClusterNew().FetchNodesInfo()
		if a3config.ClusterNew().CheckClusterEnable() == false {
			sysIDs = append(sysIDs, utils.GetA3SysId())
		} else {
			tmpDB := new(amadb.A3Db)
			err := tmpDB.DbInit()
			if err != nil {
				log.LoggerWContext(ctx).Error("Open database error: " + err.Error())
				ret = "Opening database failed"
				goto END
			}
			db := tmpDB.Db
			defer db.Close()
			for _, node := range nodeList{
				var sysId string
				err = db.QueryRow(fmt.Sprintf("SELECT system_id FROM a3_cluster_member WHERE hostname='%s'", node.Hostname)).Scan(&sysId)
				if err != nil {
					log.LoggerWContext(ctx).Error(fmt.Sprintf("Fetch systemID from mysql for hostname %s failed.", node.Hostname))
					continue
				}
				log.LoggerWContext(ctx).Info(fmt.Sprintf("Fetch systemID succeddfully: %s:%s.", node.Hostname, sysId))
				sysIDs = append(sysIDs, sysId)
			}
		}

		result, msg := amac.UpdateMsgToRdcSyn(ctx, amac.RemoveNodeFromCluster, sysIDs)
		if result < 0 {
			log.LoggerWContext(ctx).Error("UpdateMsgToRdcSyn failed:" + msg)
			ret = "Updating message to RDC failed"
			goto END
		}
	
		event.MsgType = amac.CloudIntegrateFunction
		event.Data = "disable"
		amac.MsgChannel <- *event
		code = "ok"
		ret = "Disable cloud integration successfully"

		ownMgtIp := utils.GetOwnMGTIp()
		for _, node := range nodeList {
			if node.IpAddr == ownMgtIp {
				continue
			}
			go EnableNodeConnGDC(ctx, node, false)
		}

		goto END
	}

	s = forceUrlStartWithHttps(postInfo.Url)
	err = a3config.UpdateCloudConf(a3config.GDCUrl, s)
	if err != nil {
		log.LoggerWContext(ctx).Error("Update cloud GDC URL error: " + err.Error())
		ret = "Updating cloud GDC URL failed"
		goto END
	}

	err = a3config.UpdateCloudConf(a3config.User, postInfo.User)
	if err != nil {
		log.LoggerWContext(ctx).Error("Update cloud username error: " + err.Error())
		ret = "Updating cloud username failed"
		goto END
	}

	err = a3config.UpdateCloudConf(a3config.Switch, "enable")
	if err != nil {
		log.LoggerWContext(ctx).Error("Update cloud config error: " + err.Error())
		ret = "Updating cloud configuration failed"
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
func ReqAMAStatusfromOneNode(ctx context.Context, node a3config.NodeInfo) *event.AMAStatus {
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
func EnableNodeConnGDC(ctx context.Context, node a3config.NodeInfo, enable bool) error {
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
