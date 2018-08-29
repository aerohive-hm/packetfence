/*join.go implements handling REST API:
 *	/a3/api/v1/event/cluster/join
 */
package event

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
	Id       string `json:"id"`
	Name     string `json:"name"`
	IpAdddr  string `json:"ip_addr"`
	NetMask  string `json:"netmask"`
	Type     string `json:"type"`
	Services string `json:"services"`
}

type JoinData struct {
	Items []item `json:"items"`
}

type Join struct {
	crud.Crud
}

func ClusterJoinNew(ctx context.Context) crud.SectionCmd {
	join := new(Join)
	join.New()
	join.Add("GET", handleGetJoin)
	join.Add("POST", handleUpdateJoin)
	return join
}

func handleGetJoin(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()

	// Data for demo
	join := JoinData{
		[]item{
			{
				"interface",
				"eth0",
				"10.155.23.14",
				"255.255.255.0",
				"MANAGEMENT",
				"PORTAL",
			},
			{
				"interface",
				"VLAN10",
				"192.168.10.1",
				"255.255.255.0",
				"REGISTRATION",
				"RADIUS, PORTAL",
			},
		},
	}

	jsonData, err := json.Marshal(join)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return []byte(err.Error())
	}
	return jsonData
}

func handleUpdateJoin(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	join := new(JoinData)

	err := json.Unmarshal(d.ReqData, join)
	if err != nil {
		return []byte(err.Error())
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("%v", join))

	return []byte(crud.PostOK)
}
