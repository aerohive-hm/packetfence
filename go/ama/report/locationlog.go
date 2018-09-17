package report

/*
MariaDB [A3]> desc locationlog;
+---------------------+--------------+------+-----+---------------------+----------------+
| Field               | Type         | Null | Key | Default             | Extra          |
+---------------------+--------------+------+-----+---------------------+----------------+
| id                  | int(11)      | NO   | PRI | NULL                | auto_increment |
| tenant_id           | int(11)      | NO   |     | 1                   |                |
| mac                 | varchar(17)  | YES  | MUL | NULL                |                |
| switch              | varchar(17)  | NO   | MUL |                     |                |
| port                | varchar(20)  | NO   |     |                     |                |
| vlan                | varchar(50)  | YES  |     | NULL                |                |
| role                | varchar(255) | YES  |     | NULL                |                |
| connection_type     | varchar(50)  | NO   |     |                     |                |
| connection_sub_type | varchar(50)  | YES  |     | NULL                |                |
| dot1x_username      | varchar(255) | NO   |     |                     |                |
| ssid                | varchar(32)  | NO   |     |                     |                |
| start_time          | datetime     | NO   |     | 0000-00-00 00:00:00 |                |
| end_time            | datetime     | NO   | MUL | 0000-00-00 00:00:00 |                |
| switch_ip           | varchar(17)  | YES  |     | NULL                |                |
| switch_mac          | varchar(17)  | YES  |     | NULL                |                |
| stripped_user_name  | varchar(255) | YES  |     | NULL                |                |
| realm               | varchar(255) | YES  |     | NULL                |                |
| session_id          | varchar(255) | YES  |     | NULL                |                |
| ifDesc              | varchar(255) | YES  |     | NULL                |                |
+---------------------+--------------+------+-----+---------------------+----------------+
19 rows in set (0.00 sec)
*/


type LocationlogParseStruct struct {
	TableName        string `json:"ah_tablename"`
	TimeStamp        string `json:"ah_timestamp"`
	Id               string `json:"id"`
	TenantID         string `json:"tenant_id"`
	Mac              string `json:"mac"`
	Switch           string `json:"switch"`
	Port             string `json:"port"`
	Vlan             string `json:"vlan"`
	Role             string `json:"role"`
	ConnType         string `json:"connection_type"`
	connSubType      string `json:"connection_sub_type"`
	Dot1xUserName    string `json:"dot1x_username"`
	Ssid             string `json:"ssid"`
	StartTime        string `json:"start_time"`
	EndTime          string `json:"end_time"`
	SwitchIp         string `json:"switch_ip"`
	SwitchMac        string `json:"switch_mac"`
	StrippedUserName string `json:"stripped_user_name"`
	Realm            string `json:"realm"`
	SessionId        string `json:"session_id"`
	IfDesc           string `json:"ifDesc"`
}

type LocationlogReportData struct {
	TableName string `json:"ah_tablename"`
	TimeStamp string `json:"ah_timestamp"`
	Id         int   `json:"id"`
}