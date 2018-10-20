//clusterjoin.go implements fetching clusterjoin info.
package a3config

import (
	"context"
	"errors"
	"fmt"

	"github.com/inverse-inc/packetfence/go/log"
)

type ClusterEventRespItem struct {
	User     string `json:"user"`
	Password string `json:"pass"`
}
type ClusterEventRespData struct {
	Code       string                 `json:"code"`
	Msg        string                 `json:"msg"`
	DbPassword string                 `json"dbpass"`
	Items      []ClusterEventRespItem `json:"items"`
}

func UpdateEventClusterJoinData(ctx context.Context, clusterData ClusterNetworksData) (error, ClusterEventRespData) {
	/*write data to cluster conf*/
	log.LoggerWContext(ctx).Info(fmt.Sprintf("ClusterEventJoinData %v", clusterData))
	var err error
	var clusterRespData = ClusterEventRespData{}
	nodeList := ClusterNew().FetchNodesInfo()
	for _, node := range nodeList {
		if node.Hostname == clusterData.Hostname {
			msg := fmt.Sprintf("hostname (%s) is exist.", clusterData.Hostname)
			clusterRespData.Msg = msg
			return errors.New(msg), clusterRespData
		}
	}

	for _, i := range clusterData.Items {
		err = UpdateJoinClusterconf(i, clusterData.Hostname)
		if err != nil {
			log.LoggerWContext(ctx).Error("UpdateJoinClusterconf error:" + err.Error())
			clusterRespData.Msg = "UpdateJoinClusterconf error"
			return err, clusterRespData
		}
	}

	clusterRespData.Code = "ok"
	clusterRespData.DbPassword = GetDbRootPassword()
	item := new(ClusterEventRespItem)
	Section := GetWebServices()
	item.User = Section["webservices"]["user"]
	item.Password = Section["webservices"]["pass"]
	clusterRespData.Items = append(clusterRespData.Items, *item)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("ClusterEventRespData %v", clusterRespData))
	return err, clusterRespData
}
