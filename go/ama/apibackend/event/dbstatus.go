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

	utils.ExecShell(`rm -fr /var/lib/mysql/grastate.dat.bak`)
}


func GetMyMariadbRecoveryData() {
	var result string

	MariadbStatusData.IpAddr = utils.GetOwnMGTIp()

	//pf-mariadb generate grastate.dat.bak, don't change the login now, might not need to generate grastate.dat.bak file
	//if grastate.dat.bak exist, the node should think itself is safe to bootstrap
	
	if utils.IsFileExist("/var/lib/mysql/grastate.dat.bak") {
			result, _ = utils.ExecShell(`sed -n '/safe_to_bootstrap:/ p' /var/lib/mysql/grastate.dat.bak | sed -r 's/\s*safe_to_bootstrap:\s*//'`)
			result = strings.TrimRight(result, "\n")
			MariadbStatusData.SafeToBootstrap, _ = strconv.Atoi(result)
			result, _ = utils.ExecShell(`sed -n '/seqno:/ p' /var/lib/mysql/grastate.dat.bak | sed -r 's/\s*seqno:\s*//'`)
			result = strings.TrimRight(result, "\n")
			MariadbStatusData.GrastateSeqno, _ = strconv.ParseInt(result, 10, 64)
			utils.ExecShell(`rm -fr /var/lib/mysql/grastate.dat.bak`)
	} else {
			result, _ = utils.ExecShell(`sed -n '/safe_to_bootstrap:/ p' /var/lib/mysql/grastate.dat | sed -r 's/\s*safe_to_bootstrap:\s*//'`)
			result = strings.TrimRight(result, "\n")
			MariadbStatusData.SafeToBootstrap, _ = strconv.Atoi(result)
			result, _ = utils.ExecShell(`sed -n '/seqno:/ p' /var/lib/mysql/grastate.dat | sed -r 's/\s*seqno:\s*//'`)
			result = strings.TrimRight(result, "\n")
			MariadbStatusData.GrastateSeqno, _ = strconv.ParseInt(result, 10, 64)
	}
	MariadbStatusData.ReadGrastated = true
	

	result, _ = utils.ExecShell(`sed -n '/my_uuid:/ p' /var/lib/mysql/gvwstate.dat | sed -r 's/^.*my_uuid:\s*//'`)
	result = strings.TrimRight(result, "\n")
	MariadbStatusData.MyUUID = result
	result, _ = utils.ExecShell(`sed -n '/view_id:/ p' /var/lib/mysql/gvwstate.dat | sed -r 's/^.*view_id:\s*[0-9]*\s*//;s/\s*[0-9]*\s*$//'`)
	result = strings.TrimRight(result, "\n")
	MariadbStatusData.ViewID = result
	log.LoggerWContext(ctx).Info(fmt.Sprintf("My store mariadb recovery data %v", MariadbStatusData))

	return
}

// Query DB status
func MariadbIsActive() bool {	
	result := amadb.QueryDBPrimaryStatus()
	if len(result) == 0 {
		return false
	} 

	if !a3config.ClusterNew().CheckClusterEnable() {
		return true
	}

	if strings.Contains(result, "Primary") {
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

func KillMysqld() {
	utils.ExecShell(`(ps -ef | grep mysqld | grep -v grep | awk '{print $2}' | xargs kill -9) &>/dev/null`)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("AMA Killed Mariadb!!!"))
}

func ModifygrastateFileSafeToBootstrap() {
	utils.ExecShell(`sed -i 's/^safe_to_bootstrap.*$/safe_to_bootstrap: 1/' /var/lib/mysql/grastate.dat`)
	MariadbStatusData.SafeToBootstrap = 1
	log.LoggerWContext(ctx).Info(fmt.Sprintf("AMA modify safe_to_bootstrap=1 for /var/lib/mysql/grastate.dat!!!"))
}

func ModifygrastateFileNotSafeToBootstrap() {
	utils.ExecShell(`sed -i 's/^safe_to_bootstrap.*$/safe_to_bootstrap: 0/' /var/lib/mysql/grastate.dat`)
	MariadbStatusData.SafeToBootstrap = 0
	log.LoggerWContext(ctx).Info(fmt.Sprintf("AMA modify safe_to_bootstrap=0 for /var/lib/mysql/grastate.dat!!!"))
}



func RecoveryStartedMariadb() {
	utils.ExecShell(`systemctl start packetfence-mariadb.service`)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("AMA Starting Mariadb!!!"))
}



func RestartMariadb(safeToBootstrap bool) {
	KillMysqld()
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

	log.LoggerWContext(ctx).Info(fmt.Sprintf("receive mariadb state %s from %s", statusData.State, statusData.SendIp))
	switch {
	case statusData.State == "StopYourDB":
		KillMysqld()
	case statusData.State == "YouAreNotSafeToBootstrap":
		RestartMariadb(false)		
	default:
		code = "fail"
		ret = "Unkown status."
	}

	return crud.FormPostRely(code, ret)
}

