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
	TableName       string `json:"ah_tablename"`
	TimeStamp       string `json:"ah_timestamp"`
	RadacctID       string `json:"radacctid"`
	TenantID        string `json:"tenant_id"`
	AcctSessionID   string `json:"acctsessionid"`
	AcctUniqueID    string `json:"acctuniqueid"`
	UserName        string `json:"username"`
	GroupName       string `json:"groupname"`
	Realm           string `json:"realm"`
	NasIpAddress    string `json:"nasipaddress"`
	NasPortID       string `json:"nasportid"`
	NasPortType     string `json:"nasporttype"`
	AcctStartTime   string `json:"acctstarttime"`
	AcctUpdateTime  string `json:"acctupdatetime"`
	AcctStopTime    string `json:"acctstoptime"`
	AcctInterval    string `json:"acctinterval"`
	AcctSessionTime string `json:"acctsessiontime"`
	AcctAuthentic   string `json:"acctauthentic"`
	ConnInfoStart   string `json:"connectinfo_start"`
	ConnInfoStop    string `json:"connectinfo_stop"`
	AcctInputOcts   string `json:"acctinputoctets"`
	AcctOutputOcts  string `json:"acctoutputoctets"`
	CalledStaID     string `json:"calledstationid"`
	CallingStaID    string `json:"callingstationid"`
	AcctTermCause   string `json:"acctterminatecause"`
	ServiceType     string `json:"servicetype"`
	FramedProtocol  string `json:"framedprotocol"`
	FramedIpAddr    string `json:"framedipaddress"`
}

type RadacctReportData struct {
	TableName string `json:"ah_tablename"`
	TimeStamp string `json:"ah_timestamp"`
	RadacctID int64  `json:"radacctid"`
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
