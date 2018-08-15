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
	//	"github.com/inverse-inc/packetfence/go/ama/fetch"
	"github.com/inverse-inc/packetfence/go/log"
)

type item struct {
	Id       string   `json:"id"`
	Name     string   `json:"name"`
	IpAdddr  string   `json:"ip_addr"`
	NetMask  string   `json:"netmask"`
	Vip      string   `json:"vip"`
	Type     []string `json:"type"`
	Services []string `json:"services"`
}

type NetworksData struct {
	ClusterEnable string `json:"cluster_enable"`
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
	log.LoggerWContext(ctx).Info("czhong get method" + r.Method)
	return []byte(crud.PostOK)
}

func handleUpdateNetwork(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	net := new(NetworksData)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("%v", d.ReqData))

	err := json.Unmarshal(d.ReqData, net)
	if err != nil {
		return []byte(err.Error())
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("%v", net))

	return []byte(crud.PostOK)
}
