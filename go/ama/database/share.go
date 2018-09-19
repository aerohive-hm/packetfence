package amadb

import (
	"context"
	//	"fmt"
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
