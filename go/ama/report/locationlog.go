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
	TableName        string      `json:"ah_tablename"`
	TimeStamp        string      `json:"ah_timestamp"`
	Id               interface{} `json:"id,omitempty"`
	TenantID         interface{} `json:"tenant_id,omitempty"`
	Mac              string      `json:"mac,omitempty"`
	Switch           string      `json:"switch,omitempty"`
	Port             interface{} `json:"port,omitempty"`
	Vlan             string      `json:"vlan,omitempty"`
	Role             string      `json:"role,omitempty"`
	ConnType         string      `json:"connection_type,omitempty"`
	connSubType      string      `json:"connection_sub_type,omitempty"`
	Dot1xUserName    string      `json:"dot1x_username,omitempty"`
	Ssid             string      `json:"ssid,omitempty"`
	StartTime        string      `json:"start_time,omitempty"`
	EndTime          string      `json:"end_time,omitempty"`
	SwitchIp         string      `json:"switch_ip,omitempty"`
	SwitchMac        string      `json:"switch_mac,omitempty"`
	StrippedUserName string      `json:"stripped_user_name,omitempty"`
	Realm            string      `json:"realm,omitempty"`
	SessionId        string      `json:"session_id,omitempty"`
	IfDesc           string      `json:"ifDesc,omitempty"`
}

type LocationlogReportData struct {
	TableName string `json:"ah_tablename"`
	TimeStamp string `json:"ah_timestamp"`
	Mac       string `json:"mac"`
}
