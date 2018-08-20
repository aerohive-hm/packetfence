/*adminUser.go implements handling REST API:
 *	/a3/api/v1/configurator/admin_user
 */
package configurator

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/inverse-inc/packetfence/go/ama/a3conf"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/db"
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
	admin.Add("GET", handleGetAdminUserMethod)
	admin.Add("POST", handleGetAdminUserPost)
	return admin
}

/*write admin info to password table*/
func writeAdminToDb(user, password, table string) error {
	var ctx = context.Background()
	db, err := db.DbFromConfig(ctx)
	if err != nil {
		return err
	}
	defer db.Close()

	/* replace is better than insert because it does not need to check if pid exsit or not */
	prepare := fmt.Sprintf("replace into %s(pid,password,valid_from,expiration,access_level )values(?,?,?,?,?)", table)

	timeStr := time.Now().Format("2006-01-02 15:04:05")
	expiration := "2038-01-01 00:00:00"
	stmt, err := db.Prepare(prepare)
	if err != nil {
		return err
	}
	defer stmt.Close()
	stmt.Exec(user, password, timeStr, expiration, "ALL")

	prepare = fmt.Sprintf("replace into person(pid)values(?)")
	stmt, err = db.Prepare(prepare)
	if err != nil {
		return err
	}
	stmt.Exec(user)
	return nil
}

func handleGetAdminUserMethod(r *http.Request, d crud.HandlerData) []byte {
	var admin AdminUserInfo
	var ctx = r.Context()
	section := a3config.GetWebServices()
	if section == nil {
		log.LoggerWContext(ctx).Error("Can't find Admin User.")
		return []byte("")
	}
	admin.User = section["webservices"]["user"]
	admin.Pass = section["webservices"]["pass"]
	jsonData, err := json.Marshal(admin)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return []byte(err.Error())
	}
	return jsonData
}

func handleGetAdminUserPost(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	admin := new(AdminUserInfo)
	code := "fail"
	err := json.Unmarshal(d.ReqData, admin)
	if err != nil {
		log.LoggerWContext(ctx).Error("unmarshal error: " + err.Error())
		goto END
	}

	log.LoggerWContext(ctx).Error("czhong: write to DB.")
	err = writeAdminToDb(admin.User, admin.Pass, "password")
	if err != nil {
		log.LoggerWContext(ctx).Error("write db error: " + err.Error())
		goto END
	}

	log.LoggerWContext(ctx).Error(fmt.Sprintln("email:", admin.User))
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
	return crud.FormPostRely(code, ret)
}
