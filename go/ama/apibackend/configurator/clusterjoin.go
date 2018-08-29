/*join.go implements handling REST API:
 *	/a3/api/v1/configurator/cluster/join
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

type JoinData struct {
	PrimaryServer string `json:"primary_server"`
	Admin         string `json:"admin"`
	Passwd        string `json:"passwd"`
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
		"192.168.10.200",
		"admin@aerohive.com",
		"aerohive",
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
