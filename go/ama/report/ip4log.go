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
	TableName        string `json:"ah_tablename"`
	TimeStamp        string `json:"ah_timestamp"`
	TenantID         string `json:"tenant_id"`
	Mac              string `json:"mac"`
	Ip               string `json:"ip"`
	StartTime        string `json:"start_time"`
	EndTime          string `json:"end_time"`
}

type Ip4logReportData struct {
       TableName string `json:"tablename"`
       TimeStamp string `json:"timestamp"`
       Data Ip4logParseStruct  `json:"data"`
}