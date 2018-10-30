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
	"github.com/inverse-inc/packetfence/go/ama/database"
	"github.com/inverse-inc/packetfence/go/ama/a3config"

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
	MariadbHealth            = "MariadbHealth"
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
	DBIsHealthy     bool
	DBState         string
	IpAddr          string 
	ReadGrastated   bool  //read once time during DB failed state
	GrastateSeqno   int64
	SafeToBootstrap int
	MyUUID    string
	ViewID    string
	OtherNode []MariadbNodeInfo 
}

type PostDbStatusData struct {
	Code   string `json:"code"`
	State  string `json:"state"`
	SendIp string `json:"ip"`
}

var MariadbStatusData MariadbRecoveryData
var ctx = context.Background()

func ResetGrastateData() {

	MariadbStatusData.SafeToBootstrap = 0
	MariadbStatusData.GrastateSeqno = -1
	MariadbStatusData.ReadGrastated = false
	MariadbStatusData.MyUUID = ""
	MariadbStatusData.ViewID = ""

	utils.ExecShell(`rm -fr /var/lib/mysql/grastate.dat.bak`, true)
}


func GetMyMariadbRecoveryData() {
	var result string

	MariadbStatusData.IpAddr = utils.GetOwnMGTIp()

	//pf-mariadb generate grastate.dat.bak, don't change the login now, might not need to generate grastate.dat.bak file
	//if grastate.dat.bak exist, the node should think itself is safe to bootstrap
	
	if utils.IsFileExist("/var/lib/mysql/grastate.dat.bak") {
			result, _ = utils.ExecShell(`sed -n '/safe_to_bootstrap:/ p' /var/lib/mysql/grastate.dat.bak | sed -r 's/\s*safe_to_bootstrap:\s*//'`, false)
			result = strings.TrimRight(result, "\n")
			MariadbStatusData.SafeToBootstrap, _ = strconv.Atoi(result)
			result, _ = utils.ExecShell(`sed -n '/seqno:/ p' /var/lib/mysql/grastate.dat.bak | sed -r 's/\s*seqno:\s*//'`, false)
			result = strings.TrimRight(result, "\n")
			MariadbStatusData.GrastateSeqno, _ = strconv.ParseInt(result, 10, 64)
			utils.ExecShell(`rm -fr /var/lib/mysql/grastate.dat.bak`, true)
	} else {
			result, _ = utils.ExecShell(`sed -n '/safe_to_bootstrap:/ p' /var/lib/mysql/grastate.dat | sed -r 's/\s*safe_to_bootstrap:\s*//'`, false)
			result = strings.TrimRight(result, "\n")
			MariadbStatusData.SafeToBootstrap, _ = strconv.Atoi(result)
			result, _ = utils.ExecShell(`sed -n '/seqno:/ p' /var/lib/mysql/grastate.dat | sed -r 's/\s*seqno:\s*//'`, false)
			result = strings.TrimRight(result, "\n")
			MariadbStatusData.GrastateSeqno, _ = strconv.ParseInt(result, 10, 64)
	}
	MariadbStatusData.ReadGrastated = true
	

	result, _ = utils.ExecShell(`sed -n '/my_uuid:/ p' /var/lib/mysql/gvwstate.dat | sed -r 's/^.*my_uuid:\s*//'`, false)
	result = strings.TrimRight(result, "\n")
	MariadbStatusData.MyUUID = result
	result, _ = utils.ExecShell(`sed -n '/view_id:/ p' /var/lib/mysql/gvwstate.dat | sed -r 's/^.*view_id:\s*[0-9]*\s*//;s/\s*[0-9]*\s*$//'`, false)
	result = strings.TrimRight(result, "\n")
	MariadbStatusData.ViewID = result
	

	return
}


func ClusterNodesCnt() int {
	nodes := a3config.ClusterNew().FetchNodesInfo()
	total := 0
	for _, _ = range nodes {
		total++		
	}

	return total
}

// Query DB status
func MariadbIsActive() bool {	
	result := amadb.QueryDBPrimaryStatus()
	if len(result) == 0 {
		return false
	} 

	if !MariadbStatusData.DBIsHealthy {
		log.LoggerWContext(ctx).Info(result)
	}

	if !a3config.ClusterNew().CheckClusterEnable() {
		return true
	}

	if !strings.Contains(result, "non-Primary") && strings.Contains(result, "Primary") {
		return true
	} 

	if strings.Contains(result, "Disconnected") && ClusterNodesCnt() == 1 {		
		return true
	}

	return false
}


// Query DB status
func MariadbIsNonPrimary() bool {	
	result := amadb.QueryDBPrimaryStatus()
	if len(result) == 0 {
		return false
	} 

	if !a3config.ClusterNew().CheckClusterEnable() {
		return false
	}

	if strings.Contains(result, "non-Primary") {
		return true
	} 
	return false
}


// get status of primary server
func handleGetDBStatus(r *http.Request, d crud.HandlerData) []byte {
	MyInfo := MariadbNodeInfo{}

	GetMyMariadbRecoveryData()

	MyInfo.IpAddr = utils.GetOwnMGTIp()
	if MariadbIsActive() {
		MariadbStatusData.DBState = MariadbGood
	} else {
		MariadbStatusData.DBState = MariadbFail
	}
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

func ShutdownMariadb() {
	//gracefully shutdown mariadb, If it is possible to shutdown fail, find reason instead of kill with SIGKILL.
	log.LoggerWContext(ctx).Info(fmt.Sprintf("AMA trying to shut down MariaDB!!!"))
	utils.KillMariaDB()
	log.LoggerWContext(ctx).Info(fmt.Sprintf("AMA shut down MariaDB!!!"))
}

func ModifygrastateFileSafeToBootstrap() {
	utils.ExecShell(`sed -i 's/^safe_to_bootstrap.*$/safe_to_bootstrap: 1/' /var/lib/mysql/grastate.dat`, true)
	MariadbStatusData.SafeToBootstrap = 1
	log.LoggerWContext(ctx).Info(fmt.Sprintf("AMA modify safe_to_bootstrap=1 for /var/lib/mysql/grastate.dat!!!"))
}

func ModifygrastateFileNotSafeToBootstrap() {
	utils.ExecShell(`sed -i 's/^safe_to_bootstrap.*$/safe_to_bootstrap: 0/' /var/lib/mysql/grastate.dat`, true)
	MariadbStatusData.SafeToBootstrap = 0
	log.LoggerWContext(ctx).Info(fmt.Sprintf("AMA modify safe_to_bootstrap=0 for /var/lib/mysql/grastate.dat!!!"))
}



func RecoveryStartedMariadb() {
	utils.ExecShell(`systemctl start packetfence-mariadb.service`, true)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("AMA started MariaDB!!!"))
}



func RestartMariadb(safeToBootstrap bool) {
	ShutdownMariadb()
	if safeToBootstrap {
		ModifygrastateFileSafeToBootstrap()
	} else {
		ModifygrastateFileNotSafeToBootstrap()
	}
	RecoveryStartedMariadb()
}

func handleUpdateDBStatus(r *http.Request, d crud.HandlerData) []byte {
	statusData := new(PostDbStatusData)
	code := "ok"
	ret := ""

	err := json.Unmarshal(d.ReqData, statusData)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return []byte(err.Error())
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("receive MariaDB state %s from %s", statusData.State, statusData.SendIp))
	switch {
	case statusData.State == "StopYourDB":
		ShutdownMariadb()
	case statusData.State == "YouAreNotSafeToBootstrap":
		RestartMariadb(false)		
	default:
		code = "fail"
		ret = "Unkown status."
	}

	return crud.FormPostRely(code, ret)
}

