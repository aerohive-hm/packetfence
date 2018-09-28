package report

import (
	"context"
	"database/sql"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"github.com/inverse-inc/packetfence/go/ama/database"
	"github.com/inverse-inc/packetfence/go/log"
	"time"
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
	CategoryID     int    `json:"category_id,omitempty"`
	Name           string `json:"name,omitempty"`
	MaxNodesPerPid string `json:"max_nodes_per_pid,omitempty"`
	Notes          string `json:"notes,omitempty"`
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

func PopAllNodeCategary(ctx context.Context) []interface{} {
	var nodeCateArray = make([]interface{}, 0)
	var note sql.NullString

	tmpDB := new(amadb.A3Db)
	err := tmpDB.DbInit()
	if err != nil {
		log.LoggerWContext(ctx).Error("Open database error: " + err.Error())
		return nil
	}
	db := tmpDB.Db
	defer db.Close()

	rows, err := db.Query("SELECT * FROM node_category")
	if err != nil {
		log.LoggerWContext(ctx).Error("Read rows fail")
		return nil
	}
	for rows.Next() {
		nodeCate := NodecategoryParseStruct{}
		nodeCate.TableName = "node_category"
		nodeCate.TimeStamp = fmt.Sprintf("%d", time.Now().UTC().UnixNano()*1000/(int64(time.Millisecond)))
		if err := rows.Scan(&nodeCate.CategoryID, &nodeCate.Name, &nodeCate.MaxNodesPerPid, &note); err != nil {
			log.LoggerWContext(ctx).Error("Read data fail")
			continue
		}
		nodeCateArray = append(nodeCateArray, nodeCate)
	}

	return nodeCateArray
}
