/*
	The file is reponsible for reporting to cloud
*/
package amac

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
	"io/ioutil"
	"net/http"
	"time"
)

type ReportHeader struct {
	SystemID  string `json:"systemId"`
	ClusterID string `json:"clusterId"`
	Hostname  string `json:"hostname"`
	MessageID string `json:"messageId"`
}

type ReportTable struct {
	Data json.RawMessage `json:"data"`
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
	header.ClusterID = utils.GetClusterId()
}

func sendReport2Cloud(ctx context.Context, reportMsg interface{}) int {
	message, _ := json.Marshal(reportMsg)
	log.LoggerWContext(ctx).Info(string(message))

	reader := bytes.NewReader(message)
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
			log.LoggerWContext(ctx).Info("Sending report to cloud fail")
			log.LoggerWContext(ctx).Info(err.Error())
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
				log.LoggerWContext(ctx).Error(fmt.Sprintf("Sending message faile, server(RDC) respons the code %d", statusCode))
				return -1
			}
		} else if statusCode == 200 {
			return 0
		} else {
			log.LoggerWContext(ctx).Error(fmt.Sprintf("Sending message faile, server(RDC) respons the code %d", statusCode))
			return -1
		}
	}
}

//This function will be called by restAPI, it is public
func ReportDbTable(ctx context.Context, data []byte) int {
	reportMsg := ReportDbTableMessage{}
	table := ReportTable{}

	log.LoggerWContext(ctx).Info("Into SendReport")

	if asynMsgUrl == "" {
		log.LoggerWContext(ctx).Error("RDC URL is NULL")
		return -1
	}
	/*
	   To do, pop redis queue instead of inputing data
	*/

	//log.LoggerWContext(ctx).Info("print table.Data")
	//log.LoggerWContext(ctx).Info(string(table.Data))

	fillReportHeader(&reportMsg.Header)
	reportMsg.Data.MsgType = "a3-report-db"

	err := json.Unmarshal(data, &table.Data)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return -1
	}
	reportMsg.Data.Tables = append(reportMsg.Data.Tables, table.Data)

	res := sendReport2Cloud(ctx, &reportMsg)
	return res
}

func reportSysInfo(ctx context.Context) int {
	reportMsg := ReportSysInfoMessage{}

	fillReportHeader(&reportMsg.Header)
	reportMsg.Data.MsgType = "a3-report-system-info"

	system := utils.GetCpuMem()
	reportMsg.Data.CpuUsage = int(system.CpuRate)
	reportMsg.Data.MemoryTotal = int(system.MemTotal)
	reportMsg.Data.MemoryUsed = int(system.MemUsed)

	res := sendReport2Cloud(ctx, &reportMsg)
	return res
}
func reportRoutine(ctx context.Context) {
	if reportInterval == 0 {
		reportInterval = 30
	}
	// create a ticker for report
	ticker := time.NewTicker(time.Duration(reportInterval) * time.Second)
	failCount := 0
	log.LoggerWContext(ctx).Info(fmt.Sprintf("read the report interval %d seconds", reportInterval))
	for _ = range ticker.C {
		/*
			check if allow to the connect to cloud, if not,
			not send the report
		*/
		if globalSwitch != "enable" {
			failCount = 0
			continue
		}
		//Check the connect status, if not connected, do nothing
		if GetConnStatus() != AMA_STATUS_ONBOARDING_SUC {
			failCount = 0
			continue
		}

		res := ReportDbTable(ctx, []byte(""))
		if res != 0 {
			failCount++
			log.LoggerWContext(ctx).Error(fmt.Sprintf("Reporting data to cloud fail %d times", failCount))
		} else {
			failCount = 0
		}

		res = reportSysInfo(ctx)
		if res != 0 {
			failCount++
			log.LoggerWContext(ctx).Error(fmt.Sprintf("Reporting data to cloud fail %d times", failCount))
		} else {
			failCount = 0
		}
	}

}
