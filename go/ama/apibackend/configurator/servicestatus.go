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

type Service struct {
	crud.Crud
}

func ServicesNew(ctx context.Context) crud.SectionCmd {
	service := new(Service)
	service.New()
	service.Add("GET", handleGetServiceStatus)
	return service
}

func handleGetServiceStatus(r *http.Request, d crud.HandlerData) []byte {
	var ctx = r.Context()

	//Data for demo
	service := map[string]string{
		"code":       "ok",
		"percentage": "100",
	}

	jsonData, err := json.Marshal(service)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return []byte(err.Error())
	}
	return jsonData
}
