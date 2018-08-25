//amastatus.go implements handling REST API:
/*
 *      /a3/api/v1/event/ama/status
 */
package event

import (
	"context"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"net/http"
)

type AMAStatus struct {
}

type Status struct {
	crud.Crud
}

func AMAStatusNew(ctx context.Context) crud.SectionCmd {
	status := new(Status)
	status.New()
	status.Add("GET", handleGetAMAStatus)
	return status
}

func handleGetAMAStatus(r *http.Request, d crud.HandlerData) []byte {
	return nil
}
