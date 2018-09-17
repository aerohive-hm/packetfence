//clusterjoin.go implements fetching clusterjoin info.
package a3config

import (
	"context"
	"errors"
	"fmt"

	//"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
)

type ClusterEventJoinData struct {
	Hostname string `json:"hostname"`
	Items    []Item `json:"items"`
}

type ClusterEventRespItem struct {
	User     string `json:"user"`
	Password string `json:"pass"`
}
type ClusterEventRespData struct {
	Code  string                 `json:"code"`
	Items []ClusterEventRespItem `json:"items"`
}

func UpdateEventClusterJoinData(ctx context.Context, clusterData ClusterEventJoinData) (error, ClusterEventRespData) {
	/*write data to cluster conf*/
	log.LoggerWContext(ctx).Info(fmt.Sprintf("ClusterEventJoinData %v", clusterData))
	var err error
	var clusterRespData = ClusterEventRespData{}
	nodeList := ClusterNew().FetchNodesInfo()
	for _, node := range nodeList {
		if node.Hostname == clusterData.Hostname {
			msg := fmt.Sprintf("hostname (%s) is exsit.", clusterData.Hostname)
			return errors.New(msg), clusterRespData
		}
	}

	for _, i := range clusterData.Items {
		err = UpdateJoinClusterconf(i, clusterData.Hostname)
		if err != nil {
			log.LoggerWContext(ctx).Error("UpdateJoinClusterconf error:" + err.Error())
			return err, clusterRespData
		}
	}
	clusterRespData.Code = "ok"
	item := new(ClusterEventRespItem)
	Section := GetWebServices()
	item.User = Section["webservices"]["user"]
	item.Password = Section["webservices"]["pass"]
	clusterRespData.Items = append(clusterRespData.Items, *item)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("ClusterEventRespData %v", clusterRespData))
	return err, clusterRespData
}
