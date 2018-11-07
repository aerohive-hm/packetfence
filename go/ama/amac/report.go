/*
	The file is reponsible for reporting to cloud
*/
package amac

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"github.com/inverse-inc/packetfence/go/ama/cache"
	"github.com/inverse-inc/packetfence/go/ama/report"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/log"
	"io/ioutil"
	"net/http"
	"time"
	//"strconv"
)

const (
	CacheTableUpLimit = 30
)

var AmacSendEventCounter int64 = 0
var AmacSendEventSuccessCounter int64 = 0

type ReportHeader struct {
	SystemID  string `json:"systemId"`
	ClusterID string `json:"clusterId"`
	Hostname  string `json:"hostname"`
	MessageID string `json:"messageId"`
}

type ReportTable struct {
	Ah_tablename string `json:"ah_tablename"`
	//Data json.RawMessage `json:"data"`
}

type ReportDbTableData struct {
	MsgType string        `json:"msgType"`
	Tables  []interface{} `json:"tables"`
}

type ReportDbTableMessage struct {
	Header ReportHeader      `json:"header"`
	Data   ReportDbTableData `json:"data"`
}

type ReportSysInfoData struct {
	MsgType     string `json:"msgType"`
	CpuUsage    int    `json:"cpuUsage"`
	MemoryTotal int    `json:"memoryTotal"`
	MemoryUsed  int    `json:"memoryUsed"`
}

type ReportSysInfoMessage struct {
	Header ReportHeader      `json:"header"`
	Data   ReportSysInfoData `json:"data"`
}

func fillReportHeader(header *ReportHeader) {
	header.Hostname = utils.GetHostname()
	header.SystemID = utils.GetA3SysId()
	header.ClusterID = a3config.GetClusterId()
}

func sendReport2Cloud(ctx context.Context, reportMsg []interface{}) int {
	if asynMsgUrl == "" {
		log.LoggerWContext(ctx).Error("RDC URL is NULL")
		return -1
	}
	message, _ := json.Marshal(reportMsg)
	log.LoggerWContext(ctx).Debug("into sendReport2Cloud and print Marshal result")
	log.LoggerWContext(ctx).Debug(string(message))

	reader := bytes.NewReader(message)
	for {
		request, err := http.NewRequest("POST", asynMsgUrl, reader)
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			return -1
		}
		AmacSendEventCounter++
		//Add header option, the tokenStr is from RDC now
		request.Header.Add("Authorization", rdcTokenStr)
		request.Header.Set("Content-Type", "application/json")
		resp, err := client.Do(request)
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			return -1
		}
		AmacSendEventSuccessCounter++
		body, _ := ioutil.ReadAll(resp.Body)
		log.LoggerWContext(ctx).Debug(fmt.Sprintf("receive the response %d", resp.StatusCode))
		log.LoggerWContext(ctx).Debug(string(body))
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
				log.LoggerWContext(ctx).Error(fmt.Sprintf("Sending report failed, server(RDC) respons the code %d, RDC token:%s", statusCode, rdcTokenStr))
				return -1
			}
		} else if statusCode == 200 {
			return 0
		} else {
			log.LoggerWContext(ctx).Error(fmt.Sprintf("Sending report failed, server(RDC) respons the code %d", statusCode))
			return -1
		}
	}
}

func pushNodeCateActively(ctx context.Context) {
	reportArray := make([]interface{}, 0)
	reportMsg := ReportDbTableMessage{}

	fillReportHeader(&reportMsg.Header)
	reportMsg.Data.MsgType = "a3-report-db"

	reportMsg.Data.Tables = report.PopAllNodeCategary(ctx)

	reportArray = append(reportArray, reportMsg)
	log.LoggerWContext(ctx).Info("Push node category table to cloud after onboarding successfully")
	res := sendReport2Cloud(ctx, reportArray)
	if res != 0 {
		log.LoggerWContext(ctx).Error("Push node category table to cloud fail")
		return
	} else {
		return
	}
}

func radAcctFieldHandle(t *report.RadacctParseStruct) report.RadacctParseStruct {
	t.TimeStamp = fmt.Sprintf("%d", time.Now().UTC().UnixNano()*1000/(int64(time.Millisecond)))
	t.AcctInputOcts = t.AcctInputOcts + t.Acctinputgigawords<<32
	t.Acctinputgigawords = 0
	t.AcctOutputOcts = t.AcctOutputOcts + t.Acctoutputgigawords<<32
	t.Acctoutputgigawords = 0
	switch t.AcctStatusType {
	case "Start":
		t.AcctStopTime = ""
		t.AcctUpdateTime = ""
	case "Interim-Update":
		t.AcctStartTime = ""
		t.AcctStopTime = ""
	case "Stop":
		t.AcctStartTime = ""
		t.AcctUpdateTime = ""
	case "Interim-Update-Username":
		//do nothing
	}

	/*
		If serviceType eq Call-Check, the username will be MAC address
		Which from the MAC authen, the radacc-update packet will overwrite
		the username of portal authentication. If ServiceType is Framed-User
		means this is a 802.1X username, we should push this info to cloud.
	*/
	if t.ServiceType == "Call-Check" {
		t.UserName = ""
	}

	return *t
}

//This function will be called by restAPI, it is public
func ReportDbTable(ctx context.Context, sendFlag bool) (interface{}, int) {
	reportMsg := ReportDbTableMessage{}
	table := ReportTable{}
	var temp interface{}

	log.LoggerWContext(ctx).Debug(fmt.Sprintf("Into ReportDbTable, sendFlag %t,CacheTableUpLimit %d", sendFlag, CacheTableUpLimit))

	//Check the connect status, if not connected, do nothing
	if GetConnStatus() != AMA_STATUS_ONBOARDING_SUC {
		return nil, 0
	}

	msgQue, err := cache.FetchTablesInfoInOrder(CacheTableUpLimit)
	if err != nil {
		log.LoggerWContext(ctx).Error("Fetch table message fail")
		return nil, -1
	}
	if len(msgQue) == 0 {
		log.LoggerWContext(ctx).Debug("msgQue len is 0, no DB messages")
		return nil, 0
	}
	log.LoggerWContext(ctx).Debug(fmt.Sprintf("get %d messages from msgQue", len(msgQue)))

	fillReportHeader(&reportMsg.Header)
	reportMsg.Data.MsgType = "a3-report-db"

	for _, singleMsg := range msgQue {
		table.Ah_tablename = ""
		err := json.Unmarshal(singleMsg.([]byte), &table)
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			return nil, -1
		}
		switch table.Ah_tablename {
		case "node":
			var t report.NodeParseStruct
			err = json.Unmarshal(singleMsg.([]byte), &t)
			//log.LoggerWContext(ctx).Error(fmt.Sprintf("t: %+v", t))
			temp = t
		case "node_category":
			var t report.NodecategoryParseStruct
			err = json.Unmarshal(singleMsg.([]byte), &t)
			t.CategoryID = report.GetNodeCateId(ctx, t.Name)
			//log.LoggerWContext(ctx).Error(fmt.Sprintf("t: %+v", t))
			temp = t
		case "violation":
			var t report.ViolationParseStruct
			err = json.Unmarshal(singleMsg.([]byte), &t)
			//log.LoggerWContext(ctx).Error(fmt.Sprintf("t: %+v", t))
			temp = t
		case "locationlog":
			var t report.LocationlogParseStruct
			err = json.Unmarshal(singleMsg.([]byte), &t)
			//log.LoggerWContext(ctx).Error(fmt.Sprintf("t: %+v", t))
			temp = t
		case "ip4log":
			var t report.Ip4logParseStruct
			err = json.Unmarshal(singleMsg.([]byte), &t)
			//log.LoggerWContext(ctx).Error(fmt.Sprintf("t: %+v", t))
			temp = t
		case "radius_audit_log":
			var t report.RadauditParseStruct
			err = json.Unmarshal(singleMsg.([]byte), &t)
			if t.AuthStatus == "allow" {
				t.AuthStatus = "Accept"
			} else {
				t.AuthStatus = "Reject"
			}
			t.TimeStamp = fmt.Sprintf("%d", time.Now().UTC().UnixNano()/(int64(time.Millisecond)*1000))
			temp = t
		case "radacct":
			var t report.RadacctParseStruct
			err = json.Unmarshal(singleMsg.([]byte), &t)
			/*
				if t.AcctStatusType == "Stop" || t.AcctStatusType == "Start" {
					log.LoggerWContext(ctx).Error("8888888888Receiving STOP/Start message")
				}
			*/
			t = radAcctFieldHandle(&t)
			//log.LoggerWContext(ctx).Error(fmt.Sprintf("t: %+v", t))
			temp = t
		default:
			log.LoggerWContext(ctx).Debug("unknown table, skip")
			continue
		}

		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			return nil, -1
		}
		reportMsg.Data.Tables = append(reportMsg.Data.Tables, temp)
	}

	//sendFlag is true, means the cache table up to the limit
	if sendFlag {
		reportArray := make([]interface{}, 0)
		reportArray = append(reportArray, reportMsg)

		res := sendReport2Cloud(ctx, reportArray)
		if res != 0 {
			log.LoggerWContext(ctx).Error("Sending report messages to cloud failed when the cache table overflow")
			return nil, -1
		} else {
			return nil, 0
		}
	} else {
		return reportMsg, 0
	}
}

func reportSysInfo(ctx context.Context) (interface{}, int) {
	reportMsg := ReportSysInfoMessage{}

	fillReportHeader(&reportMsg.Header)
	reportMsg.Data.MsgType = "a3-report-system-info"

	system := utils.GetCpuMem()
	reportMsg.Data.CpuUsage = int(system.CpuRate)
	reportMsg.Data.MemoryTotal = int(system.MemTotal)
	reportMsg.Data.MemoryUsed = int(system.MemUsed)

	//reportArray := make([]ReportSysInfoMessage, 0)
	//reportArray = append(reportArray, reportMsg)
	//_ = sendReport2Cloud(ctx, reportArray)
	return reportMsg, 0
}
func reportRoutine(ctx context.Context) {
	if ReportInterval == 0 {
		ReportInterval = 30
	}
	// create a ticker for report
	ticker := time.NewTicker(time.Duration(ReportInterval) * time.Second)
	failCount := 0
	log.LoggerWContext(ctx).Info(fmt.Sprintf("read the report interval %d seconds", ReportInterval))
	for _ = range ticker.C {
		/*
			check if allow to the connect to cloud, if not,
			not send the report
		*/
		if GlobalSwitch != "enable" {
			failCount = 0
			continue
		}
		//Check the connect status, if not connected, do nothing
		if GetConnStatus() != AMA_STATUS_ONBOARDING_SUC {
			failCount = 0
			continue
		}
		reportArray := make([]interface{}, 0)
		dbMsg, resDb := ReportDbTable(ctx, false)
		if resDb != 0 {
			log.LoggerWContext(ctx).Error("Reporting DB data to cloud failed")
		} else {
			if dbMsg != nil {
				reportArray = append(reportArray, dbMsg)
			}
		}

		sysMsg, resSys := reportSysInfo(ctx)
		if resSys != 0 {
			log.LoggerWContext(ctx).Error("Reporting system data to cloud failed")
		} else {
			if sysMsg != nil {
				reportArray = append(reportArray, sysMsg)
			}
		}
		res := sendReport2Cloud(ctx, reportArray)
		if res != 0 {
			failCount++
			log.LoggerWContext(ctx).Error(fmt.Sprintf("Sending report data to cloud fail times: %d", failCount))
		}
	}
}
