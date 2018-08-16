/*adminUser.go implements handling REST API:
 *	/a3/api/v1/configurator/admin_user
 */
package configurator

import (
	"context"
	"encoding/json"
	"fmt"
	"time"
	"net/http"
	_ "github.com/go-sql-driver/mysql"
	"github.com/inverse-inc/packetfence/go/db"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/fetch"
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
func writeAdminToDb(user,password,table string) error{
	var ctx = context.Background()
	db, err := db.DbFromConfig(ctx) 
		
	/* replace is better than insert because it does not need to check if pid exsit or not */
	prepare := fmt.Sprintf("replace into password(pid,password,valid_from,expiration,access_level )values(?,?,?,?,?)")
	
	timeStr:=time.Now().Format("2006-01-02 15:04:05")
	expiration := "2038-01-01 00:00:00"
	stmt, err := db.Prepare(prepare)
	if err != nil {		
		return err
	}
	stmt.Exec(user,password,timeStr,expiration,"ALL")
	 
    defer stmt.Close()
	defer db.Close()
	return nil
}

func handleGetAdminUserMethod(r *http.Request, d crud.HandlerData) []byte {
	var adminuserinfo AdminUserInfo
	var config fetch.PfConfWebservices
	var ctx = r.Context()
	config.GetPfConfSub(ctx, &config.Webservices)
	//adminuserinfo.Id = "webservices"
	adminuserinfo.User = config.Webservices.User
	jsonData, err := json.Marshal(adminuserinfo)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return []byte(err.Error())
	}
	return jsonData
}

func handleGetAdminUserPost(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	admin := new(AdminUserInfo)
	err := json.Unmarshal(d.ReqData, admin)
	if err != nil {
		log.LoggerWContext(ctx).Error("unmarshal error:" + err.Error())
		return []byte(`{"code":"fail"}`)
	}
    err = writeAdminToDb(admin.User,admin.Pass,"password")
	if err != nil {
		log.LoggerWContext(ctx).Error("write db error:" + err.Error())
		return []byte(`{"code":"fail"}`)
	}
	log.LoggerWContext(ctx).Info(fmt.Sprintf("admin: %s, pass: %s", admin.User,
		admin.Pass))
	return []byte(crud.PostOK)
}
