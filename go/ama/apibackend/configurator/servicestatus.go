package configurator

import (
	"context"
	//	"encoding/json"
	"fmt"
	"net/http"
	//	"strconv"

	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	//	"github.com/inverse-inc/packetfence/go/log"
)

type Service struct {
	crud.Crud
}

type StatusRes struct {
	Code string `json:"code"`
}

func ServicesNew(ctx context.Context) crud.SectionCmd {
	service := new(Service)
	service.New()
	service.Add("GET", handleGetServiceStatus)
	return service
}

func handleGetServiceStatus(r *http.Request, d crud.HandlerData) []byte {
	//var ctx = r.Context()
	code := "ok"

	msg := utils.ServiceStatus()
	if msg == "" {
		code = "fail"
	}

	if msg == "100" {
		utils.UpdateCurrentlyAt()
		utils.ExecShell(`pfcmd service iptables restart`)
	}

	return []byte(fmt.Sprintf(`{"code":"%s", "percentage":"%s"}`, code, msg))
}
