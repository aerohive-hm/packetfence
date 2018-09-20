package report

/*
MariaDB [A3]> desc radius_audit_log;
+--------------------------+--------------+------+-----+-------------------+-----------------------------+
| Field                    | Type         | Null | Key | Default           | Extra                       |
+--------------------------+--------------+------+-----+-------------------+-----------------------------+
| id                       | int(11)      | NO   | PRI | NULL              | auto_increment              |
| tenant_id                | int(11)      | NO   |     | 1                 |                             |
| created_at               | timestamp    | NO   | MUL | CURRENT_TIMESTAMP | on update CURRENT_TIMESTAMP |
| mac                      | char(17)     | NO   | MUL | NULL              |                             |
| ip                       | varchar(255) | YES  | MUL | NULL              |                             |
| computer_name            | varchar(255) | YES  |     | NULL              |                             |
| user_name                | varchar(255) | YES  | MUL | NULL              |                             |
| stripped_user_name       | varchar(255) | YES  |     | NULL              |                             |
| realm                    | varchar(255) | YES  |     | NULL              |                             |
| event_type               | varchar(255) | YES  |     | NULL              |                             |
| switch_id                | varchar(255) | YES  |     | NULL              |                             |
| switch_mac               | varchar(255) | YES  |     | NULL              |                             |
| switch_ip_address        | varchar(255) | YES  |     | NULL              |                             |
| radius_source_ip_address | varchar(255) | YES  |     | NULL              |                             |
| called_station_id        | varchar(255) | YES  |     | NULL              |                             |
| calling_station_id       | varchar(255) | YES  |     | NULL              |                             |
| nas_port_type            | varchar(255) | YES  |     | NULL              |                             |
| ssid                     | varchar(255) | YES  |     | NULL              |                             |
| nas_port_id              | varchar(255) | YES  |     | NULL              |                             |
| ifindex                  | varchar(255) | YES  |     | NULL              |                             |
| nas_port                 | varchar(255) | YES  |     | NULL              |                             |
| connection_type          | varchar(255) | YES  |     | NULL              |                             |
| nas_ip_address           | varchar(255) | YES  |     | NULL              |                             |
| nas_identifier           | varchar(255) | YES  |     | NULL              |                             |
| auth_status              | varchar(255) | YES  | MUL | NULL              |                             |
| reason                   | text         | YES  |     | NULL              |                             |
| auth_type                | varchar(255) | YES  |     | NULL              |                             |
| eap_type                 | varchar(255) | YES  |     | NULL              |                             |
| role                     | varchar(255) | YES  |     | NULL              |                             |
| node_status              | varchar(255) | YES  |     | NULL              |                             |
| profile                  | varchar(255) | YES  |     | NULL              |                             |
| source                   | varchar(255) | YES  |     | NULL              |                             |
| auto_reg                 | char(1)      | YES  |     | NULL              |                             |
| is_phone                 | char(1)      | YES  |     | NULL              |                             |
| pf_domain                | varchar(255) | YES  |     | NULL              |                             |
| uuid                     | varchar(255) | YES  |     | NULL              |                             |
| radius_request           | text         | YES  |     | NULL              |                             |
| radius_reply             | text         | YES  |     | NULL              |                             |
| request_time             | int(11)      | YES  |     | NULL              |                             |
+--------------------------+--------------+------+-----+-------------------+-----------------------------+
39 rows in set (0.00 sec)
*/

type RadauditParseStruct struct {
	TableName string `json:"ah_tablename"`
	TimeStamp string `json:"ah_timestamp"`
	//Id               int    `json:"id"`
	TenantId         interface{} `json:"tenant_id"`
	CreateAt         string      `json:"created_at"`
	Mac              string      `json:"mac"`
	Ip               string      `json:"ip"`
	ComputerName     string      `json:"computer_name"`
	UserName         string      `json:"user_name"`
	StripUserName    string      `json:"stripped_user_name"`
	Realm            string      `json:"realm"`
	EventType        string      `json:"event_type"`
	APId             string      `json:"switch_id"`
	APMac            string      `json:"switch_mac"`
	APIpAddr         string      `json:"switch_ip_address"`
	RadSrcIpAddr     string      `json:"radius_source_ip_address"`
	CalledStationID  string      `json:"called_station_id"`
	CallingStationID string      `json:"calling_station_id"`
	NasPortType      string      `json:"nas_port_type"`
	SSID             string      `json:"ssid"`
	NasPortID        string      `json:"nas_port_id"`
	Ifindex          string      `json:"ifindex"`
	NasPort          string      `json:" nas_port"`
	ConnectionType   string      `json:"connection_type"`
	NasIpAddr        string      `json:"nas_ip_address"`
	NasIdentifier    string      `json:"nas_identifier"`
	AuthStatus       string      `json:"auth_status"`
	Reason           string      `json:"reason"`
	AuthType         string      `json:"auth_type"`
	EapType          string      `json:"eap_type"`
	Role             string      `json:"role"`
	NodeStatus       string      `json:"node_status"`
	Profile          string      `json:"profile"`
	Source           string      `json:"source"`
	AutoReg          string      `json:"auto_reg"`
	IsPhone          string      `json:"is_phone"`
	PfDomain         string      `json:"pf_domain"`
	UUID             string      `json:"uuid"`
	RadRequest       string      `json:"radius_request"`
	RadReply         string      `json:"radius_reply"`
	RequestTime      int         `json:"request_time"`
}

type RadauditReportData struct {
	TableName string `json:"ah_tablename"`
	TimeStamp string `json:"ah_timestamp"`
	Id        int    `json:"id"`
}

type StringExtend struct {
	Value []string `json:"value"`
}

type IntExtend struct {
	Value []int `json:"value"`
}

type RadauditOriData struct {
	UserName                  StringExtend `json:"User-Name"`
	NasIpAddress              StringExtend `json:"NAS-IP-Address"`
	NasPort                   IntExtend    `json:"NAS-Port"`
	ServiceType               IntExtend    `json:"Service-Type"`
	CalledStationId           StringExtend `json:"Called-Station-Id"`
	CallingStationId          StringExtend `json:"Calling-Station-Id"`
	NasIdentifier             StringExtend `json:"NAS-Identifier"`
	NasPortType               IntExtend    `json:"NAS-Port-Type"`
	AcctSessionId             StringExtend `json:"Acct-Session-Id"`
	AcctMultiSessionId        StringExtend `json:"Acct-Multi-Session-Id"`
	EventTimestamp            StringExtend `json:"Event-Timestamp"`
	StrippedUserName          StringExtend `json:"Stripped-User-Name"`
	Realm                     StringExtend `json:"Realm"`
	CalledStationSsid         StringExtend `json:"Called-Station-SSID"`
	FreeRadiusClientIpAddress StringExtend `json:"FreeRADIUS-Client-IP-Address"`
}
