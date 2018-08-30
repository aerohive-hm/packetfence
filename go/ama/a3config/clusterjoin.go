//clusterjoin.go implements fetching clusterjoin info.
package a3config

import (
	"context"
	//"fmt"
	//"strings"

	//"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
)

type ClusterItem struct {
	Name    string `json:"name"`
	IpAddr  string `json:"ip_addr"`
	NetMask string `json:"netmask"`
}

type ClusterEventJoinData struct {
	Hostname string        `json:"hostname"`
	Items    []ClusterItem `json:"items"`
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
	var err error
	var clusterRespData = ClusterEventRespData{}
	for _, item := range clusterData.Items {
		err = UpdateJoinClusterconf(item, clusterData.Hostname)
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

	return err, clusterRespData
}
