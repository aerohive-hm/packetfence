// GET/POST /a3/api/v1/configuration/cluster
// POST /a3/api/v1/configuration/cluster/remove

package a3config

import (
//"context"
//"fmt"

//"github.com/inverse-inc/packetfence/go/log"
)

// 1. fetch the status of all members in cluster
// 2. change settings about some cluster options

// cluster node information
type ClusterNodeItem struct {
	Hostname string `json:"hostname"`
	IpAddr   string `json:"ipaddr"`
	NodeType string `json:"type"`
	Status   string `json:"status"`
}

type ClusterInfoData struct {
	RouterId  string            `json:"vrid"` //virtual router ID
	SharedKey string            `json:"sharedkey"`
	Items     []ClusterNodeItem `json:"items,omitempty"`
}

// Remove Node from cluster
type ClusterRemoveData struct {
	Hostname []string `json:"hostname"`
}
