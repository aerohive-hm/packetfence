package a3apibackend

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/log"
	"github.com/inverse-inc/packetfence/go/pfconfigdriver"
)

type UserInfo struct {
	Id   string `json:"id"`
	User string `json:"user"`
	Pass string `json:"pass"`
}

func init() {
	Register("configurator", HandleConfiguator)
}
func GetUserInfo(ctx context.Context) UserInfo {
	userinfo := UserInfo{}
	var webservices pfconfigdriver.PfConfWebservices

	webservices.PfconfigNS = "config::Pf"
	webservices.PfconfigMethod = "hash_element"
	webservices.PfconfigHashNS = "webservices"
	pfconfigdriver.FetchDecodeSocket(ctx, &webservices)

	userinfo.Id = webservices.PfconfigHashNS
	userinfo.User = webservices.User
	userinfo.Pass = webservices.Pass
	return userinfo
}

func AddUserInfoToJson(ctx context.Context) string {
	userinfo := GetUserInfo(ctx)

	jsonuser, err := json.Marshal(userinfo)
	if err != nil {
		log.LoggerWContext(ctx).Info("marshal user error")
	}
	return string(jsonuser)
}

func HandleConfiguator(w http.ResponseWriter, r *http.Request, d HandlerData) {
	//GET
	if d.Method == "GET" {
		if d.SubCmd == "admin_user" {
			ctx := r.Context()
			jsonuser := AddUserInfoToJson(ctx)
			fmt.Fprintf(w, string(jsonuser))
		}
	}

	//POST
}
