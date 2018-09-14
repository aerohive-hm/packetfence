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
	ctx := context.Background()
	data := new(SyncData)

	data.Status = Status
	data.Code = "ok"
	data.SendIp = utils.GetOwnMGTIp()
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

func NotifyClusterStatus(status string) error {
	ctx := context.Background()
	nodeList := a3config.ClusterNew().FetchNodesInfo()
	ownMgtIp := utils.GetOwnMGTIp()

	for _, node := range nodeList {
		if node.IpAddr == ownMgtIp {
			continue
		}

		ama.UpdateClusterNodeStatus(node.IpAddr, ama.Idle)
		err := SendClusterSync(node.IpAddr, status)
		if err != nil {
			log.LoggerWContext(ctx).Error(fmt.Sprintln(err.Error()))
		}
	}

	return nil
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

func UpdatePrimaryNetworksData(ctx context.Context, clusterData a3config.ClusterNetworksData) (error, a3config.ClusterEventRespData) {
	RespData := a3config.ClusterEventRespData{}
	jsonClusterData, err := json.Marshal(&clusterData)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return err, RespData
	}
	/*check cluset hostname is not same with primary hostname*/
	if a3config.GetPrimaryHostname() == clusterData.HostName {
		msg := fmt.Sprintf("hostename(%s) can not be the same with Primary hostname(%s).", clusterData.HostName, a3config.GetPrimaryHostname())
		return errors.New(msg), RespData
	}
	/* check ip and vip is the same net range*/
	err = a3config.CheckItemValid(ctx, true, clusterData.Items)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return err, RespData
	}
	/* check ip and primary ip can not be same*/

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
		err = errors.New("return code is not ok from Primary server.")
		return err, RespData
	}

	return err, RespData
}

/*
func IsPrimaryCluster() {
	ClusterIp := a3config.ReadClusterPrimary()

}
*/
