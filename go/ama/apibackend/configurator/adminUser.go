/*adminUser.go implements handling REST API:
 *	/a3/api/v1/configurator/admin_user
 */
package configurator

import (
	"context"
	"encoding/json"

	"github.com/inverse-inc/packetfence/go/ama/apibackend/fetch"
	"github.com/inverse-inc/packetfence/go/log"
)

type AdminUserInfo struct {
	Id   string `json:"id"`
	User string `json:"user"`
	Pass string `json:"pass"`
}

func (a3Data *AdminUserInfo) HandleGetAdminUserMethod(ctx context.Context) ([]byte, error) {
	var adminuserinfo AdminUserInfo
	var config fetch.PfConfWebservices
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
