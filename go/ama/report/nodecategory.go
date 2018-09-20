package report

import (
	"context"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"github.com/inverse-inc/packetfence/go/ama/database"
	"github.com/inverse-inc/packetfence/go/log"
)

/*
MariaDB [A3]> desc node_category;
+-------------------+--------------+------+-----+---------+----------------+
| Field             | Type         | Null | Key | Default | Extra          |
+-------------------+--------------+------+-----+---------+----------------+
| category_id       | int(11)      | NO   | PRI | NULL    | auto_increment |
| name              | varchar(255) | NO   | UNI | NULL    |                |
| max_nodes_per_pid | int(11)      | YES  |     | 0       |                |
| notes             | varchar(255) | YES  |     | NULL    |                |
+-------------------+--------------+------+-----+---------+----------------+
4 rows in set (0.00 sec)
*/

type NodecategoryParseStruct struct {
	TableName      string `json:"ah_tablename"`
	TimeStamp      string `json:"ah_timestamp"`
	CategoryID     int    `json:"category_id"`
	Name           string `json:"name"`
	MaxNodesPerPid string `json:"max_nodes_per_pid"`
	Notes          string `json:"notes"`
}

type NodecategoryReportData struct {
	TableName  string `json:"ah_tablename"`
	TimeStamp  string `json:"ah_timestamp"`
	CategoryID int    `json:"category_id"`
	Name       string `json:"name"`
}

func GetNodeCateId(ctx context.Context, role_name string) int {
	tmpDB := new(amadb.A3Db)
	err := tmpDB.DbInit()
	if err != nil {
		log.LoggerWContext(ctx).Error("Open database error: " + err.Error())
		return -1
	}
	db := tmpDB.Db
	defer db.Close()

	var cate_id int
	row := db.QueryRow(fmt.Sprintf("SELECT category_id FROM node_category WHERE name = '%s'", role_name))
	err = row.Scan(&cate_id)
	if err != nil {
		log.LoggerWContext(ctx).Error("Query database error: " + err.Error())
	} else {
		return cate_id
	}
	return -1
}
