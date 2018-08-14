/*netWorks.go implements handling REST API:
 *	/a3/api/v1/configurator/networks
 */
package configurator

import (
	//"encoding/json"
	//	"fmt"
	"context"
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

type Networks struct {
	ClusterEnable string `json:"cluster_enable"`
	HostName      string `json:"hostname"`
	Items         []item `json:"items"`
}

type NetworksCmd struct {
	crud.Crud
}

func NetworksCmdNew(ctx context.Context) crud.SectionCmd {
	net := new(NetworksCmd)
	net.Add("GET", handleGetNetwork)
	net.Add("POST", handleUpdateNetwork)
	return net
}

func handleGetNetwork(r *http.Request, d crud.HandlerData) ([]byte, error) {
	ctx := r.Context()
	log.LoggerWContext(ctx).Info("czhong get method", r.Method)
	return []byte("test"), nil
}

func handleUpdateNetwork(r *http.Request, d crud.HandlerData) ([]byte, error) {
	return []byte("test"), nil
}
