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
	TableName        string `json:"ah_tablename"`
	TimeStamp        string `json:"ah_timestamp"`
	TenantId         string `json:"tenant_id"`
	Mac              string `json:"mac"`
	Pid              string `json:"pid"`
	CategoryId       string `json:"category_id"`
	DetectDate       string `json:"detect_date"`
	RegDate          string `json:"regdate"`
	UnregDate        string `json:"unregdate"`
	Lastskip         string `json:"lastskip"`
	TimeBalance      string `json:"time_balance"`
	BandwidthBalance string `json:"bandwidth_balance"`
	Status           string `json:"status"`
	UserAgent        string `json:"user_agent"`
	ComputerName     string `json:"computername"`
	Notes            string `json:"notes"`
	LastArp          string `json:"last_arp"`
	LastDhcp         string `json:"last_dhcp"`
	DhcpFingerprint  string `json:"dhcp_fingerprint"`
	Dhcp6Fingerprint string `json:"dhcp6_fingerprint"`
	DhcpVendor       string `json:"dhcp_vendor"`
	Dhcp6Enterprise  string `json:"dhcp6_enterprise"`
	DeviceType       string `json:"device_type"`
	DeviceClass      string `json:"device_class"`
	DeviceVersion    string `json:"device_version"`
	DeviceScore      string `json:"device_score"`
	BypassVlan       string `json:"bypass_vlan"`
	VoIp             string `json:"voip"`
	AutoReg          string `json:"autoreg"`
	SessionId        string `json:"sessionid"`
	MachineAccount   string `json:"machine_account"`
	BypassRoleId     string `json:"bypass_role_id"`
	LastSeen         string `json:"last_seen"`
}

type NodeReportData struct {
       TableName string `json:"tablename"`
       TimeStamp string `json:"timestamp"`
       Data NodeParseStruct  `json:"data"`
}

/*
type SqlNullFields struct {
	CategoryId       sql.NullInt64
	TimeBalance      sql.NullInt64
	BandwidthBalance sql.NullInt64
	SessionId        sql.NullString
	MachineAccount   sql.NullString
	BypassRoleId     sql.NullInt64
}

type TimeFields struct {
	DetectDate time.Time
	RegDate    time.Time
	UnregDate  time.Time
	Lastskip   time.Time
	LastArp    time.Time
	LastDhcp   time.Time
	LastSeen   time.Time
}

func tranTime2Ms(node *NodeStru, time TimeFields) {
	node.DetectDate = time.DetectDate.Unix()
	node.RegDate = time.RegDate.Unix()
	node.UnregDate = time.UnregDate.Unix()
	node.Lastskip = time.Lastskip.Unix()
	node.LastArp = time.LastArp.Unix()
	node.LastDhcp = time.LastDhcp.Unix()
	node.LastSeen = time.LastSeen.Unix()
}

func tranNullFields2Int64(dest *int64, src sql.NullInt64) {
	*dest = src.Int64
}

func tranNullFields2String(dest *string, src sql.NullString) {
	*dest = src.String
}

func tranNullFields(node *NodeStru, nullFields SqlNullFields) {
	tranNullFields2Int64(&node.CategoryId, nullFields.CategoryId)
	tranNullFields2Int64(&node.TimeBalance, nullFields.TimeBalance)
	tranNullFields2Int64(&node.TimeBalance, nullFields.TimeBalance)
	tranNullFields2Int64(&node.BypassRoleId, nullFields.BypassRoleId)
	tranNullFields2String(&node.SessionId, nullFields.SessionId)
	tranNullFields2String(&node.MachineAccount, nullFields.MachineAccount)
}
func getNodeTableItem(ctx context.Context) {
	//var context context.Context
	nodeInfo := NodeStru{}
	sqlNullFields := SqlNullFields{}
	timeFields := TimeFields{}

	tmpDB := new(amadb.A3Db)
	err := tmpDB.DbInit()
	if err != nil {
		//log.LoggerWContext(context).Error("Open database error: " + err.Error())
		return
	}
	db := tmpDB.Db
	defer db.Close()

	rows, err := db.Query("SELECT * FROM node")
	if err != nil {
		fmt.Println(err)
	} else {
		defer rows.Close()
		for rows.Next() {
			err := rows.Scan(&nodeInfo.TenantId, &nodeInfo.Mac, &nodeInfo.Pid, &sqlNullFields.CategoryId,
				&timeFields.DetectDate, &timeFields.RegDate, &timeFields.UnregDate, &timeFields.Lastskip,
				&sqlNullFields.TimeBalance, &sqlNullFields.BandwidthBalance, &nodeInfo.Status, &nodeInfo.UserAgent,
				&nodeInfo.ComputerName, &nodeInfo.Notes, &timeFields.LastArp, &timeFields.LastDhcp,
				&nodeInfo.DhcpFingerprint, &nodeInfo.Dhcp6Fingerprint, &nodeInfo.DhcpVendor, &nodeInfo.Dhcp6Enterprise,
				&nodeInfo.DeviceType, &nodeInfo.DeviceClass, &nodeInfo.DeviceVersion, &nodeInfo.DeviceScore,
				&nodeInfo.BypassVlan, &nodeInfo.VoIp, &nodeInfo.AutoReg, &sqlNullFields.SessionId,
				&sqlNullFields.MachineAccount, &sqlNullFields.BypassRoleId, &timeFields.LastSeen)
			if err != nil {
				fmt.Println(err)
				continue
			}
			tranTime2Ms(&nodeInfo, timeFields)
			tranNullFields(&nodeInfo, sqlNullFields)
			fmt.Printf("node info: %+v\n", nodeInfo)
			break
		}
	}
}

*/
