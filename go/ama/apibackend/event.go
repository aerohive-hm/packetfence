//handleEvent.go implements handling REST API:
/*
 *	/a3/api/v1/event/...
 */
package apibackend

import (
	//	"context"
	//	"errors"
	//	"fmt"
	//	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/event"
	//	"github.com/inverse-inc/packetfence/go/log"
	//	"net/http"
)

/*
type A3EventHandler interface {
	GetMethodHandle(ctx context.Context) ([]byte, error)
	//Todo:PostMethodHandle()
}
*/

func init() {
	sections := map[string]interface{}{
		"onboarding": event.OnBoardingNew,
	}
	Register("event", sections)
}

/*
func HandleEvent(w http.ResponseWriter, r *http.Request, d crud.HandlerData) {
	fmt.Println("Start handle event ...")
	if r.Method == "GET" {
		jsonData, err := handleGetMethod(r, d)
		if err != nil {
			fmt.Println(err)
			//log.LoggerWContext(ctx).Error("Error while handling GET method for A3 event:" + err.Error())
			return
		}
		fmt.Fprintf(w, string(jsonData))
	} else if r.Method == "POST" {
		//jsonData, err := handlePostMethod(ctx, d)
		//Todo: How to handle POST method for A3 event
	} else {
		fmt.Println("Can't handle unsupported method:%s", r.Method)
	}
}

func handleGetMethod(r *http.Request, d crud.HandlerData) ([]byte, error) {
	ctx := r.Context()
	var eventHandler A3EventHandler
	switch d.SubCmd {
	case "onboarding":
		eventHandler = new(event.A3OnboardingInfo)

	//Todo: For other subcmd handle, add here

	default:
		//Todo: default handle
		err := errors.New("Unsupport subcmd for GET method")
		return nil, err
	}
	jsonData, err := eventHandler.GetMethodHandle(ctx)
	if err != nil {
		log.LoggerWContext(ctx).Error("Error while handling GET method for subcmd %s:", d.SubCmd)
		return nil, err
	}
	return jsonData, nil
}
*/
