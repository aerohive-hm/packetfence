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
	TenantId         string `json:"tenant_id,omitempty"`
	CreateAt         string `json:"created_at,omitempty"`
	Mac              string `json:"mac,omitempty"`
	Ip               string `json:"ip,omitempty"`
	ComputerName     string `json:"computer_name,omitempty"`
	UserName         string `json:"user_name,omitempty"`
	StripUserName    string `json:"stripped_user_name,omitempty"`
	Realm            string `json:"realm,omitempty"`
	EventType        string `json:"event_type,omitempty"`
	APId             string `json:"switch_id,omitempty"`
	APMac            string `json:"switch_mac,omitempty"`
	APIpAddr         string `json:"switch_ip_address,omitempty"`
	RadSrcIpAddr     string `json:"radius_source_ip_address,omitempty"`
	CalledStationID  string `json:"called_station_id,omitempty"`
	CallingStationID string `json:"calling_station_id,omitempty"`
	NasPortType      string `json:"nas_port_type,omitempty"`
	SSID             string `json:"ssid,omitempty"`
	NasPortID        string `json:"nas_port_id,omitempty"`
	Ifindex          string `json:"ifindex,omitempty"`
	NasPort          string `json:" nas_port,omitempty"`
	ConnectionType   string `json:"connection_type,omitempty"`
	NasIpAddr        string `json:"nas_ip_address,omitempty"`
	NasIdentifier    string `json:"nas_identifier,omitempty"`
	AuthStatus       string `json:"auth_status,omitempty"`
	Reason           string `json:"reason,omitempty"`
	AuthType         string `json:"auth_type,omitempty"`
	EapType          string `json:"eap_type,omitempty"`
	Role             string `json:"role,omitempty"`
	NodeStatus       string `json:"node_status,omitempty"`
	Profile          string `json:"profile,omitempty"`
	Source           string `json:"source,omitempty"`
	AutoReg          string `json:"auto_reg,omitempty"`
	IsPhone          string `json:"is_phone,omitempty"`
	PfDomain         string `json:"pf_domain,omitempty"`
	UUID             string `json:"uuid,omitempty"`
	RadRequest       string `json:"radius_request,omitempty"`
	RadReply         string `json:"radius_reply,omitempty"`
	RequestTime      string `json:"request_time,omitempty"`
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
