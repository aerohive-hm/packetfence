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

type ReportData struct {
	MsgType string        `json:"msgType"`
	Tables  []interface{} `json:"tables"`
}

type ReportMessage struct {
	Header ReportHeader `json:"header"`
	Data   ReportData   `json:"data"`
}

func fillReportHeader(header *ReportHeader) {
	header.Hostname = utils.GetHostname()
	header.SystemID = utils.GetA3SysId()
	header.ClusterID = utils.GetClusterId()
}

//This function will be called by restAPI, it is public
func SendReport(ctx context.Context, data []byte) int {
	reportMsg := ReportMessage{}
	table := ReportTable{}

	log.LoggerWContext(ctx).Info("Into SendReport")

	if asynMsgUrl == "" {
		log.LoggerWContext(ctx).Error("RDC URL is NULL")
		return -1
	}
	/*
	   To do, pop redis queue instead of inputing data
	*/

	err := json.Unmarshal(data, &table.Data)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return -1
	}
	log.LoggerWContext(ctx).Info("print table.Data")
	log.LoggerWContext(ctx).Info(string(table.Data))

	fillReportHeader(&reportMsg.Header)
	reportMsg.Data.MsgType = "a3reportingDB"

	reportMsg.Data.Tables = append(reportMsg.Data.Tables, table.Data)
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
			return 0
		}
	}
}

func reportRoutine(ctx context.Context) {
	log.LoggerWContext(ctx).Info(fmt.Sprintf("read the report interval %d seconds", reportInterval))
	if reportInterval == 0 {
		reportInterval = 30
	}
	// create a ticker for report
	ticker := time.NewTicker(time.Duration(reportInterval) * time.Second)
	failCount := 0

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

		res := SendReport(ctx, []byte("justfortest"))
		if res != 0 {
			failCount++
			log.LoggerWContext(ctx).Error(fmt.Sprintf("Reporting data to cloud fail %d times", failCount))
		} else {
			failCount = 0
		}
	}

}
