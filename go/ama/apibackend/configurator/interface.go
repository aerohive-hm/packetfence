package configurator

import (
	"context"
	"encoding/json"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
)

type Interface struct {
	crud.Crud
}

func InterfaceNew(ctx context.Context) crud.SectionCmd {
	iface := new(Interface)
	iface.New()
	iface.Add("POST", handleUpdateInterface)
	iface.Add("PUT", handleCreateInterface)
	iface.Add("DELETE", handleDelInterface)
	return iface
}

func handleUpdateInterface(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	code := "fail"
	ret := ""

	i := new(a3config.Item)

	err := json.Unmarshal(d.ReqData, i)
	if err != nil {
		ret = err.Error()
		return crud.FormPostRely(code, ret)
	}

	err = a3config.UpdateSystemInterface(ctx, *i)
	if err != nil {
		ret = err.Error()
		return crud.FormPostRely(code, ret)
	}

	code = "ok"
	return crud.FormPostRely(code, ret)
}

func handleCreateInterface(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	code := "fail"
	ret := ""

	i := new(a3config.Item)

	err := json.Unmarshal(d.ReqData, i)
	if err != nil {
		ret = err.Error()
		return crud.FormPostRely(code, ret)
	}

	err = a3config.CreateSystemInterface(ctx, *i)
	if err != nil {
		ret = err.Error()
		return crud.FormPostRely(code, ret)
	}

	code = "ok"
	return crud.FormPostRely(code, ret)
}
func handleDelInterface(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	code := "fail"
	ret := ""

	i := new(a3config.Item)

	err := json.Unmarshal(d.ReqData, i)
	if err != nil {
		ret = err.Error()
		return crud.FormPostRely(code, ret)
	}
	err = a3config.DelSystemInterface(ctx, *i)
	if err != nil {
		ret = err.Error()
		return crud.FormPostRely(code, ret)
	}

	code = "ok"
	return crud.FormPostRely(code, ret)
}
