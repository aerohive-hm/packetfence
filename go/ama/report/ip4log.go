package report

/*
MariaDB [A3]> desc ip4log;
+------------+-------------+------+-----+---------------------+-------+
| Field      | Type        | Null | Key | Default             | Extra |
+------------+-------------+------+-----+---------------------+-------+
| tenant_id  | int(11)     | NO   | PRI | 1                   |       |
| mac        | varchar(17) | NO   | MUL | NULL                |       |
| ip         | varchar(45) | NO   | PRI | NULL                |       |
| start_time | datetime    | NO   |     | NULL                |       |
| end_time   | datetime    | YES  | MUL | 0000-00-00 00:00:00 |       |
+------------+-------------+------+-----+---------------------+-------+
5 rows in set (0.00 sec)
*/

type Ip4logParseStruct struct {
	TableName string      `json:"ah_tablename"`
	TimeStamp string      `json:"ah_timestamp"`
	TenantID  interface{} `json:"tenant_id,omitempty"`
	Mac       string      `json:"mac,omitempty"`
	Ip        string      `json:"ip,omitempty"`
	StartTime string      `json:"start_time,omitempty"`
	EndTime   string      `json:"end_time,omitempty"`
}

type Ip4logReportData struct {
	TableName string      `json:"ah_tablename"`
	TimeStamp string      `json:"ah_timestamp"`
	TenantID  interface{} `json:"tenant_id"`
	Ip        string      `json:"ip"`
}
