//cluster.go implements send event for cluster join and get / update primary cluster.
package a3share

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/inverse-inc/packetfence/go/ama"
	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/client"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
)

const (
	// it's a probe to check if the members are alive.
	NotifySync       = "NotifySync"
	StopService      = "StopServices"
	StartSync        = "StartSync"
	FinishSync       = "FinishSync"
	PrimaryRecovered = "PrimaryRecovered"
	ServerRemoved    = "ServerRemoved"
	UpdateConf       = "UpdateConf"
)

type SyncData struct {
	Code   string `json:"code"`
	Status string `json:"status"`
	SendIp string `json:"ip"`
}

func SendClusterSync(ip, Status string) error {
	data := new(SyncData)

	data.Status = Status
	data.Code = "ok"
	data.SendIp = utils.GetOwnMGTIp()
	url := fmt.Sprintf("https://%s:9999/a3/api/v1/event/cluster/sync", ip)

	log.LoggerWContext(ama.Ctx).Info(fmt.Sprintf("post cluster event sync with: %s", url))

	client := new(apibackclient.Client)
	client.Host = ip
	jsonData, err := json.Marshal(&data)
	if err != nil {
		log.LoggerWContext(ama.Ctx).Error(err.Error())
		return err
	}

	err = client.ClusterSend("POST", url, string(jsonData))

	if err != nil {
		log.LoggerWContext(ama.Ctx).Error(err.Error())
	}

	return err
}

func NotifyClusterStatus(status string) error {
	nodeList := a3config.ClusterNew().FetchNodesInfo()
	ownMgtIp := utils.GetOwnMGTIp()

	counter := 0
	errInfo := ""
	ret := make(chan error)

	for _, node := range nodeList {
		if node.IpAddr == ownMgtIp {
			continue
		}

		go func(ip, status string) {
			if status == NotifySync {
				ama.UpdateClusterNodeStatus(ip, ama.Idle)
			}

			ret <- SendClusterSync(ip, status)
		}(node.IpAddr, status)

		counter++
	}

	for ; counter > 0; counter-- {
		e := <-ret
		if e != nil {
			//log.LoggerWContext(ama.Ctx).Error(fmt.Sprintln(e.Error()))
			errInfo += e.Error() + "\n"
		}
	}

	if len(errInfo) > 0 {
		return errors.New(errInfo)
	}
	return nil
}

func GetPrimaryClusterStatus(ctx context.Context) (error, a3config.ClusterStatusData) {

	url := fmt.Sprintf("https://%s:9999/a3/api/v1/configuration/cluster/status", a3config.ReadClusterPrimary())
	log.LoggerWContext(ctx).Info(fmt.Sprintf("read cluster status data from %s", url))
	clusterstatusData := a3config.ClusterStatusData{}
	client := new(apibackclient.Client)
	client.Host = a3config.ReadClusterPrimary()

	err := client.ClusterSend("GET", url, "")
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return err, clusterstatusData
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("read primary cluster status data:%s",
		string(client.RespData)))

	err = json.Unmarshal(client.RespData, &clusterstatusData)
	if err != nil {
		return err, clusterstatusData
	}

	return err, clusterstatusData

}

func GetPrimaryNetworksData(ctx context.Context) (error, a3config.NetworksData) {

	url := fmt.Sprintf("https://%s:9999/a3/api/v1/configurator/networks", a3config.ReadClusterPrimary())
	log.LoggerWContext(ctx).Info(fmt.Sprintf("read cluster network data from %s", url))
	networkData := a3config.NetworksData{}
	client := new(apibackclient.Client)
	client.Host = a3config.ReadClusterPrimary()

	err := client.ClusterSend("GET", url, "")
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return err, networkData
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("read primary network data:%s",
		string(client.RespData)))

	err = json.Unmarshal(client.RespData, &networkData)
	if err != nil {
		return err, networkData
	}

	return err, networkData

}

// When cluster node join, cluster node information should send to primary node to update
// update data:
//    IP for eth interface of joining node
//    VLAN interface IP address
//    hostname for joining node
func UpdatePrimaryNetworksData(ctx context.Context, clusterData a3config.ClusterNetworksData) (error, a3config.ClusterEventRespData) {
	RespData := a3config.ClusterEventRespData{}
	jsonClusterData, err := json.Marshal(&clusterData)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return err, RespData
	}
	/*check cluset hostname is not same with primary hostname*/
	if a3config.GetPrimaryHostname() == clusterData.Hostname {
		msg := fmt.Sprintf("hostename(%s) can not be the same with Primary hostname(%s).", clusterData.Hostname, a3config.GetPrimaryHostname())
		return errors.New(msg), RespData
	}
	/* check ip and vip is the same net range*/
	err = a3config.CheckItemValid(ctx, true, clusterData.Items)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return err, RespData
	}

	url := fmt.Sprintf("https://%s:9999/a3/api/v1/event/cluster/join", a3config.ReadClusterPrimary())
	log.LoggerWContext(ctx).Info(fmt.Sprintf("post cluster network data to primary with: %s", url))

	client := new(apibackclient.Client)
	client.Host = a3config.ReadClusterPrimary()
	err = client.ClusterSend("POST", url, string(jsonClusterData))
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return err, RespData
	}
	log.LoggerWContext(ctx).Info(fmt.Sprintf("read cluster join event data:%s",
		string(client.RespData)))

	err = json.Unmarshal(client.RespData, &RespData)
	if err != nil {
		log.LoggerWContext(ctx).Error("Unmarshal error:" + err.Error())
		return err, RespData
	}

	if RespData.Code != "ok" {
		err = errors.New(RespData.Msg)
		return err, RespData
	}

	return err, RespData
}
