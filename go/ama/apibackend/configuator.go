package a3apibackend

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/log"
	//"github.com/inverse-inc/packetfence/go/pfconfigdriver"
)

type userInfo struct {
	Id   string `json:"id"`
	User string `json:"user"`
	Pass string `json:"pass"`
}

func init() {
	Register("configurator", HandleConfiguator)
}

func HandleGetAdminUser(w http.ResponseWriter, ctx context.Context) {
	var userinfo userInfo
	var config PfConfWebservices

	config.GetPfConfSub(ctx, &config.Webservices)
	userinfo.Id = "webservices"
	userinfo.User = config.Webservices.User
	userinfo.Pass = config.Webservices.Pass
	jsonuser, err := json.Marshal(userinfo)
	if err != nil {
		log.LoggerWContext(ctx).Info("marshal user error")
	}
	fmt.Fprintf(w, string(jsonuser))
}

func HandleConfiguator(w http.ResponseWriter, r *http.Request, d HandlerData) {
	ctx := r.Context()
	//GET
	if d.Method == "GET" {
		if d.SubCmd == "admin_user" {
			HandleGetAdminUser(w, ctx)
		}

	}
	//POST
}
