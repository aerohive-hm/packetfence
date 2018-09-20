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
	"github.com/inverse-inc/packetfence/go/ama/database"
	"github.com/inverse-inc/packetfence/go/ama/utils"
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
	code := "fail"
	ret := ""

	net := new(a3config.NetworksData)
	err := json.Unmarshal(d.ReqData, net)
	if err != nil {
		ret = err.Error()
		return crud.FormPostRely(code, ret)
	}
	err = a3config.UpdateNetworksData(ctx, *net)
	if err != nil {
		ret = err.Error()
		return crud.FormPostRely(code, ret)
	}
	code = "ok"

	if len(net.Items) != 0 {
		a3config.RecordSetupStep(a3config.StepLicensing, code)
		writeSysidToDb()
	}
	return crud.FormPostRely(code, ret)
}

func writeSysidToDb() {
	PrimarySysId := utils.GetA3SysId()
	PrimaryHostname := utils.GetHostname()
	err := amadb.AddSysIdbyHost(PrimarySysId, PrimaryHostname)
	if err != nil {
		log.LoggerWContext(context.Background()).Error("AddSysIdbyHost error:" + err.Error())
	}
}
