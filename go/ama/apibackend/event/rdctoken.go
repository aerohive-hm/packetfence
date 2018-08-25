/*rdctoken.go implements handling REST API:
 *      /a3/api/v1/event/rdctoken
 */
package event

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama/amac"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/log"
)

type TokenReq struct {
	SystemID string `json:"systemID"`
}

type Token struct {
	crud.Crud
}

func RdcTokenNew(ctx context.Context) crud.SectionCmd {
	token := new(Token)
	token.New()
	token.Add("GET", handleGetToken)
	token.Add("POST", handlePostToken)
	return token
}

/* This function will hanle the RDC token request from the other cluster members */
func handleGetToken(r *http.Request, d crud.HandlerData) []byte {

	ctx := r.Context()

	fmt.Println(r.URL)

	token := amac.ReqTokenForOtherNodes(ctx, "test-systemid")

	return token
}

/*
	When user input the GDC para to trigger the RDC token update in the other nodes
	this node will receive a post request and get a new RDC token
*/
func handlePostToken(r *http.Request, d crud.HandlerData) []byte {

	ctx := r.Context()
	tokenRes := amac.A3TokenResFromRdc{}

	log.LoggerWContext(ctx).Info("into handlePostToken")
	err := json.Unmarshal(d.ReqData, &tokenRes)
	if err != nil {
		return []byte(err.Error())
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("%+v", tokenRes))
	amac.UpdateRdcToken(ctx, tokenRes.Data.Token)

	return []byte(crud.PostOK)
}
