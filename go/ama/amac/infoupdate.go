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
	"fmt"
	"github.com/inverse-inc/packetfence/go/ama/share"
	"github.com/inverse-inc/packetfence/go/log"
	"io/ioutil"
	"net/http"
)

/*
	This function is used to send update message if network/license changes
	be aware: asynchronous mode
*/
func updateMsgToRdcAsyn(ctx context.Context, msgType int) int {
	var nodeInfo interface{}

	if updateMsgUrl == "" {
		log.LoggerWContext(ctx).Error("RDC URL is NULL")
		return -1
	}

	switch msgType {
	case NetworkChange:
		log.LoggerWContext(ctx).Error("begin to send initerface change to RDC")
		nodeInfo = a3share.GetIntChgInfo(ctx)
	case LicenseInfoChange:
		log.LoggerWContext(ctx).Error("begin to send license update to RDC")
		nodeInfo = a3share.GetLicenseUpdateInfo(ctx)
	default:
		log.LoggerWContext(ctx).Error("unexpected message")
	}

	data, _ := json.Marshal(nodeInfo)
	log.LoggerWContext(ctx).Error(string(data))
	reader := bytes.NewReader(data)
	for {
		request, err := http.NewRequest("POST", updateMsgUrl, reader)
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			return -1
		}

		//Add header option, the tokenStr is from RDC now
		request.Header.Add("Authorization", rdcTokenStr)
		request.Header.Set("Content-Type", "application/json")
		resp, err := client.Do(request)
		if err != nil {
			log.LoggerWContext(ctx).Error("Update message to RDC fail")
			log.LoggerWContext(ctx).Error(err.Error())
			return -1
		}

		body, _ := ioutil.ReadAll(resp.Body)
		log.LoggerWContext(ctx).Error(fmt.Sprintf("receive the response %d", resp.StatusCode))
		log.LoggerWContext(ctx).Error(string(body))
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

/*
	This function is used to send update message if network/license changes
	be aware: synchronous mode, should be called by rest APIs and return the
	result
*/
func UpdateMsgToRdcSyn(ctx context.Context, msgType int) (int, string) {
	var nodeInfo interface{}

	if connMsgUrl == "" {
		log.LoggerWContext(ctx).Error("RDC URL is NULL")
		return -1, UrlIsNull
	}

	switch msgType {
	case RemoveNodeFromCluster:
		nodeInfo = a3share.GetRemoveNodeInfo(ctx)
	default:
		log.LoggerWContext(ctx).Error("unexpected message")
	}

	data, _ := json.Marshal(nodeInfo)
	log.LoggerWContext(ctx).Info("begin to send remove node msg to RDC")
	log.LoggerWContext(ctx).Info(string(data))
	reader := bytes.NewReader(data)
	for {
		request, err := http.NewRequest("POST", connMsgUrl, reader)
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			return -1, OtherError
		}

		//Add header option, the tokenStr is from RDC now
		request.Header.Add("Authorization", rdcTokenStr)
		request.Header.Set("Content-Type", "application/json")
		resp, err := client.Do(request)
		if err != nil {
			log.LoggerWContext(ctx).Info("remove node message to RDC fail")
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
			return 0, UpdateMsgSuc
		} else {
			log.LoggerWContext(ctx).Error(fmt.Sprintf("Update message faile, server(RDC) respons the code %d", statusCode))
			return -1, InvalidToken
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
