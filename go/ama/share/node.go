package a3share

import (
	"github.com/inverse-inc/packetfence/go/ama/a3config"
)

type nodeInfo struct {
	IpAddr string
}

func FetchNodesInfo() []nodeInfo {
	conf := a3config.A3Read("CLUSTER", "all")
	if conf == nil {
		return nil
	}
	nodes := []nodeInfo{}
	for secName, kvpair := range conf {
		if secName == "CLUSTER" {
			continue
		}

		for k, v := range kvpair {
			if k == "management_ip" {
				node := nodeInfo{IpAddr: v}
				nodes = append(nodes, node)
			}
		}
	}
	return nodes
}
