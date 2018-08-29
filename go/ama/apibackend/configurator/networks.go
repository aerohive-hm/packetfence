/*netWorks.go implements handling REST API:
 *	/a3/api/v1/configurator/networks
 */
package configurator

import (
	"context"
	"encoding/json"
	//"fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/log"
)

type Networks struct {
	crud.Crud
}

func NetworksNew(ctx context.Context) crud.SectionCmd {
	net := new(Networks)
	net.New()
	net.Add("GET", handleGetNetwork)
	net.Add("POST", handleUpdateNetwork)
	return net
}

func handleGetNetwork(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	network := a3config.GetNetworksData(ctx)
	jsonData, err := json.Marshal(network)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return []byte(err.Error())
	}
	return jsonData
}

func handleUpdateNetwork(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	net := new(a3config.NetworksData)

	err := json.Unmarshal(d.ReqData, net)
	if err != nil {
		return []byte(err.Error())
	}
	a3config.UpdateNetworksData(ctx, *net)

	return []byte(crud.PostOK)
}
