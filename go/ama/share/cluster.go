//cluster.go implements send event for cluster join and get / update primary cluster.
package a3share

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/client"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
)

func GetPrimaryNetworksData(ctx context.Context) (error, a3config.NetworksData) {

	url := fmt.Sprintf("https://%s:9999/a3/api/v1/configurator/networks",
		a3config.ReadClusterPrimary())
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

	url := fmt.Sprintf("https://%s:9999/a3/api/v1/event/cluster/join",
		a3config.ReadClusterPrimary())
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

type syncData struct {
	Code   string `json:"code"`
	Status string `json:"status"`
}

func waitPrimarySync(ip string) error {
	ctx := context.Background()
	var msg syncData
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
		log.LoggerWContext(ctx).Info(fmt.Sprintf("read sync status=%s from primary", msg.Status))

		if msg.Status == "StartSync" {
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
	apibackclient.SendClusterSync(ip, "FinishSync")

	utils.UpdateCurrentlyAt()

}
