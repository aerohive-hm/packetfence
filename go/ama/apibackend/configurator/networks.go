/*netWorks.go implements handling REST API:
 *	/a3/api/v1/configurator/networks
 */
package configurator

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/log"
)

type item struct {
	Id       string `json:"id"`
	Name     string `json:"name"`
	IpAddr   string `json:"ip_addr"`
	NetMask  string `json:"netmask"`
	Vip      string `json:"vip"`
	Type     string `json:"type"`
	Services string `json:"services"`
}

type NetworksData struct {
	ClusterEnable bool   `json:"cluster_enable"`
	HostName      string `json:"hostname"`
	Items         []item `json:"items"`
}

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

	// Data for demo
	network := NetworksData{
		true,
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

	jsonData, err := json.Marshal(network)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return []byte(err.Error())
	}
	return jsonData
}

func handleUpdateNetwork(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	net := new(NetworksData)

	err := json.Unmarshal(d.ReqData, net)
	if err != nil {
		return []byte(err.Error())
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("%v", net))

	return []byte(crud.PostOK)
}
