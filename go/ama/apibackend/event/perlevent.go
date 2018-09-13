/*rdctoken.go implements handling REST API:
 *      /a3/api/v1/event/perlevent
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


type PerlEventH struct {
	crud.Crud
}

func PerlEventNew(ctx context.Context) crud.SectionCmd {
	PerlEvent := new(PerlEventH)
	PerlEvent.New()
	PerlEvent.Add("POST", handlePostPerlEvent)
	return PerlEvent
}

type PerlEventData struct {
	MsgType      int `json:"msgtype"`
}

func handlePostPerlEvent(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()


	log.LoggerWContext(ctx).Info(fmt.Sprintf("receive perl event data: %s", string(d.ReqData)))

	eventData := new(PerlEventData)
	err := json.Unmarshal(d.ReqData, eventData)
	if err != nil {
		log.LoggerWContext(ctx).Error("Unmarshal error:" + err.Error())
		return []byte(err.Error())
	}

	
	result := amac.UpdateMsgToRdcAsyn(ctx, eventData.MsgType)
	if result != 0 {
		log.LoggerWContext(ctx).Info(fmt.Sprintf("update message type %d failed", eventData.MsgType))
	}

	// don't care fail now
	return []byte(crud.PostOK)
}
