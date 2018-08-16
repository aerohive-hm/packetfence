package configurator

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	//  "github.com/inverse-inc/packetfence/go/ama/fetch"
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

type Iface struct {
	Name     string `json:"name"`
	IpAddr   string `json:"ip_addr"`
	NetMask  string `json:"netmask"`
	Vip      string `json:"vip"`
	Type     string `json:"type"`
	Services string `json:"services"`
}

func handleUpdateInterface(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	log.LoggerWContext(ctx).Info("czhong get method " + r.Method)
	return []byte(crud.PostOK)
}

func handleDelInterface(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	iface := new(Iface)

	err := json.Unmarshal(d.ReqData, iface)
	if err != nil {
		return []byte(err.Error())
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("%v", iface))

	return []byte(crud.PostOK)
}
