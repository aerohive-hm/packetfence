//cluster.go implements handling REST API:
/*
 *      /a3/api/v1/configuration/cluster
 */

package configuration

import (
	"context"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"net/http"
)

type ClusterInfo struct {
}

type Cluster struct {
	crud.Crud
}

func ClusterNew(ctx context.Context) crud.SectionCmd {
	cluster := new(Cluster)
	cluster.New()
	cluster.Add("GET", handleGetClusterInfo)
	cluster.Add("POST", handlePostClusterInfo)
	return cluster
}

func handleGetClusterInfo(r *http.Request, d crud.HandlerData) []byte {
	return nil
}

func handlePostClusterInfo(r *http.Request, d crud.HandlerData) []byte {
	return nil
}
