/*adminUser.go implements handling REST API:
 *	/a3/api/v1/configurator/admin_user
 */
package configurator

import (
	"context"
	"encoding/json"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/fetch"
	"github.com/inverse-inc/packetfence/go/log"
)

type adminUserInfo struct {
	Id   string `json:"id"`
	User string `json:"user"`
	Pass string `json:"pass"`
}

type AdminUser struct {
	crud.Crud
}

func AdminUserNew(ctx context.Context) crud.SectionCmd {
	admin := new(AdminUser)
	admin.New()
	admin.Add("GET", handleGetAdminUserMethod)
	return admin
}

func handleGetAdminUserMethod(r *http.Request, d crud.HandlerData) ([]byte, error) {
	var adminuserinfo adminUserInfo
	var config fetch.PfConfWebservices
	var ctx = r.Context()
	config.GetPfConfSub(ctx, &config.Webservices)
	adminuserinfo.Id = "webservices"
	adminuserinfo.User = config.Webservices.User
	//adminuserinfo.Pass = config.Webservices.Pass
	jsonData, err := json.Marshal(adminuserinfo)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return nil, err
	}
	return jsonData, nil
}
