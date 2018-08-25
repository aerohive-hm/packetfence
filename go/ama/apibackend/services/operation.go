//operation.go implements handling REST API:
/*
 *    /a3/api/v1/services/ama/operation
 */

package services

import (
	"context"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"net/http"
)

type OperatData struct {
}

type Operation struct {
	crud.Crud
}

func OperationNew(ctx context.Context) crud.SectionCmd {
	ope := new(Interface)
	ope.New()
	ope.Add("POST", handlePostOperatData)
	return ope
}

func handlePostOperatData(r *http.Request, d crud.HandlerData) []byte {
	return nil
}
