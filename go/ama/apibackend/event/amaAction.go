//amastatus.go implements handling REST API:
/*
 *      /a3/api/v1/event/ama/action
 */
package event

import (
	"context"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/amac"
	"github.com/inverse-inc/packetfence/go/log"
	"net/http"
	"encoding/json"
)

type AMAAction struct {
	Action string `json:"action"`
}

type Action struct {
	crud.Crud
}

func AMAActionNew(ctx context.Context) crud.SectionCmd {
	action := new(Action)
	action.New()
	action.Add("POST", handlePostAMAAction)
	return action
}

func handlePostAMAAction(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	code := "fail"
	postInfo := new(AMAAction)
	ret := ""
	event := new(amac.MsgStru)

	err := json.Unmarshal(d.ReqData, postInfo)
	if err != nil {
		log.LoggerWContext(ctx).Error("unmarshal error: " + err.Error())
		goto END
	}

	event.MsgType = amac.CloudIntegrateFunction
	event.Data = postInfo.Action
	amac.MsgChannel <- *event

	code = "ok"
END:

	if code == "ok" {
		//other thing need to do
	}

	if err != nil {
		ret = err.Error()
	}
	return crud.FormPostRely(code, ret)
}
