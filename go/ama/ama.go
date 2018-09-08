package ama

import (
	"context"
	"fmt"

	"github.com/inverse-inc/packetfence/go/log"
)

type ClusterPrimaryStatus int

// status of primary server during join
const (
	_           ClusterPrimaryStatus = iota
	PrepareSync                      // notify cluster members to close db service
	Ready4Sync
	FinishSync
	RecoveryDone
)

type ClusterJoinStatusType int

// status of node server during join
const (
	Idle ClusterJoinStatusType = iota
	Waitng2Sync
	SyncFiles
	SyncDB
	SyncFinished
)

type ClusterStatusType struct {
	IsPrimary      bool // Primary or New join server ??
	Status         interface{}
	ServersExisted map[string]ClusterJoinStatusType
	SyncCounter    int
}

var ClusterStatus = ClusterStatusType{}
var ServiceStartPercentage = "0"

func init() {
	ClusterStatus.IsPrimary = false
	ClusterStatus.Status = Idle
}

func InitClusterStatus(primary string) {
	ctx := context.Background()
	if primary == "primary" {
		ClusterStatus.IsPrimary = true
		ClusterStatus.Status = PrepareSync
		ClusterStatus.ServersExisted = make(map[string]ClusterJoinStatusType)
	} else {
		ClusterStatus.IsPrimary = false
		ClusterStatus.Status = Waitng2Sync
		ClusterStatus.SyncCounter = 0
	}
	log.LoggerWContext(ctx).Error(fmt.Sprintln("init: "))
	log.LoggerWContext(ctx).Error(fmt.Sprintln(ClusterStatus))
}

func ClearClusterStatus() {
	ClusterStatus.IsPrimary = false
	ClusterStatus.Status = Idle
	ClusterStatus.ServersExisted = map[string]ClusterJoinStatusType{}
	ClusterStatus.SyncCounter = 0
}

func SetClusterStatus(status interface{}) {
	ClusterStatus.Status = status
}

func IsClusterJoinMode() bool {
	if ClusterStatus.IsPrimary {
		return true
	}

	if ClusterStatus.Status != Idle {
		return true
	}
	return false
}

func UpdateClusterNodeStatus(ip string, status ClusterJoinStatusType) {
	ClusterStatus.ServersExisted[ip] = status

	if status == SyncFinished {
		ClusterStatus.SyncCounter++
	}
}

func IsAllNodeStatus(status ClusterJoinStatusType) bool {
	for _, s := range ClusterStatus.ServersExisted {
		if s != status {
			return false
		}
	}
	return true
}
