package ama

import (
	"context"
	"fmt"

	"github.com/inverse-inc/packetfence/go/log"
)

type ClusterPrimaryStatus int

const (
	_           ClusterPrimaryStatus = iota
	PrepareSync                      // notify cluster members to close db service
	Ready4Sync
	FinishSync
)

type ClusterJoinStatusType int

const (
	_ ClusterJoinStatusType = iota
	Waitng2Sync
	SyncFiles
	SyncDB
	SyncFinished
)

type ClusterStatusType struct {
	IsPrimary bool // Primary or New join server ??
	Status    interface{}
}

var ClusterStatus = ClusterStatusType{}

func InitClusterStatus(primary string) {
	ctx := context.Background()
	if primary == "primary" {
		ClusterStatus.IsPrimary = true
		ClusterStatus.Status = PrepareSync
	} else {
		ClusterStatus.IsPrimary = false
		ClusterStatus.Status = Waitng2Sync
	}
	log.LoggerWContext(ctx).Error(fmt.Sprintln("init: "))
	log.LoggerWContext(ctx).Error(fmt.Sprintln(ClusterStatus))
}

func SetClusterStatus(status interface{}) {
	ClusterStatus.Status = status
}
