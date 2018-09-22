/*
	The file implements the following functions:
	1) Updating the network info(asynchronous msg)
	2) Updating the license info(asynchronous msg)
 	3) Updating the nodes info if remove a node from cluster(synchronous msg)
*/

package amac

import (
	"bytes"
	"context"
	"encoding/json"
	"time"
	"fmt"
	"strconv"
	"github.com/inverse-inc/packetfence/go/ama/share"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/log"
	"io/ioutil"
	"net/http"
)

type primaryUpdateData struct {
	MsgType            string `json:"msgType"`
	MasterNodeSystemID string `json:"masterNodeSystemID"`
}

type PrimaryUpdate struct {
	Header tokenCommonHeader `json:"header"`
	Data   primaryUpdateData `json:"data"`
}

type BasicSyncData struct {
	MsgType            string `json:"msgType"`
	ClusterHostName	   string `json:"clusterHostName"`
	License	a3share.A3License `json:"license"`
}

type BasicSyncInfo struct {
	Header	a3share.A3OnboardingHeader	`json:"header"`
	Data	BasicSyncData				`json:"data"`
}

//Sync basic A3 info to RDC after onboarding successfully
func syncBasicInfoToRdc(ctx context.Context) {
	const syncInterval = 3600
	var interval int

    intervalStr := a3config.ReadCloudConf(a3config.SyncInterval)
	if intervalStr == "" {
		interval = syncInterval
	}else {
		interval, _ = strconv.Atoi(intervalStr)
	}
    
	ticker := time.NewTicker(time.Duration(interval) * time.Second)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("Sync basic A3 info to RDC with interval %d seconds", interval))

	for _ = range ticker.C {
		if GetConnStatus() != AMA_STATUS_ONBOARDING_SUC {
			log.LoggerWContext(ctx).Info("Ingore sync basic A3 info for connection status be not onboarding")
			continue
		}
		
		basicSyncInfo := fillBasicA3InfoMsg(ctx)
		ret := UpdateMsgToRdcAsyn(ctx, SyncBasicInfo, basicSyncInfo)
		if ret < 0 {
			log.LoggerWContext(ctx).Error("Sync basic A3 info to RDC failed")
		}
	}
}

func fillBasicA3InfoMsg(ctx context.Context) []BasicSyncInfo {
	var basicInfo BasicSyncInfo
	var slice []BasicSyncInfo

	basicInfo.Header.GetValue(ctx)
	basicInfo.Data.License.GetValue(ctx)

	basicInfo.Data.MsgType = "basic-info-sync"

	managementIface, errint := utils.GetIfaceList("eth0")
	if errint < 0 {
		fmt.Errorf("Get ETH0 interfaces infomation failed")
		basicInfo.Data.ClusterHostName = ""
	} else {
		for _, iface := range managementIface {
			basicInfo.Data.ClusterHostName = a3config.ClusterNew().GetPrimaryClusterVip(iface.Name)
			break
		}
	}

	slice = append(slice, basicInfo)
	return slice
}
	
func fillPrimaryUpdateMsg() []PrimaryUpdate {
	var msgArray []PrimaryUpdate
	msg := PrimaryUpdate{}

	msg.Header.SystemID = utils.GetA3SysId()
	msg.Header.Hostname = utils.GetHostname()
	msg.Header.ClusterID = utils.GetClusterId()

	msg.Data.MsgType = "cluster-status-update"
	msg.Data.MasterNodeSystemID = utils.GetA3SysId()

	msgArray = append(msgArray, msg)

	return msgArray
}

/*
	This function is used to send update message if network/license changes
	be aware: asynchronous mode
*/
func UpdateMsgToRdcAsyn(ctx context.Context, msgType int, in interface{}) int {
	//Check the connect status, if not connected, ignore updating
	if GetConnStatus() != AMA_STATUS_ONBOARDING_SUC {
		log.LoggerWContext(ctx).Info("Ingore updating for connection status be not onboarding")
		return 0
	}
	
	var nodeInfo interface{}

	if asynMsgUrl == "" {
		log.LoggerWContext(ctx).Error("RDC URL is NULL")
		return -1
	}

	switch msgType {
	case NetworkChange:
		log.LoggerWContext(ctx).Info("begin to send initerface change to RDC")
		nodeInfo = a3share.GetIntChgInfo(ctx)
	case LicenseInfoChange:
		log.LoggerWContext(ctx).Info("begin to send license update to RDC")
		nodeInfo = a3share.GetLicenseUpdateInfo(ctx)
	case ClusterStatusUpdate:
		log.LoggerWContext(ctx).Info("begin to send cluster status update to RDC")
		nodeInfo = fillPrimaryUpdateMsg()
	case SyncBasicInfo:
		log.LoggerWContext(ctx).Info("Sync basic A3 info to RDC")
		nodeInfo = fillBasicA3InfoMsg(ctx)
	default:
		log.LoggerWContext(ctx).Error("unexpected message")
	}

	data, _ := json.Marshal(nodeInfo)

	reader := bytes.NewReader(data)
	for {
		request, err := http.NewRequest("POST", asynMsgUrl, reader)
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			return -1
		}

		//Add header option, the tokenStr is from RDC now
		request.Header.Add("Authorization", rdcTokenStr)
		request.Header.Set("Content-Type", "application/json")
		resp, err := client.Do(request)
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			return -1
		}

		body, _ := ioutil.ReadAll(resp.Body)
		log.LoggerWContext(ctx).Info(fmt.Sprintf("receive the response %d", resp.StatusCode))
		log.LoggerWContext(ctx).Info(string(body))
		statusCode := resp.StatusCode
		resp.Body.Close()
		/*
			statusCode = 401 means authenticate fail, need to request valid RDC token
			from the other nodes
		*/
		if statusCode == 401 {
			result := ReqTokenFromOtherNodes(ctx, nil)
			//result == 0 means get the token, try to onboarding again
			if result == 0 {
				continue
			} else {
				//not get the token, return and wait for the event from UI or other nodes
				log.LoggerWContext(ctx).Error(InvalidToken)
				return result
			}
		} else if statusCode == 200 {
			return 0
		} else {
			log.LoggerWContext(ctx).Error(fmt.Sprintf("Update message faile, server(RDC) respons the code %d", statusCode))
			return -1
		}
		return 0
	}
	return 0
}

func getSuccPrompt(msgType int) string {
	switch msgType {
	case RemoveNodeFromCluster:
		return "Remove the link from cloud successfully"

	default:
		return ""
	}
}

func getFailPrompt(msgType int) string {
	switch msgType {
	case RemoveNodeFromCluster:
		return "Remove the link from cloud fail"

	default:
		return ""
	}
}

/*
	This function is used to send update message if network/license changes
	be aware: synchronous mode, should be called by rest APIs and return the
	result
*/
func UpdateMsgToRdcSyn(ctx context.Context, msgType int, in interface{}) (int, string) {
	//Check the connect status, if not connected, ignore updating
	if GetConnStatus() != AMA_STATUS_ONBOARDING_SUC {
		log.LoggerWContext(ctx).Info("Ingore updating for connection status be not onboarding")
		return 0, ""
	}
	
	var nodeInfo interface{}

	if synMsgUrl == "" {
		log.LoggerWContext(ctx).Error("RDC URL is NULL")
		return -1, UrlIsNull
	}

	switch msgType {
	case RemoveNodeFromCluster:
		systemIdArray := in.([]string)
		nodeInfo = a3share.FillRemoveNodeInfo(ctx, systemIdArray)

	default:
		log.LoggerWContext(ctx).Error("unexpected message")
	}

	data, _ := json.Marshal(nodeInfo)
	log.LoggerWContext(ctx).Info("begin to send remove node msg to RDC")
	log.LoggerWContext(ctx).Info(string(data))
	reader := bytes.NewReader(data)
	for {
		request, err := http.NewRequest("POST", synMsgUrl, reader)
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			return -1, OtherError
		}

		//Add header option, the tokenStr is from RDC now
		request.Header.Add("Authorization", rdcTokenStr)
		request.Header.Set("Content-Type", "application/json")
		resp, err := client.Do(request)
		if err != nil {
			log.LoggerWContext(ctx).Info(err.Error())
			return -1, SrvNoResponse
		}

		body, _ := ioutil.ReadAll(resp.Body)
		log.LoggerWContext(ctx).Info(fmt.Sprintf("receive the response %d", resp.StatusCode))
		log.LoggerWContext(ctx).Info(string(body))
		statusCode := resp.StatusCode
		resp.Body.Close()
		/*
			statusCode = 401 means authenticate fail, need to request valid RDC token
			from the other nodes
		*/
		if statusCode == 401 {
			result := ReqTokenFromOtherNodes(ctx, nil)
			//result == 0 means get the token, try to onboarding again
			if result == 0 {
				continue
			} else {
				//not get the token, return and wait for the event from UI or other nodes
				log.LoggerWContext(ctx).Error(fmt.Sprintf("Update message faile, server(RDC) respons the code %d", statusCode))
				return -1, InvalidToken
			}
		} else if statusCode == 200 {
			return 0, getSuccPrompt(msgType)
		} else {
			log.LoggerWContext(ctx).Error(fmt.Sprintf("Update message faile, server(RDC) respons the code %d", statusCode))
			return -1, getFailPrompt(msgType)
		}
	}
	return 0, UpdateMsgSuc
}

func JoinCompleteEvent() {
	event := new(MsgStru)

	event.MsgType = JoinClusterComplete
	event.Data = "Join cluster complete"
	MsgChannel <- *event
}

func EnableCloundIntegration(enableOrDisable string) {
	event := new(MsgStru)

	event.MsgType = CloudIntegrateFunction
	event.Data = enableOrDisable
	MsgChannel <- *event
}
