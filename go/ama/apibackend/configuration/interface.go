//interface.go implements handling REST API:
/*
 *      /a3/api/v1/configuration/interface
 */

package configuration

import (
	"context"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"net/http"
)

type IntInfo struct {
}

type Interface struct {
	crud.Crud
}

func InterfaceNew(ctx context.Context) crud.SectionCmd {
	intface := new(Interface)
	intface.New()
	intface.Add("GET", handleGetInterfaceInfo)
	intface.Add("POST", handlePostInterfaceInfo)
	intface.Add("DELETE", handleDeleteInterface)
	return intface
}

func handleGetInterfaceInfo(r *http.Request, d crud.HandlerData) []byte {
	return nil
}

func handlePostInterfaceInfo(r *http.Request, d crud.HandlerData) []byte {
	return nil
}

func handleDeleteInterface(r *http.Request, d crud.HandlerData) []byte {
	return nil
}
