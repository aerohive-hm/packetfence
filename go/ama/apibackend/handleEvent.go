//handleEvent.go implements handling REST API:
/*
 *	/a3/api/v1/event/...
 */
package a3apibackend

import (
	"context"
	"errors"
	"fmt"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/a3Event"
	"github.com/inverse-inc/packetfence/go/log"
	"net/http"
)

type A3EventHandler interface {
	FetchAndConvertA3InfoToJson(ctx context.Context) ([]byte, error)
	//Todo: Handle POST method
}

func init() {
	Register("event", HandleEvent)
}

func HandleEvent(w http.ResponseWriter, r *http.Request, d HandlerData) {
	fmt.Println("Start handle event ...")
	if d.Method == "GET" {
		jsonData, err := handleGetMethod(r, d)
		if err != nil {
			//log.LoggerWContext(ctx).Error("Error while handling GET method for A3 event:" + err.Error())
			return
		}
		fmt.Fprintf(w, string(jsonData))
	} else if d.Method == "POST" {
		//jsonData, err := handlePostMethod(ctx, d)
		//Todo: How to handle POST method for A3 event
	} else {
		fmt.Println("Can't handle unsupported method:%s", d.Method)
	}
}

func handleGetMethod(r *http.Request, d HandlerData) ([]byte, error) {
	ctx := r.Context()
	var eventHandler A3EventHandler
	switch d.SubCmd {
	case "onboarding":
		eventHandler = new(a3Event.A3OnboardingInfo)

	//Todo: For other subcmd handle, add here

	default:
		//Todo: default handle
		err := errors.New("Unsupport subcmd for GET method")
		return nil, err
	}
	jsonData, err := eventHandler.FetchAndConvertA3InfoToJson(ctx)
	if err != nil {
		log.LoggerWContext(ctx).Error("Error while handling GET method for subcmd %s:", d.SubCmd)
		return nil, err
	}
	return jsonData, nil
}
