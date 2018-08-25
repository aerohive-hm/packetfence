//license.go implements handling REST API:
/*
 *      /a3/api/v1/configuration/license
 */

package configuration

import (
	"context"
	"net/http"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
)

type LicenseInfo struct {

}

type License struct {
	crud.Crud
}

func LicenseNew(ctx context.Context) crud.SectionCmd {
	license := new(Interface)
	license.New()
	license.Add("GET", handleGetLicenseInfo)
	license.Add("POST", handlePostLicenseInfo)
	return license
}

func handleGetLicenseInfo(r *http.Request, d crud.HandlerData) []byte {
	return nil
}

func handlePostLicenseInfo(r *http.Request, d crud.HandlerData) []byte {
	return nil
}