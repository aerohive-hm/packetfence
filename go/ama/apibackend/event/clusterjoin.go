/*join.go implements handling REST API:
 *	/a3/api/v1/event/cluster/join
 */
package event

import (
	"context"
	"encoding/json"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/utils"
)

type Join struct {
	crud.Crud
}

func ClusterJoinNew(ctx context.Context) crud.SectionCmd {
	join := new(Join)
	join.New()
	join.Add("POST", handleUpdateEventClusterJoin)
	return join
}

/*
|-send event/cluster/sync stopservice( rc = ok)
|-`systemctl stop packetfence-mariadb`
|-`pfcmd configreload hard`
|-`bin/pfcmd checkup`
|-`pf-mariadb --force-new-cluster &`
|-send event/cluster/sync start
*/
func PrepareClusterNodeJoin() {
	utils.ForceNewCluster()
}

func handleUpdateEventClusterJoin(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	clusterData := new(a3config.ClusterEventJoinData)

	err := json.Unmarshal(d.ReqData, clusterData)
	if err != nil {
		return []byte(err.Error())
	}
	err, Respdata := a3config.UpdateEventClusterJoinData(ctx, *clusterData)
	if err != nil {
		return []byte(err.Error())
	}
	Resp, _ := json.Marshal(Respdata)

	// Prepare for cluster node sync
	go PrepareClusterNodeJoin()

	return []byte(Resp)
}
