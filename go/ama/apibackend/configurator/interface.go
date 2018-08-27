package configurator

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/log"
)

type Interface struct {
	crud.Crud
}

func InterfaceNew(ctx context.Context) crud.SectionCmd {
	iface := new(Interface)
	iface.New()
	iface.Add("POST", handleUpdateInterface)
	iface.Add("DELETE", handleDelInterface)
	return iface
}

func handleUpdateInterface(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	i := new(a3config.Item)

	err := json.Unmarshal(d.ReqData, i)
	if err != nil {
		return []byte(err.Error())
	}

	err = a3config.UpdateSystemInterface(ctx, *i)
	if err != nil {
		return []byte(err.Error())
	}
	return []byte(crud.PostOK)
}

func handleDelInterface(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	i := new(a3config.Item)

	err := json.Unmarshal(d.ReqData, i)
	if err != nil {
		return []byte(err.Error())
	}
	err = a3config.DelSystemInterface(ctx, *i)
	if err != nil {
		return []byte(err.Error())
	}
	log.LoggerWContext(ctx).Info(fmt.Sprintf("%v", i))

	return []byte(crud.PostOK)
}
