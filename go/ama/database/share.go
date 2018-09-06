package amadb

import (
	"context"
	"fmt"
	"github.com/inverse-inc/packetfence/go/log"
)

func IsPrimaryCluster() bool {
	var ctx = context.Background()

	tmpDB := new(A3Db)
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
