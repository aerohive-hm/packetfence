package a3apibackend

import (
	"context"
	"errors"
	"fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama/apibackend/a3Configurator"
	"github.com/inverse-inc/packetfence/go/log"
)

type A3ConfiguatorHandler interface {
	//Todo: Handle GET method
	HandleGetAdminUserMethod(ctx context.Context) ([]byte, error)
	//Todo: Handle POST method

}

func init() {
	Register("configurator", HandleConfiguator)
}

func HandleConfiguator(w http.ResponseWriter, r *http.Request, d HandlerData) {
	if d.Method == "GET" {
		jsonData, err := handleConfiguatorGetMethod(r, d)
		if err != nil {
			fmt.Println(" handleGetMethod Error ")
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

func handleConfiguatorGetMethod(r *http.Request, d HandlerData) ([]byte, error) {
	ctx := r.Context()
	var eventHandler A3ConfiguatorHandler
	switch d.SubCmd {
	case "admin_user":
		eventHandler = new(configurator.AdminUserInfo)

	//Todo: For other subcmd handle, add here

	default:
		//Todo: default handle
		err := errors.New("Unsupport subcmd for GET method")
		return nil, err
	}
	jsonData, err := eventHandler.HandleGetAdminUserMethod(ctx)
	if err != nil {
		log.LoggerWContext(ctx).Error("Error while handling GET method for subcmd %s:", d.SubCmd)
		return nil, err
	}
	return jsonData, nil
}
