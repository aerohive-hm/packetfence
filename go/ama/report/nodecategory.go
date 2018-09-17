package report

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
	CategoryID     string  `json:"category_id"`
	Name           string  `json:"name"`
	MaxNodesPerPid string  `json:"max_nodes_per_pid"`
	Notes          string  `json:"notes"`
}


type NodecategoryReportData struct {
	TableName string `json:"ah_tablename"`
	TimeStamp string `json:"ah_timestamp"`
	CategoryID int `json:"category_id"`
	Name       string  `json:"name"`
}
