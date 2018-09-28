package report

/*
MariaDB [A3]> desc violation;
+--------------+--------------+------+-----+---------------------+----------------+
| Field        | Type         | Null | Key | Default             | Extra          |
+--------------+--------------+------+-----+---------------------+----------------+
| id           | int(11)      | NO   | PRI | NULL                | auto_increment |
| tenant_id    | int(11)      | NO   | MUL | 1                   |                |
| mac          | varchar(17)  | NO   | MUL | NULL                |                |
| vid          | int(11)      | NO   | MUL | NULL                |                |
| start_date   | datetime     | NO   |     | NULL                |                |
| release_date | datetime     | YES  | MUL | 0000-00-00 00:00:00 |                |
| status       | varchar(10)  | YES  | MUL | open                |                |
| ticket_ref   | varchar(255) | YES  |     | NULL                |                |
| notes        | text         | YES  |     | NULL                |                |
+--------------+--------------+------+-----+---------------------+----------------+
9 rows in set (0.01 sec)
*/

type ViolationParseStruct struct {
	TableName   string      `json:"ah_tablename"`
	TimeStamp   string      `json:"ah_timestamp"`
	Id          interface{} `json:"id,omitempty"`
	TenantID    string      `json:"tenant_id,omitempty"`
	Mac         string      `json:"mac,omitempty"`
	Vid         string      `json:"vid,omitempty"`
	StartDate   string      `json:"start_date,omitempty"`
	ReleaseDate string      `json:"release_date,omitempty"`
	Status      string      `json:"status,omitempty"`
	TicketRef   string      `json:"ticket_ref,omitempty"`
	Notes       string      `json:"notes,omitempty"`
}

type ViolationReportData struct {
	TableName string      `json:"ah_tablename"`
	TimeStamp string      `json:"ah_timestamp"`
	Id        interface{} `json:"id"`
}
