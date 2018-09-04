/*clusternetworks.go implements handling REST API:
 *	/a3/api/v1/configurator/cluster/status
 */
package configurator

import (
	"context"
	"fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	//"github.com/inverse-inc/packetfence/go/log"
)

type ClusterStatus struct {
	crud.Crud
}

func ClusterStatusNew(ctx context.Context) crud.SectionCmd {
	status := new(ClusterStatus)
	status.New()
	status.Add("GET", handleGetClusterStatus)
	return status
}

func handleGetClusterStatus(r *http.Request, d crud.HandlerData) []byte {
	var i string
	code := "ok"

	switch ama.ClusterStatus.Status {
	case ama.Waitng2Sync:
		i = "10"
	case ama.SyncFiles:
		i = "30"
	case ama.SyncDB:
		i = "60"
	case ama.SyncFinished:
		i = "100"
	default:
		code = "fail"
		i = "not in cluster join mode"
	}

	if code == "ok" {
		return []byte(fmt.Sprintf(`{"code":"ok", "percentage":"%s"}`, i))
	}

	return []byte(fmt.Sprintf(`{"code":"%s", "msg":"%s"}`, code, i))
}
