//clusternetworks.go implements handling REST API:
//	/a3/api/v1/configurator/step
//  getStart
//  adminUser
//  networks
//  licensing
//  licensing,enterEntitlementKey
//  licensing,endUserLicenseAgreement
//  aerohiveCloud 
//  startingManagement

//  joinCluster
//  clusterNetworking
//  joining
//  startingRegistration

package configurator

import (
	"context"
	"encoding/json"
	"net/http"
	"fmt"

	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/log"
)

type Step struct {
	crud.Crud
}

func StepNew(ctx context.Context) crud.SectionCmd {
	step := new(Step)
	step.New()
	step.Add("GET", handleGetStep)
	return step
}


func handleGetStep(r *http.Request, d crud.HandlerData) []byte {
	var ctx = r.Context()

	//read history step
	historyStep := a3config.ReadSetupStep()
	log.LoggerWContext(ctx).Info(fmt.Sprintf("last pending configurator step = %s", historyStep))

	if historyStep == "" {
		historyStep = "getStart"
	}
	
	step := map[string]string{
		"step": historyStep,
	}

	jsonData, err := json.Marshal(step)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return []byte(err.Error())
	}
	return jsonData
}
