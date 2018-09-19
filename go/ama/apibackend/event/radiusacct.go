/*rdctoken.go implements handling REST API:
 *      /api/v1/event/radiusacct
 */
package event

import (
	"context"
	//"encoding/json"
	//"fmt"
	"net/http"

	//"github.com/inverse-inc/packetfence/go/ama/amac"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	//"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/log"
)

type RadAcct struct {
	crud.Crud
}

func RadAcctNew(ctx context.Context) crud.SectionCmd {
	radacct := new(RadAcct)
	radacct.New()
	radacct.Add("POST", handlePostRadAcct)
	return radacct
}

/* This function will hanle the RDC token request from the other cluster members */
func handlePostRadAcct(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	log.LoggerWContext(ctx).Error("into handlePostRadAcct")

	return []byte("")
}
