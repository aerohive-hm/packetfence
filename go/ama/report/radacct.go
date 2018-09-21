package report

/*
MariaDB [A3]> desc radacct;
+--------------------+------------------+------+-----+---------+----------------+
| Field              | Type             | Null | Key | Default | Extra          |
+--------------------+------------------+------+-----+---------+----------------+
| radacctid          | bigint(21)       | NO   | PRI | NULL    | auto_increment |
| tenant_id          | int(11)          | NO   |     | 1       |                |
| acctsessionid      | varchar(64)      | NO   | MUL |         |                |
| acctuniqueid       | varchar(32)      | NO   | MUL |         |                |
| username           | varchar(64)      | NO   | MUL |         |                |
| groupname          | varchar(64)      | NO   |     |         |                |
| realm              | varchar(64)      | YES  |     |         |                |
| nasipaddress       | varchar(15)      | NO   | MUL |         |                |
| nasportid          | varchar(32)      | YES  |     | NULL    |                |
| nasporttype        | varchar(32)      | YES  |     | NULL    |                |
| acctstarttime      | datetime         | YES  | MUL | NULL    |                |
| acctupdatetime     | datetime         | YES  |     | NULL    |                |
| acctstoptime       | datetime         | YES  | MUL | NULL    |                |
| acctinterval       | int(12)          | YES  | MUL | NULL    |                |
| acctsessiontime    | int(12) unsigned | YES  | MUL | NULL    |                |
| acctauthentic      | varchar(32)      | YES  |     | NULL    |                |
| connectinfo_start  | varchar(50)      | YES  |     | NULL    |                |
| connectinfo_stop   | varchar(50)      | YES  |     | NULL    |                |
| acctinputoctets    | bigint(20)       | YES  |     | NULL    |                |
| acctoutputoctets   | bigint(20)       | YES  |     | NULL    |                |
| calledstationid    | varchar(50)      | NO   |     |         |                |
| callingstationid   | varchar(50)      | NO   | MUL |         |                |
| acctterminatecause | varchar(32)      | NO   |     |         |                |
| servicetype        | varchar(32)      | YES  |     | NULL    |                |
| framedprotocol     | varchar(32)      | YES  |     | NULL    |                |
| framedipaddress    | varchar(15)      | NO   | MUL |         |                |
+--------------------+------------------+------+-----+---------+----------------+
26 rows in set (0.00 sec)
*/

type RadacctParseStruct struct {
	TableName           string `json:"ah_tablename"`
	TimeStamp           string `json:"ah_timestamp"`
	RadacctID           string `json:"radacctid,omitempty"`
	TenantID            string `json:"tenant_id,omitempty"`
	AcctSessionID       string `json:"acctsessionid,omitempty"`
	AcctUniqueID        string `json:"acctuniqueid,omitempty"`
	UserName            string `json:"username,omitempty"`
	GroupName           string `json:"groupname,omitempty"`
	Realm               string `json:"realm,omitempty"`
	NasIpAddress        string `json:"nasipaddress,omitempty"`
	NasPortID           string `json:"nasportid,omitempty"`
	NasPortType         string `json:"nasporttype,omitempty"`
	AcctStartTime       string `json:"acctstarttime,omitempty"`
	AcctUpdateTime      string `json:"acctupdatetime,omitempty"`
	AcctStopTime        string `json:"acctstoptime,omitempty"`
	AcctInterval        string `json:"acctinterval,omitempty"`
	AcctSessionTime     string `json:"acctsessiontime,omitempty"`
	AcctAuthentic       string `json:"acctauthentic,omitempty"`
	ConnInfoStart       string `json:"connectinfo_start,omitempty"`
	ConnInfoStop        string `json:"connectinfo_stop,omitempty"`
	AcctInputOcts       int64  `json:"acctinputoctets,omitempty"`
	Acctinputgigawords  int64  `json:"acctinputgigawords,omitempty"`
	AcctOutputOcts      int64  `json:"acctoutputoctets,omitempty"`
	Acctoutputgigawords int64  `json:"acctoutputgigawords,omitempty"`
	CalledStaID         string `json:"calledstationid,omitempty"`
	CallingStaID        string `json:"callingstationid,omitempty"`
	AcctTermCause       string `json:"acctterminatecause,omitempty"`
	ServiceType         string `json:"servicetype,omitempty"`
	FramedProtocol      string `json:"framedprotocol,omitempty"`
	FramedIpAddr        string `json:"framedipaddress,omitempty"`
	AcctStatusType      string `json:"acctstatustype,omitempty"`
}

type RadacctReportData struct {
	TableName      string `json:"ah_tablename"`
	TimeStamp      string `json:"ah_timestamp"`
	AcctStatusType string `json:"acctstatustype"`
}

type RadacctOriData struct {
	UserName         StringExtend `json:"User-Name"`
	NasIpAddr        StringExtend `json:"NAS-IP-Address"`
	NasPort          IntExtend    `json:"NAS-Port"`
	ServiceType      IntExtend    `json:"Service-Type"`
	FramedIpAddress  StringExtend `json:"Framed-IP-Address"`
	CalledStationId  StringExtend `json:"Called-Station-Id"`
	CallingStationId StringExtend `json:"Calling-Station-Id"`
	NasIdentifier    StringExtend `json:"NAS-Identifier"`
	NasPortType      IntExtend    `json:"NAS-Port-Type"`
	AcctStatusType   IntExtend    `json:"NAS-Port-Type"`
	//AcctSessionId             StringExtend `json:"Acct-Session-Id"`
	AcctMultiSessionId        StringExtend `json:"Acct-Multi-Session-Id"`
	EventTimestamp            StringExtend `json:"Event-Timestamp"`
	StrippedUserName          StringExtend `json:"Stripped-User-Name"`
	Realm                     StringExtend `json:"Realm"`
	CalledStationSsid         StringExtend `json:"Called-Station-SSID"`
	FreeRadiusClientIpAddress StringExtend `json:"FreeRADIUS-Client-IP-Address"`
}
