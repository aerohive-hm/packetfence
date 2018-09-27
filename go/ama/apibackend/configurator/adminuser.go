/*adminUser.go implements handling REST API:
 *	/a3/api/v1/configurator/admin_user
 */
package configurator

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/database"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
)

type AdminUserInfo struct {
	User string `json:"user"`
	Pass string `json:"pass"`
}

type AdminUser struct {
	crud.Crud
}

func AdminUserNew(ctx context.Context) crud.SectionCmd {
	admin := new(AdminUser)
	admin.New()
	//	admin.Add("GET", handleGetAdminUserMethod)
	admin.Add("POST", handleGetAdminUserPost)
	return admin
}

func hashPassword(password string) string {
	method := a3config.GetKeyFromSection("advanced", "hash_passwords")
	if method == "plaintext" {
		return password
	} else if method == "bcrypt" {
		return utils.AhBcryptHash(password)
	} else if method == "ntlm" {
		// TODO
		return ""
	}
	return ""
}

/* replace is better than insert because it does not need to check if pid exsit or not */
const (
	sqlCmd = `replace into password(pid,password,valid_from,expiration,access_level)` +
		`values('%s','%s','%s','%s','%s')`
	apiUserSql = `replace into api_user(username,password,valid_from,expiration,` +
		`access_level)values(?,?,?,?,?)`
)

/*write admin info to password table*/
func writeAdminToDb(user, password string) error {
	timeStart := utils.AhNowUtcFormated()
	expiration := utils.ExpireTime

	hpassword := hashPassword(password)
	bpassword := `{bcrypt}` + hpassword
	values := fmt.Sprintf(sqlCmd, user, bpassword, timeStart,
		expiration, "ALL")
	sql := []amadb.SqlCmd{
		{
			"replace into person(pid,email)values(?,?)",
			[]interface{}{
				user,
				user,
			},
		},
		// replace table person before password, there is a trigger in DB
		{
			Sql: values,
		},
		{
			apiUserSql,
			[]interface{}{
				user,
				hpassword,
				timeStart,
				expiration,
				"ALL",
			},
		},
	}

	db := new(amadb.A3Db)
	return db.Exec(sql)
}

/*
func handleGetAdminUserMethod(r *http.Request, d crud.HandlerData) []byte {
	//	var admin AdminUserInfo
	//	var ctx = r.Context()
	return []byte("")
}
*/
func handleGetAdminUserPost(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	admin := new(AdminUserInfo)
	code := "fail"

	err := json.Unmarshal(d.ReqData, admin)
	if err != nil {
		log.LoggerWContext(ctx).Error("unmarshal error: " + err.Error())
		goto END
	}

	if utils.IsFileZero(utils.A3Root + "/conf/pf.conf") {
		err = errors.New("System is starting up, please wait a moment.")
		goto END
	}

	err = writeAdminToDb(admin.User, admin.Pass)
	if err != nil {
		log.LoggerWContext(ctx).Error("write db error: " + err.Error())
		goto END
	}

	err = a3config.UpdateEmail(admin.User)
	if err != nil {
		log.LoggerWContext(ctx).Error("write conf error: " + err.Error())
		goto END
	}

	code = "ok"

END:
	var ret = ""
	if err != nil {
		ret = err.Error()
	}
	a3config.RecordSetupStep(a3config.StepNetworks, code)
	return crud.FormPostRely(code, ret)
}
