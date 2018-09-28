package amadb

import (
	"context"
	"fmt"
	"github.com/inverse-inc/packetfence/go/log"
)

func AddSysIdbyHost(sysid, host string) error {
	sql := SqlCmd2{
		Table: "a3_cluster_member",
		Vars:  "system_id, hostname",
		Args: []interface{}{
			sysid,
			host,
		},
	}

	db := new(A3Db)
	return db.Insert(sql)
}

func QuerySysIdbyHost(hostname string) string {
	var ctx = context.Background()
	var sysid string

	tmpDB := new(A3Db)
	err := tmpDB.DbInit()
	if err != nil {
		log.LoggerWContext(ctx).Error("Open database error: " + err.Error())
		return ""
	}
	db := tmpDB.Db
	defer db.Close()

	sql := fmt.Sprintf(`select system_id from a3_cluster_member where hostname = "%s"`, hostname)
	row := db.QueryRow(sql)
	err = row.Scan(&sysid)
	if err != nil {
		log.LoggerWContext(ctx).Error("Query database system_id error: " + err.Error())
		return ""
	}
	log.LoggerWContext(ctx).Info("Query system_id: " + sysid)
	return sysid
}

func DeleteSysIdbyHost(hostname string) error {
	sql := []SqlCmd{
		{
			`delete from a3_cluster_member where hostname = ?`,
			[]interface{}{
				hostname,
			},
		},
	}

	db := new(A3Db)
	return db.Exec(sql)

}
func QueryDBClusterIpSet() string {
	var ctx = context.Background()

	tmpDB := new(A3Db)
	err := tmpDB.DbInit()
	if err != nil {
		log.LoggerWContext(ctx).Error("Open database error: " + err.Error())
		return ""
	}
	db := tmpDB.Db
	defer db.Close()

	var strName, strValue string
	row := db.QueryRow("SHOW status LIKE 'wsrep_incoming_addresses'")
	err = row.Scan(&strName, &strValue)
	if err != nil {
		log.LoggerWContext(ctx).Error("Query database wsrep_incoming_addresses error: " + err.Error())
		return ""
	}

	log.LoggerWContext(ctx).Info("Query wsrep_incoming_addresses: " + strValue)

	return strValue
}
