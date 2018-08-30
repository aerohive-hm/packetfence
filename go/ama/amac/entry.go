/*
	The file implements the following functions:
	1) start the front end component damon
	2) try to connect RDC using the current RDC token
 	3) monitorinig the message from UI and other nodes
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
	GdcConfigChange         = 1
	NetworkChange           = 2
	LicenseInfoChange       = 3
	DisableCloudIntegration = 4
	RdcTokenUpdate          = 5
	RemoveNodeFromCluster   = 6
	JoinClusterComplete     = 7
)
const KEEPALIVE_TIMEOUT_COUNT_MAX = 3

var (
	ama_connect_status = AMA_STATUS_INIT
	m                  = new(sync.RWMutex)
	timeoutCount       uint64
	//create channel to store messages from UI
	MsgChannel      = make(chan MsgStru, 4096)
	LastConnectTime A3Time
)

type A3Time struct {
	time time.Time
	mu   sync.RWMutex
}

func updateLastConTime() {
	LastConnectTime.mu.Lock()
	LastConnectTime.time = time.Now()
	LastConnectTime.mu.Unlock()
}

func ReadLastConTime() time.Time {
	LastConnectTime.mu.RLock()
	time := LastConnectTime.time
	LastConnectTime.mu.RUnlock()
	return time
}

func GetAMAConnStatus() string {
	var str string
	switch ama_connect_status {
	case AMA_STATUS_INIT:
		str = "Init status"
	case AMA_STATUS_CONNECING_GDC:
		str = "Connecting GDC"
	case AMA_STATUS_CONNECING_RDC:
		str = "Connecting RDC"
	case AMA_STATUS_ONBOARDING_SUC:
		str = "Connected"
	default:
		str = "Unknow"
	}
	return str
}

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
	Header tokenCommonHeader `json:"header"`
	Data   map[string]string `json:"data"`
}

func updateConnStatus(status int) {
	m.Lock()
	ama_connect_status = status
	m.Unlock()
	if status == AMA_STATUS_ONBOARDING_SUC {
		updateLastConTime()
	}
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
	if globalSwitch == "enable" {
		//trying to connect to the cloud when damon start
		result := connectToRdcWithoutPara(ctx)
		if result != 0 {
			log.LoggerWContext(ctx).Info("Connect to cloud fail, waiting events from UI or other nodes")
		} else {
			log.LoggerWContext(ctx).Info("Connect to cloud successfully")
		}
	} else {
		log.LoggerWContext(ctx).Info("Cloud integration is disable, waiting events from UI or other nodes")
	}

	//loopConnect(ctx)
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
	log.LoggerWContext(ctx).Info(fmt.Sprintf("Receiving event %d, data:%s", msg.MsgType, msg.Data))
	switch msg.MsgType {
	/*
	   This type handles changes to the following parameters:
	   GDC URL/username/password, and enable the cloud integration
	*/
	case GdcConfigChange:

	case NetworkChange:
		updateMsgToRdcAsyn(ctx, NetworkChange)

	case LicenseInfoChange:
		updateMsgToRdcAsyn(ctx, LicenseInfoChange)

	case DisableCloudIntegration:
		updateConnStatus(AMA_STATUS_INIT)
		globalSwitch = "disable"

	case RdcTokenUpdate:
		//To do, set the globalswitch to enable
		connectToRdcWithoutPara(ctx)

	case RemoveNodeFromCluster:
		UpdateMsgToRdcSyn(ctx, RemoveNodeFromCluster)

	case JoinClusterComplete:
		//Read the conf file and install RDC URL
		_ = update("")
		if globalSwitch == "enable" {
			connectToRdcWithoutPara(ctx)
		}

	default:
		log.LoggerWContext(ctx).Error("unexpected message")
	}
}

//Sending keepalive packets after onboarding successfully
func keepaliveToRdc(ctx context.Context) {

	log.LoggerWContext(ctx).Info(fmt.Sprintf("read the keepalive interval %d seconds", keepaliveInterval))
	// create a ticker for heartbeat
	if keepaliveInterval == 0 {
		keepaliveInterval = 30
	}
	ticker := time.NewTicker(time.Duration(keepaliveInterval) * time.Second)
	timeoutCount = 0

	for _ = range ticker.C {
		/*
			check if allow to the connect to cloud, if not,
			not send the keepalive
		*/
		if globalSwitch != "enable" {
			timeoutCount = 0
			continue
		}
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
		//url := fmt.Sprintf("http://10.155.23.116:8008/rest/v1/poll/%s", utils.GetA3SysId())
		request, err := http.NewRequest("GET", keepAliveUrl, nil)
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
		}

		//Add header option
		request.Header.Add("Authorization", rdcTokenStr)
		request.Header.Set("Content-Type", "application/json")

		resp, result := client.Do(request)
		if result != nil {
			timeoutCount++
			continue
		}
		timeoutCount = 0
		body, _ := ioutil.ReadAll(resp.Body)
		log.LoggerWContext(ctx).Info(string(body))

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
			dst := fmt.Sprintf("Bearer %s", resMsg.Data["token"])
			UpdateRdcToken(ctx, dst)
			rdcTokenStr = resMsg.Data["token"]
		}
	}
	return
}
