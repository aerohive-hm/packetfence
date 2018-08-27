/*clusternetworks.go implements handling REST API:
 *	/a3/api/v1/configurator/cluster/status
 */
package configurator

import (
	"context"
	"encoding/json"
	//  "fmt"
	"net/http"
	//	"strconv"

	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/log"
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
	var ctx = r.Context()

	//Data for demo
	status := map[string]string{
		"percentage": "100",
	}

	jsonData, err := json.Marshal(status)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return []byte(err.Error())
	}
	return jsonData
}
