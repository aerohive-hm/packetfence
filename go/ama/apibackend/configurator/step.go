/*clusternetworks.go implements handling REST API:
 *	/a3/api/v1/configurator/step
 */
package configurator

import (
	"context"
	"encoding/json"
	//  "fmt"
	"net/http"
	//	"strconv"

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

	//Data for demo
	step := map[string]string{
		"step": "getStart",
	}

	jsonData, err := json.Marshal(step)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return []byte(err.Error())
	}
	return jsonData
}
