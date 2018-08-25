package utils

import (
	"context"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"github.com/inverse-inc/packetfence/go/ama/database"
	"github.com/inverse-inc/packetfence/go/log"
	"strings"
)

func GetA3Version() string {
	cmd := "pfcmd version"
	out, err := ExecShell(cmd)
	if err != nil {
		fmt.Println("%s:exec error", cmd)
		return ""
	}
	i := strings.Index(out, "\n")
	return out[:i]
}

func GetSysUptime() int64 {
	return uptime()
}

func GetA3SysId() string {
	cmd := "cat /etc/A3.systemid"

	out, err := ExecShell(cmd)
	if err != nil {
		fmt.Println("%s:exec error", cmd)
		return ""
	}
	return out
}

func IsPrimaryCluster() bool {
	var ctx = context.Background()

	tmpDB := new(amadb.A3Db)
	err := tmpDB.DbInit()
	if err != nil {
		log.LoggerWContext(ctx).Error("Open database error: " + err.Error())
		return false
	}
	db := tmpDB.Db
	defer db.Close()

	var strName, strValue string
	row := db.QueryRow("SHOW status LIKE 'wsrep_cluster_status'")
	err = row.Scan(&strName, &strValue)
	if err != nil {
		log.LoggerWContext(ctx).Error("Query database error: " + err.Error())
		return false
	}
	fmt.Println("Cluster status:", strValue)
	return strValue == "Primary"
}
