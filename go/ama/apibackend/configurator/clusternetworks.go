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
	//	"github.com/inverse-inc/packetfence/go/ama/fetch"
	"github.com/inverse-inc/packetfence/go/log"
)

type clusterNetworksData struct {
	HostName string `json:"hostname"`
	Items    []item `json:"items"`
}

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

	// Data for demo
	clusternet := clusterNetworksData{
		"a3.aerohive.com",
		[]item{
			{
				"interface",
				"eth0",
				"10.155.23.14",
				"255.255.255.0",
				"0.0.0.0",
				"",
				"",
			},
			{
				"interface",
				"VLAN10",
				"192.168.10.1",
				"255.255.255.0",
				"0.0.0.0",
				"REGISTRATION",
				"",
			},
			{
				"interface",
				"VLAN20",
				"192.168.20.1",
				"255.255.255.0",
				"0.0.0.0",
				"ISOLATION",
				"RADIUS, PORTAL",
			},
		},
	}

	jsonData, err := json.Marshal(clusternet)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return []byte(err.Error())
	}
	return jsonData
}

func handleUpdateClusterNetwork(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	clusternet := new(clusterNetworksData)

	err := json.Unmarshal(d.ReqData, clusternet)
	if err != nil {
		return []byte(err.Error())
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("%v", clusternet))

	return []byte(crud.PostOK)
}
