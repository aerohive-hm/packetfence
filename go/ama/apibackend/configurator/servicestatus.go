package configurator

import (
	"context"
	//	"encoding/json"
	//  "fmt"
	"net/http"
	//	"strconv"

	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	//	"github.com/inverse-inc/packetfence/go/log"
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
	//var ctx = r.Context()
	code := "ok"

	return crud.FormPostRely(code, err.Error())
}
