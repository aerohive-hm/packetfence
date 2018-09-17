/*join.go implements handling REST API:
 *	/a3/api/v1/configurator/cluster/join
 */
package configurator

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/client"
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
	join.Add("POST", handleUpdateJoin)
	return join
}

// Login primary server with API: "https://PrimaryServer:9999/api/v1/login"
func handleUpdateJoin(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	join := new(JoinData)
	code := "fail"
	ret := ""

	err := json.Unmarshal(d.ReqData, join)
	if err != nil {
		return []byte(err.Error())
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("Join Auth POST cluster Primary = %s, admin = %s",
		join.PrimaryServer, join.Admin))

	//write to pf.conf in order to use API client.ClusterAuth()
	a3config.WriteUserPassToPF(join.PrimaryServer, join.Admin, join.Passwd)
	//use administrative user to do authentication
	client := new(apibackclient.Client)
	client.Host = join.PrimaryServer
	err = client.ClusterAuth()
	if err != nil {
		log.LoggerWContext(ctx).Error("ClusterAuth error: " + err.Error())
		ret := fmt.Sprintf("It can't connect to cluster primary [%s] with adminuser [%s]", join.PrimaryServer, join.Admin)
		a3config.DeleteClusterPrimary()
		return crud.FormPostRely(code, ret)
	}
	code = "ok"
	a3config.RecordSetupStep(a3config.StepClusterNetworking, code)
	a3config.Isclusterjoin = true
	return crud.FormPostRely(code, ret)
}
