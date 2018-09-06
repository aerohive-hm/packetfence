/*clusterjoin.go implements handling REST API:
 *	/a3/api/v1/event/cluster/join
 */
package event

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama"
	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/client"
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
func PrepareClusterNodeJoin() {
	utils.ForceNewCluster()
	notifyClusterStartSync()
}

func sendClusterSync(ip, Status string) error {
	ctx := context.Background()
	data := new(SyncData)

	data.Status = Status
	data.Code = "ok"
	data.SendIp = a3share.GetOwnMGTIp()
	url := fmt.Sprintf("https://%s:9999/a3/api/v1/event/cluster/sync", ip)

	log.LoggerWContext(ctx).Info(fmt.Sprintf("post cluster event sync with: %s", url))

	client := new(apibackclient.Client)
	client.Host = ip
	jsonData, err := json.Marshal(&data)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return err
	}
	
	err = client.ClusterSend("POST", url, string(jsonData))

	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
	}
	return err
}

func stopServiceByJoin() error {
	nodeList := a3share.FetchNodesInfo()
	ownMgtIp := a3share.GetOwnMGTIp()
	
	for _, node := range nodeList {
		if node.IpAddr == ownMgtIp {
			continue
		}
		err := sendClusterSync(node.IpAddr, "StopServices")
		if err != nil {
			return err
		}
	}
	return nil
}

func notifyClusterStartSync() error {
	ctx := context.Background()
	nodeList := a3share.FetchNodesInfo()
	ownMgtIp := a3share.GetOwnMGTIp()
	
	for _, node := range nodeList {
		if node.IpAddr == ownMgtIp {
			continue
		}
		err := sendClusterSync(node.IpAddr, "StartSync")
		if err != nil {
			log.LoggerWContext(ctx).Error(fmt.Sprintln(err.Error()))
		}
	}
	return nil
}

func handleUpdateEventClusterJoin(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	clusterData := new(a3config.ClusterEventJoinData)
	var respdata a3config.ClusterEventRespData
	var resp []byte

	err := json.Unmarshal(d.ReqData, clusterData)
	if err != nil {
		goto END
	}

	err = stopServiceByJoin()
	if err != nil {
		log.LoggerWContext(ctx).Info(fmt.Sprintf("post event sync to stopService failed"))
		//goto END
	}

	err, respdata = a3config.UpdateEventClusterJoinData(ctx, *clusterData)
	if err != nil {
		goto END
	}
	resp, _ = json.Marshal(respdata)

	// Prepare for cluster node sync
	ama.InitClusterStatus("primary")
	go PrepareClusterNodeJoin()

END:
	if err != nil {
		return []byte(fmt.Sprintf(`{"code":"fail","msg":"%s"}`, err.Error))
	}
	return resp
}
