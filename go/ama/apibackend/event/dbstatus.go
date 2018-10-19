// dbstatus.go handling REST API
// /a3/api/v1/event/cluster/dbstatus
package event


import (
	"context"
	"fmt"
	"encoding/json"
	"net/http"
	"strconv"
	"strings"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/log"
	"github.com/inverse-inc/packetfence/go/ama/utils"

)



type DBstatus struct {
	crud.Crud
}

func ClusterDBStatusNew(ctx context.Context) crud.SectionCmd {
	db := new(DBstatus)
	db.New()
	db.Add("GET", handleGetDBStatus)
	db.Add("POST", handleUpdateDBStatus)
	return db
}

// For Mariadb Galera cluster recovery
const (
	MysqlGrastateFile  = "/var/lib/mysql/grastate.dat"
	MysqlGvwstateFile  = "/var/lib/mysql/gvwstate.dat"
	MariadbGood              = "MariadbGood"
	MariadbFail              = "MariadbFail"
)

type MariadbNodeInfo struct {
	IpAddr          string `json:"ipaddr"`
	DBState         string `json:"dbstate"`
	GrastateSeqno   int64 `json:"grastate_seqno"`
	SafeToBootstrap int    `json:"safe_to_bootstrap"`
	MyUUID    string       `json:"myuuid"`
	ViewID    string       `json:"viewid"`	
}

type MariadbRecoveryData struct {
	DBState         string
	IpAddr          string 
	GrastateSeqno   int64
	SafeToBootstrap int
	MyUUID    string
	ViewID    string
	OtherNode []MariadbNodeInfo 
}



var MariadbStatusData MariadbRecoveryData


func GetMyMariadbRecoveryData() {
	var result string
	ctx := context.Background()

	MariadbStatusData.IpAddr = utils.GetOwnMGTIp()

	if utils.IsFileExist("/var/lib/mysql/grastate.dat.bak") {
		result, _ = utils.ExecShell(`sed -n '/safe_to_bootstrap:/ p' /var/lib/mysql/grastate.dat.bak | sed -r 's/\s*safe_to_bootstrap:\s*//'`)
		result = strings.TrimRight(result, "\n")
		MariadbStatusData.SafeToBootstrap, _ = strconv.Atoi(result)
		result, _ = utils.ExecShell(`sed -n '/seqno:/ p' /var/lib/mysql/grastate.dat.bak | sed -r 's/\s*seqno:\s*//'`)
		result = strings.TrimRight(result, "\n")
		MariadbStatusData.GrastateSeqno, _ = strconv.ParseInt(result, 10, 64)
	} else {
		result, _ = utils.ExecShell(`sed -n '/safe_to_bootstrap:/ p' /var/lib/mysql/grastate.dat | sed -r 's/\s*safe_to_bootstrap:\s*//'`)
		result = strings.TrimRight(result, "\n")
		MariadbStatusData.SafeToBootstrap, _ = strconv.Atoi(result)
		result, _ = utils.ExecShell(`sed -n '/seqno:/ p' /var/lib/mysql/grastate.dat | sed -r 's/\s*seqno:\s*//'`)
		result = strings.TrimRight(result, "\n")
		MariadbStatusData.GrastateSeqno, _ = strconv.ParseInt(result, 10, 64)
	}

	

	result, _ = utils.ExecShell(`sed -n '/my_uuid:/ p' /var/lib/mysql/gvwstate.dat | sed -r 's/^.*my_uuid:\s*//'`)
	result = strings.TrimRight(result, "\n")
	MariadbStatusData.MyUUID = result
	result, _ = utils.ExecShell(`sed -n '/view_id:/ p' /var/lib/mysql/gvwstate.dat | sed -r 's/^.*view_id:\s*[0-9]\s*//;s/\s*[0-9]\s*\n$//'`)
	result = strings.TrimRight(result, "\n")
	MariadbStatusData.ViewID = result
	log.LoggerWContext(ctx).Info(fmt.Sprintf("My storemariadb recovery data %v", MariadbStatusData))

	return
}

// get status of primary server
func handleGetDBStatus(r *http.Request, d crud.HandlerData) []byte {
	var ctx = context.Background()
	MyInfo := MariadbNodeInfo{}

	GetMyMariadbRecoveryData()

	MyInfo.IpAddr = utils.GetOwnMGTIp()
	MyInfo.DBState = MariadbStatusData.DBState
	MyInfo.GrastateSeqno = MariadbStatusData.GrastateSeqno
	MyInfo.SafeToBootstrap = MariadbStatusData.SafeToBootstrap
	MyInfo.MyUUID = MariadbStatusData.MyUUID
	MyInfo.ViewID = MariadbStatusData.ViewID
	
	jsonData, err := json.Marshal(MyInfo)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return []byte(err.Error())
	}
	return jsonData
}

func handleUpdateDBStatus(r *http.Request, d crud.HandlerData) []byte {
	var ctx = context.Background()
	OtherNodeInfo := new(MariadbNodeInfo)
	code := "ok"
	ret := ""

	err := json.Unmarshal(d.ReqData, OtherNodeInfo)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return []byte(err.Error())
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("receive mariadb status information from %s", OtherNodeInfo.IpAddr))
	

	return crud.FormPostRely(code, ret)
}

