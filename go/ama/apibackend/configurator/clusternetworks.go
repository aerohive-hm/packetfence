/*clusternetworks.go implements handling REST API:
 *	/a3/api/v1/configurator/cluster/networks
 */
package configurator

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
)

type clusterNetworks struct {
	crud.Crud
}

func ClusterNetworksNew(ctx context.Context) crud.SectionCmd {
	clusternet := new(clusterNetworks)
	clusternet.New()
	clusternet.Add("GET", handleGetClusterNetwork)
	clusternet.Add("POST", handleUpdateClusterNetwork)
	return clusternet
}

func handleGetClusterNetwork(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	clusternet := utils.GetClusterNetworksData(ctx)
	jsonData, err := json.Marshal(clusternet)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return []byte(err.Error())
	}
	return jsonData
}

func handleUpdateClusterNetwork(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	clusternet := new(utils.ClusterNetworksData)

	err := json.Unmarshal(d.ReqData, clusternet)
	if err != nil {
		return []byte(err.Error())
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("%v", clusternet))

	return []byte(crud.PostOK)
}
