package report

/*
MariaDB [A3]> show columns from node;
+-------------------+------------------+------+-----+---------------------+-------+
| Field             | Type             | Null | Key | Default             | Extra |
+-------------------+------------------+------+-----+---------------------+-------+
| tenant_id         | int(11)          | NO   | PRI | 1                   |       |
| mac               | varchar(17)      | NO   | PRI | NULL                |       |
| pid               | varchar(255)     | NO   | MUL | default             |       |
| category_id       | int(11)          | YES  | MUL | NULL                |       |
| detect_date       | datetime         | NO   |     | 0000-00-00 00:00:00 |       |
| regdate           | datetime         | NO   |     | 0000-00-00 00:00:00 |       |
| unregdate         | datetime         | NO   |     | 0000-00-00 00:00:00 |       |
| lastskip          | datetime         | NO   |     | 0000-00-00 00:00:00 |       |
| time_balance      | int(10) unsigned | YES  |     | NULL                |       |
| bandwidth_balance | int(10) unsigned | YES  |     | NULL                |       |
| status            | varchar(15)      | NO   | MUL | unreg               |       |
| user_agent        | varchar(255)     | YES  |     | NULL                |       |
| computername      | varchar(255)     | YES  |     | NULL                |       |
| notes             | varchar(255)     | YES  |     | NULL                |       |
| last_arp          | datetime         | NO   |     | 0000-00-00 00:00:00 |       |
| last_dhcp         | datetime         | NO   |     | 0000-00-00 00:00:00 |       |
| dhcp_fingerprint  | varchar(255)     | YES  | MUL | NULL                |       |
| dhcp6_fingerprint | varchar(255)     | YES  |     | NULL                |       |
| dhcp_vendor       | varchar(255)     | YES  |     | NULL                |       |
| dhcp6_enterprise  | varchar(255)     | YES  |     | NULL                |       |
| device_type       | varchar(255)     | YES  |     | NULL                |       |
| device_class      | varchar(255)     | YES  |     | NULL                |       |
| device_version    | varchar(255)     | YES  |     | NULL                |       |
| device_score      | varchar(255)     | YES  |     | NULL                |       |
| bypass_vlan       | varchar(50)      | YES  |     | NULL                |       |
| voip              | enum('no','yes') | NO   |     | no                  |       |
| autoreg           | enum('no','yes') | NO   |     | no                  |       |
| sessionid         | varchar(30)      | YES  |     | NULL                |       |
| machine_account   | varchar(255)     | YES  |     | NULL                |       |
| bypass_role_id    | int(11)          | YES  |     | NULL                |       |
| last_seen         | datetime         | NO   | MUL | 0000-00-00 00:00:00 |       |
+-------------------+------------------+------+-----+---------------------+-------+
31 rows in set (0.00 sec)
*/

type NodeParseStruct struct {
	TableName        string      `json:"ah_tablename"`
	TimeStamp        string      `json:"ah_timestamp"`
	TenantId         interface{} `json:"tenant_id,omitempty"`
	Mac              string      `json:"mac,omitempty"`
	Pid              string      `json:"pid,omitempty"`
	CategoryId       string      `json:"category_id,omitempty"`
	DetectDate       string      `json:"detect_date,omitempty"`
	RegDate          string      `json:"regdate,omitempty"`
	UnregDate        string      `json:"unregdate,omitempty"`
	Lastskip         string      `json:"lastskip,omitempty"`
	TimeBalance      string      `json:"time_balance,omitempty"`
	BandwidthBalance string      `json:"bandwidth_balance,omitempty"`
	Status           string      `json:"status,omitempty"`
	UserAgent        string      `json:"user_agent,omitempty"`
	ComputerName     string      `json:"computername,omitempty"`
	Notes            string      `json:"notes,omitempty"`
	LastArp          string      `json:"last_arp,omitempty"`
	LastDhcp         string      `json:"last_dhcp,omitempty"`
	DhcpFingerprint  string      `json:"dhcp_fingerprint,omitempty"`
	Dhcp6Fingerprint string      `json:"dhcp6_fingerprint,omitempty"`
	DhcpVendor       string      `json:"dhcp_vendor,omitempty"`
	Dhcp6Enterprise  string      `json:"dhcp6_enterprise,omitempty"`
	DeviceType       string      `json:"device_type,omitempty"`
	DeviceClass      string      `json:"device_class,omitempty"`
	DeviceVersion    string      `json:"device_version,omitempty"`
	DeviceScore      string      `json:"device_score,omitempty"`
	BypassVlan       string      `json:"bypass_vlan,omitempty"`
	VoIp             string      `json:"voip,omitempty"`
	AutoReg          string      `json:"autoreg,omitempty"`
	SessionId        string      `json:"sessionid,omitempty"`
	MachineAccount   string      `json:"machine_account,omitempty"`
	BypassRoleId     string      `json:"bypass_role_id,omitempty"`
	LastSeen         string      `json:"last_seen,omitempty"`
}

type NodeReportData struct {
	TableName string      `json:"ah_tablename"`
	TimeStamp string      `json:"ah_timestamp"`
	TenantId  interface{} `json:"tenant_id"`
	Mac       string      `json:"mac"`
}
