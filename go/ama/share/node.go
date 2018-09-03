package a3share

import (
	"github.com/inverse-inc/packetfence/go/ama/a3config"
)

type NodeInfo struct {
	IpAddr string
}

type RespData struct {
	Code string `json:"code"`
	Msg  string `json:"msg"`
}

func FetchNodesInfo() []NodeInfo {
	conf := a3config.A3Read("CLUSTER", "all")
	if conf == nil {
		return nil
	}
	nodes := []NodeInfo{}
	for secName, kvpair := range conf {
		if secName == "CLUSTER" {
			continue
		}

		for k, v := range kvpair {
			if k == "management_ip" {
				node := NodeInfo{IpAddr: v}
				nodes = append(nodes, node)
			}
		}
	}
	return nodes
}

func GetOwnMGTIp() string {
	return a3config.GetIfaceElementVlaue("eth0", "ip")
}