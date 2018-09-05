/*clusternetworks.go implements handling REST API:
 *	/a3/api/v1/configurator/cluster/networks
 */
package configurator

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/amac"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/share"
	//"github.com/inverse-inc/packetfence/go/ama/client"
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

// Get network data from master
// Send request to call master API: /a3/api/v1/configurator/networks
func handleGetClusterNetwork(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()

	/*get primary networksdate*/
	_, primaryData := a3share.GetPrimaryNetworksData(ctx)
	clusternetdata := a3config.GetClusterNetworksData(ctx, primaryData)

	jsonData, err := json.Marshal(clusternetdata)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return []byte(err.Error())
	}
	log.LoggerWContext(ctx).Info(fmt.Sprintf("%v", clusternetdata))
	return jsonData
}

func activeJoinCluster(ip, user, pass string) {
	a3share.ActiveSyncFromPrimary(ip, user, pass)
	amac.JoinCompleteEvent()
}

func handleUpdateClusterNetwork(r *http.Request, d crud.HandlerData) []byte {

	ctx := r.Context()
	code := "fail"
	ret := ""

	clusternetdata := new(a3config.ClusterNetworksData)
	err := json.Unmarshal(d.ReqData, clusternetdata)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		ret = err.Error()
		return crud.FormPostRely(code, ret)
	}
	err, clusterRespData := a3share.UpdatePrimaryNetworksData(ctx, *clusternetdata)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdatePrimaryNetworksData error:" + err.Error())
		ret := err.Error()
		return crud.FormPostRely(code, ret)
	}

	err = a3config.UpdateClusterNetworksData(ctx, *clusternetdata, clusterRespData)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdateClusterNetworksData error:" + err.Error())
		ret := err.Error()
		return crud.FormPostRely(code, ret)
	}

	a3config.UpdateClusterFile()

	web := clusterRespData.Items[0]
	go activeJoinCluster(a3config.ReadClusterPrimary(),
		web.User, web.Password)

	code = "ok"
	a3config.RecordSetupStep(a3config.StepJoining, code)
	return crud.FormPostRely(code, ret)
}
