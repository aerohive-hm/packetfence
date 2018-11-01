package configurator

import (
	"context"
	"fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
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
	return []byte(fmt.Sprintf(`{"code":"ok", "percentage":"%d"}`, ama.PfService))
}
