/*clusterjoin.go implements handling REST API:
 *	/a3/api/v1/event/cluster/join
 */
package event

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"time"

	"github.com/inverse-inc/packetfence/go/ama"
	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/client"
	"github.com/inverse-inc/packetfence/go/ama/database"
	"github.com/inverse-inc/packetfence/go/ama/share"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
)

type Join struct {
	crud.Crud
}

func ClusterJoinNew(ctx context.Context) crud.SectionCmd {
	join := new(Join)
	join.New()
	join.Add("POST", handleUpdateEventClusterJoin)
	return join
}

/*
|-send event/cluster/sync stopservice( rc = ok)
|-`systemctl stop packetfence-mariadb`
|-`pfcmd configreload hard`
|-`bin/pfcmd checkup`
|-`pf-mariadb --force-new-cluster &`
|-send event/cluster/sync start
*/
func prepareClusterNodeJoin() {
	utils.ForceNewCluster()
	a3share.NotifyClusterStatus(a3share.StartSync)
}

func handleUpdateEventClusterJoin(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	clusterData := new(a3config.ClusterNetworksData)
	var respdata a3config.ClusterEventRespData
	var resp []byte
	PrimarySysId := utils.GetA3SysId()
	PrimaryHostname := utils.GetHostname()

	err := json.Unmarshal(d.ReqData, clusterData)
	if err != nil {
		goto END
	}

	if ama.IsClusterJoinMode() {
		err = errors.New("another server is joining the cluster.")
		return []byte(fmt.Sprintf(`{"code":"fail","msg":"%s"}`, err.Error()))
	}
	ama.InitClusterStatus("primary")

	err = a3share.NotifyClusterStatus(a3share.StopService)
	if err != nil {
		log.LoggerWContext(ctx).Info(fmt.Sprintf("post event sync to stopService failed"))
		goto END
	}

	err, respdata = a3config.UpdateEventClusterJoinData(ctx, *clusterData)
	if err != nil {
		goto END
	}
	/*write primary sysid to db*/
	err = amadb.AddSysIdbyHost(PrimarySysId, PrimaryHostname)
	if err != nil {
		log.LoggerWContext(ctx).Error("AddSysIdbyHost error:" + err.Error())
		goto END
	}

	/*write cluster sysid to db*/
	err = amadb.AddSysIdbyHost(clusterData.SysId, clusterData.Hostname)
	if err != nil {
		log.LoggerWContext(ctx).Error("AddSysIdbyHost error:" + err.Error())
		goto END
	}
	resp, _ = json.Marshal(respdata)

	// Prepare for cluster node sync
	go prepareClusterNodeJoin()

END:
	if err != nil {
		ama.ClearClusterStatus()
		return []byte(fmt.Sprintf(`{"code":"fail","msg":"%s"}`, err.Error()))
	}
	return resp
}
func waitPrimarySync(ip string) error {
	ctx := context.Background()
	var msg a3share.SyncData
	url := fmt.Sprintf("https://%s:9999/a3/api/v1/event/cluster/sync", ip)

	client := new(apibackclient.Client)
	client.Host = ip

	for {
		err := client.ClusterSend("GET", url, "")
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			client.Token = "" //clear the token
			time.Sleep(10 * time.Second)
			continue
		}

		err = json.Unmarshal(client.RespData, &msg)
		if err != nil {
			log.LoggerWContext(ctx).Error("Unmarshal error:" + err.Error())
			time.Sleep(10 * time.Second)
			continue
		}
		log.LoggerWContext(ctx).Info(fmt.Sprintf("read sync status=%s from primary %s", msg.Status, msg.SendIp))

		if msg.Status == a3share.StartSync {
			break
		}

		time.Sleep(10 * time.Second)
	}

	return nil
}

func ActiveSyncFromPrimary(ip, user, password string) {
	//wait a moment?
	err := waitPrimarySync(ip)
	if err != nil {
		return
	}
	ctx := context.Background()
	log.LoggerWContext(ctx).Info(fmt.Sprintf("start to sync from primary=%s and restart necessary service", ip))
	utils.SyncFromPrimary(ip, user, password)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("notify to primary with FinishSync and start pf service"))
	utils.ExecShell(utils.A3Root + "/bin/pfcmd service pf start")
	utils.ExecShell(`systemctl restart packetfence-api-frontend`)
	a3share.SendClusterSync(ip, a3share.FinishSync)
	ama.ClearClusterStatus()

	utils.UpdateCurrentlyAt()

}
