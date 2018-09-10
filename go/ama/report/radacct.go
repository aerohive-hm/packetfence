package report

type Radacct struct {
	RadacctID       int64  `json:"radacctID"`
	TenantID        int32  `json:"tenantID"`
	AcctSessionID   string `json:"acctSessionID"`
	AcctUniqueID    string `json:"acctUniqueID"`
	UserName        string `json:"userName"`
	GroupName       string `json:"groupName"`
	Realm           string `json:"realm"`
	NasIpAddress    string `json:"nasIpAddress"`
	NasPortID       string `json:"nasPortID"`
	NasPortType     string `json:"nasPortType"`
	AcctStartTime   int64  `json:"acctStartRime"`
	AcctUpdateTime  int64  `json:"acctUpdateTime"`
	AcctStopTime    int64  `json:"acctStopTime"`
	AcctInterval    int32  `json:"acctInterval"`
	AcctSessionTime uint32 `json:"acctSessionTime"`
	AcctAuthentic   string `json:"acctAuthentic"`
	ConnInfoStart   string `json:"connectInfoStart"`
	ConnInfoStop    string `json:"connectInfoStop"`
	AcctInputOcts   int64  `json:"acctInputOctets"`
	AcctOutputOcts  int64  `json:"acctOutputOctets"`
	CalledStaID     string `json:"calledStationID"`
	CallingStaID    string `json:"callingStationID"`
	AcctTermCause   string `json:"acctTerminateCause"`
	ServiceType     string `json:"serviceType"`
	FramedProtocol  string `json:"framedProtocol"`
	FramedIpAddr    string `json:"framedIpAddress"`
}
