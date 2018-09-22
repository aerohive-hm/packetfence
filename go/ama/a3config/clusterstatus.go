// GET /api/v1/configuration/cluster/status

package a3config

import (
	"context"
	"github.com/inverse-inc/packetfence/go/ama/utils"
)

type ClusterStatusData struct {
	Is_cluster    bool `json:"is_cluste"`
	Is_management bool `json:"is_management"`
}

func GetClusterStatus(ctx context.Context) ClusterStatusData {
	statusData := ClusterStatusData{}
	statusData.Is_cluster = clusterEnableDefault
	ip, _ := utils.GetifaceIpInfo("eth0")
	statusData.Is_management = utils.IsManagement(ip)
	return statusData
}
