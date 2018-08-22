/*
	The file implements the following functions:
	1) start the front end component damon
	2) try to connect RDC using the current RDC token
 	3) monitorinig the message from UI and other nodes
 	4)
*/

package amac

import (
	//"crypto/x509"
	"context"
	"encoding/json"
	"fmt"
	"github.com/inverse-inc/packetfence/go/log"
	"io/ioutil"
	"net/http"
	"sync"
	"time"
)

const (
	AMA_STATUS_INIT           = 0
	AMA_STATUS_CONNECING_GDC  = 1
	AMA_STATUS_CONNECING_RDC  = 2
	AMA_STATUS_ONBOARDING_SUC = 3
	AMA_STATUS_UNKNOWN        = 100
)
const (
	GdcConfigChange       = 1
	NetworkChange         = 2
	LicenseInfoChange     = 3
	Disconnet             = 4
	RdcTokenUpdate        = 5
	RemoveNodeFromCluster = 6
)
const KEEPALIVE_TIMEOUT_COUNT_MAX = 3

var (
	ama_connect_status = AMA_STATUS_INIT
	m                  = new(sync.RWMutex)
	timeoutCount       uint64
	//create channel to store messages from UI
	MsgChannel = make(chan MsgStru, 4096)
)

type MsgStru struct {
	MsgType int
	Data    string
}

type SliceMock struct {
	addr uintptr
	len  int
	cap  int
}

type KeepAliveResFromRdc struct {
	Header A3CommonHeader    `json:"header"`
	Data   map[string]string `json:"data"`
}

func updateConnStatus(status int) {
	m.Lock()
	ama_connect_status = status
	m.Unlock()
}

//The UI damon will call this API, so it is public
func GetConnStatus() int {
	m.RLock()
	status := ama_connect_status
	m.RUnlock()
	return status
}

/*
	Entry function for the front end component
*/
func Entry(ctx context.Context) {
	var msg MsgStru

	//check if enable the cloud integraton, if no, skip the connectToRdcWithoutPara()
	//if (enbale the cloud integration = true) {
	//trying to connect to the cloud when damon start
	//result := connectToRdcWithoutPara(ctx)
	/*
		To to, hanle the error, include: RDC auth fail,
		request RDC token from other nodes fail
	*/
	//if result != 0 {
	//log.LoggerWContext(ctx).Info("Waiting events from UI or other nodes")
	//}

	//}

	loopConnect(ctx)
	//start a goroutine, sending the keepalive only when the status is connected
	go keepaliveToRdc(ctx)

	/*
		Read the channel to monitor the configuration change from UI
		If config change, change the connect status to init and reconnect
		to GDC
	*/
	for {
		select {
		case msg = <-MsgChannel:
			handleMsgFromUi(ctx, msg)

		default:
			status := GetConnStatus()
			if status == AMA_STATUS_ONBOARDING_SUC {
				time.Sleep(5 * time.Second)
			} else {
				time.Sleep(1 * time.Second)
			}
		}
	}
}

/*
	Handling the message from web UI, such as items about GDC change,
	network info change, or license info changes
*/
func handleMsgFromUi(ctx context.Context, message MsgStru) {
	var msg MsgStru = message
	fmt.Println("msg.msgType", msg.MsgType)
	fmt.Println("msg.data", msg.Data)
	log.LoggerWContext(ctx).Info("Receiving event %d", msg.MsgType)
	switch msg.MsgType {
	/*
	   This type handles changes to the following parameters:
	   GDC URL/username/password, and enable the cloud integration
	*/
	case GdcConfigChange:
		updateConnStatus(AMA_STATUS_CONNECING_GDC)
		//to do, get the latest config info
		loopConnect(ctx)
		// To do, handle the result, include GDC auth fail, RDC auth fail, server down

	case NetworkChange:
		updateMsgToRdc(ctx)
	case LicenseInfoChange:

	case Disconnet:
		updateConnStatus(AMA_STATUS_INIT)
	case RdcTokenUpdate:
		connectToRdcWithoutPara(ctx)
	// To do, handle the result,
	case RemoveNodeFromCluster:

	default:
		log.LoggerWContext(ctx).Error("unexpected message")
	}
}

//Sending keepalive packets after onboarding successfully
func keepaliveToRdc(ctx context.Context) {

	// create a ticker for heartbeat
	ticker := time.NewTicker(10 * time.Second)
	timeoutCount = 0

	for _ = range ticker.C {
		/*
			To do, check if disable the connect to cloud, if disable,
			not send the keepalive
		*/

		/*
			check the timeoutCount of keepalive, if hearbeat fails,
			need to re-onboarding
		*/
		if timeoutCount >= KEEPALIVE_TIMEOUT_COUNT_MAX {
			updateConnStatus(AMA_STATUS_CONNECING_RDC)
			result := connectToRdcWithoutPara(ctx)
			if result == 0 {
				updateConnStatus(AMA_STATUS_ONBOARDING_SUC)
				timeoutCount = 0
			} else {
				timeoutCount++
				log.LoggerWContext(ctx).Info(fmt.Sprintf("Keepalive timeout %d", timeoutCount))
				//Onboarding fail, not send keepalive
				continue
			}
		}
		//Check the connect status, if not connected, do nothing
		if GetConnStatus() != AMA_STATUS_ONBOARDING_SUC {
			continue
		}

		log.LoggerWContext(ctx).Info("sending the keepalive")
		request, err := http.NewRequest("GET", "http://10.155.23.116:8008/rest/v1/poll/1234567", nil)
		if err != nil {
			panic(err)
		}

		//Add header option
		request.Header.Add("X-A3-Auth-Token", rdcTokenStr)
		request.Header.Set("Content-Type", "application/json")

		resp, result := client.Do(request)
		if result != nil {
			timeoutCount++
			continue
		}
		timeoutCount = 0
		body, _ := ioutil.ReadAll(resp.Body)
		fmt.Println(string(body))

		//Dispatch the data coming with keepalive reponses
		dispathMsgFromRdc(ctx, []byte(body))
		resp.Body.Close()
	}
}

/*
	Handling the data coming with the keepalive responses, now only
	process the RDC token update messages, there will be configuration
	messages from HM in the future
*/
func dispathMsgFromRdc(ctx context.Context, message []byte) {
	keepAliveResp := make([]KeepAliveResFromRdc, 0)

	err := json.Unmarshal(message, &keepAliveResp)
	if err != nil {
		log.LoggerWContext(ctx).Error("keepaliveToRdc: json Unmarshal fail")
		return
	}

	//go through the slice
	for _, resMsg := range keepAliveResp {
		if resMsg.Data["msgType"] == "amac_token" {
			//RDC token need to write file, if process restart we can read it
			UpdateRdcToken(ctx, resMsg.Data["token"])
			rdcTokenStr = resMsg.Data["token"]
		}
	}
	return
}
