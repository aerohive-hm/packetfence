/*command.go implements handling REST API:
 *	/a3/api/v1/event/command/status
 */
package event

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"


	"github.com/inverse-inc/packetfence/go/ama"
	"github.com/inverse-inc/packetfence/go/ama/amac"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/log"
)

type CommandStatus struct {
	crud.Crud
}


func CommandStatusNew(ctx context.Context) crud.SectionCmd {
	command := new(CommandStatus)
	command.New()
	command.Add("GET", handleGetCommandStatus)
	command.Add("POST", handlePostCommandStatus)
	return command
}


type CommandStatusData struct {
	SetupIsPrimay       bool   `json:"setup_is_primay"`
	SetupStatus         interface{} `json:"setup_status"`
	SetupSyncCounter    int    `json:"setup_sync_counter"`

	AmacCloudEnable   string `josn:"amac_cloud_enable"`
	AmacCloudKeepalive   int `josn:"amac_cloud_keepalive"`
	AmacCloudReportInterval   int `josn:"amac_cloud_report_interval"`
	RecvDBReportCounter           int64   `json:"recvdb_report"`
	RecvDBNodeCounter           int64   `json:"recvdb_node"`
	RecvDBNodeCategoryCounter           int64   `json:"recvdb_node_category"`
	RecvDBLocationlogCounter           int64   `json:"recvdb_locationlog"`
	RecvDBRadacctCounter           int64   `json:"recvdb_radacct"`
	RecvDBClassCounter           int64   `json:"recvdb_class"`
	RecvDBViolationCounter           int64   `json:"recvdb_violation"`
	RecvDBRadauditCounter           int64   `json:"recvdb_radaudit"`
	RecvDBIp4logCounter           int64   `json:"recvdb_ip4log"`
	AmacSendEventCounter          int64   `json:"amac_send_cloud"`
	AmacSendEventSuccessCounter   int64 `json:"amac_send_cloud_success"`
}




// get status of ama
func handleGetCommandStatus(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()

	CommandData := CommandStatusData{}

	
	CommandData.SetupIsPrimay = ama.ClusterStatus.IsPrimary
	CommandData.SetupStatus = ama.ClusterStatus.Status
	CommandData.SetupSyncCounter = ama.ClusterStatus.SyncCounter
	CommandData.AmacCloudEnable = amac.GlobalSwitch
	CommandData.AmacCloudKeepalive = amac.KeepaliveInterval
	CommandData.AmacCloudReportInterval = amac.ReportInterval
	CommandData.RecvDBReportCounter = ReportCounter.recvCounter
	CommandData.RecvDBNodeCounter = ReportCounter.recvCounterNode
	CommandData.RecvDBNodeCategoryCounter = ReportCounter.recvCounterNodeCategory
	CommandData.RecvDBLocationlogCounter = ReportCounter.recvCounterLoationlog
	CommandData.RecvDBRadacctCounter = ReportCounter.recvCounterRadacct
	CommandData.RecvDBClassCounter = ReportCounter.recvCounterClass
	CommandData.RecvDBViolationCounter = ReportCounter.recvCounterViolation
	CommandData.RecvDBRadauditCounter = ReportCounter.recvCounterRadaudit
	CommandData.RecvDBIp4logCounter = ReportCounter.recvCounterIp4log
	CommandData.AmacSendEventCounter = 0
	CommandData.AmacSendEventSuccessCounter = 0

	jsonData, err := json.Marshal(CommandData)
	if err != nil {
		log.LoggerWContext(ctx).Error("command data marshal error:" + err.Error())
		return []byte(err.Error())
	}
	log.LoggerWContext(ctx).Info(fmt.Sprintf("%v", CommandData))
	return jsonData
}

func handlePostCommandStatus(r *http.Request, d crud.HandlerData) []byte {
	var ctx = context.Background()
	code := "ok"
	ret := ""

	log.LoggerWContext(ctx).Info(fmt.Sprintf("receive POST command data %v", d.ReqData))
	//err := json.Unmarshal(d.ReqData, sync)
	//if err != nil {
	//	log.LoggerWContext(ctx).Error(err.Error())
	//	return []byte(err.Error())
	//}	
	code = "fail"
	ret = "NOT support yet"

	return crud.FormPostRely(code, ret)
}

